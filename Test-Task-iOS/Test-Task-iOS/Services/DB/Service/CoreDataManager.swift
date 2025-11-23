//
//  CoreDataManager.swift
//  Test-Task-iOS
//
//  Created by Марк Киричко on 20.11.2025.
//

import CoreData

protocol ICoreDataManager: AnyObject {
    func saveContext()
    func savePosts(posts: [Post])
    func updatePost(post: Post)
    func deleteAllPosts()
    func fetchPosts()-> [PostModel]
}

final class CoreDataManager: ICoreDataManager {
    
    static let shared = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PostModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    // MARK: - сохранение постов
    func savePosts(posts: [Post]) {
        
        deleteAllPosts()
        
        let context = CoreDataManager.shared.context
        
        for item in posts {
            let post = PostModel(context: context)
            post.id = Int16(item.id)
            post.userId = Int16(item.userId)
            post.title = item.title
            post.body = item.body
        }
        CoreDataManager.shared.saveContext()
    }
    
    // MARK: - изменение статуса лайка
    func updatePost(post: Post) {
        let context = CoreDataManager.shared.context
        
        let fetchRequest: NSFetchRequest<PostModel> = PostModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", post.id)
        
        do {
            let existingPosts = try context.fetch(fetchRequest)
            
            if let existingPost = existingPosts.first {
                existingPost.isLiked = post.isLiked ?? false
                CoreDataManager.shared.saveContext()
                print("Пост обновлен: \(post.title)")
            } else {
                print("Пост не найден в Core Data")
            }
        } catch {
            print("Ошибка при обновлении поста: \(error)")
        }
    }
    
    // MARK: - удаление всех постов из Core Data
    func deleteAllPosts() {
        let context = CoreDataManager.shared.context
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = PostModel.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
        } catch {
            print("Error deleting posts: \(error)")
        }
    }
    
    // MARK: - получение постов из Core Data
    func fetchPosts()-> [PostModel] {
        let context = CoreDataManager.shared.context
        let fetchRequest: NSFetchRequest<PostModel> = NSFetchRequest<PostModel>(entityName: "PostModel")
        
        do {
            let posts = try context.fetch(fetchRequest)
            return posts
        } catch {
            print("Error fetching posts: \(error)")
            return []
        }
    }
}
