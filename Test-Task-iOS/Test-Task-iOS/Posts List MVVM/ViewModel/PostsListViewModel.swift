//
//  PostsListViewModel.swift
//  Test-Task-iOS
//
//  Created by Марк Киричко on 20.11.2025.
//

import Foundation

protocol IPostsListViewModel: AnyObject {
    func postsItem(index: Int)-> Post
    func postsCount()-> Int
    func getPosts()
    func getPostsFromAPI()
    func getPostsFromDB()
    func toggleLike(post: Post)
    func refreshData()
    func handlePagination(offset: Double, contentHeight: Double, frameHeight: Double)
    func registerLoadingHandler(block: @escaping(Bool)->Void)
    func registerItemChangedHandler(block: @escaping(Int)->Void)
}

final class PostsListViewModel: IPostsListViewModel {
    
    var posts = [Post]()
    var currentPage = 1
    
    var loadingHandler: ((Bool)->Void)?
    var itemChangedHandler: ((Int)->Void)?
    var isLoading = false
    
    // MARK: - сервисы
    private let apiService: IAPIService
    private let coreDataManager: ICoreDataManager
    private let networkManager: INetworkManager
    
    init(apiService: IAPIService, coreDataManager: ICoreDataManager, networkManager: INetworkManager) {
        self.apiService = apiService
        self.coreDataManager = coreDataManager
        self.networkManager = networkManager
    }
    
    // MARK: - Public methods
    func postsItem(index: Int)-> Post {
        return posts[index]
    }
    
    func postsCount()-> Int {
        return posts.count
    }
    
    func getPosts() {
        networkManager.checkInternetConnection { [weak self] isConnected in
            if isConnected {
                self?.getPostsFromAPI()
            } else {
                self?.getPostsFromDB()
            }
        }
    }
    
    func getPostsFromAPI() {
        loadingHandler?(true)
        apiService.getPosts(page: currentPage, limit: 10) { [weak self] apiPosts in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self?.handlePostsFromAPI(apiPosts)
            }
        }
    }
    
    func getPostsFromDB() {
        loadingHandler?(true)
        let savedPosts = coreDataManager.fetchPosts()
        self.posts = mapToPosts(savedPosts)
        self.loadingHandler?(false)
    }
    
    func toggleLike(post: Post) {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        posts[index].isLiked?.toggle()
        coreDataManager.updatePost(post: posts[index])
        itemChangedHandler?(index)
    }
    
    private func handlePostsFromAPI(_ apiPosts: [Post]) {
        let savedPosts = coreDataManager.fetchPosts()
        let postsWithLikes = mergePostsWithSavedLikes(apiPosts: apiPosts, savedPosts: savedPosts)
        self.posts = postsWithLikes
        self.coreDataManager.savePosts(posts: postsWithLikes)
        self.loadingHandler?(false)
    }
    
    private func mergePostsWithSavedLikes(apiPosts: [Post], savedPosts: [PostModel]) -> [Post] {
        let savedPostsMap = Dictionary(uniqueKeysWithValues: savedPosts.map { ($0.id, $0.isLiked) })
        return apiPosts.map { apiPost in
            var post = apiPost
            post.isLiked = savedPostsMap[Int16(apiPost.id)] ?? false
            return post
        }
    }
    
    private func mapToPosts(_ postModels: [PostModel]) -> [Post] {
        return postModels.map {
            Post(
                userId: Int($0.userId),
                id: Int($0.id),
                title: $0.title ?? "",
                body: $0.body ?? "",
                isLiked: $0.isLiked
            )
        }
    }
    
    func refreshData() {
        posts = []
        getPosts()
    }
    
    func handlePagination(offset: Double, contentHeight: Double, frameHeight: Double) {
        
        let threshold = contentHeight - frameHeight - 50
        guard offset > threshold, offset > 0 else { return }
        
        guard !isLoading else { return }
        
        isLoading = true
        currentPage += 1
        
        apiService.getPosts(page: currentPage, limit: 10) { [weak self] apiPosts in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.posts.append(contentsOf: apiPosts)
                self.loadingHandler?(false)
                self.isLoading = false
            }
        }
    }
    
    func registerLoadingHandler(block: @escaping(Bool)->Void) {
        self.loadingHandler = block
    }
    
    func registerItemChangedHandler(block: @escaping(Int)->Void) {
        self.itemChangedHandler = block
    }
}
