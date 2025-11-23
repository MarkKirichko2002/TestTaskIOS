//
//  PostsListTableViewController.swift
//  Test-Task-iOS
//
//  Created by Марк Киричко on 20.11.2025.
//

import UIKit

final class PostsListTableViewController: UIViewController {
    
    // MARK: - UI
    let refresh = UIRefreshControl()
    let tableView = UITableView()
    let loadingLabel = UILabel()
    
    var viewModel: IPostsListViewModel
    var animationClass: IAnimationClass
    
    init(viewModel: IPostsListViewModel, animationClass: IAnimationClass) {
        self.viewModel = viewModel
        self.animationClass = animationClass
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigation()
        setUpTable()
        setUpLabel()
        setUpRefreshControl()
        bindViewModel()
    }
    
    private func setUpNavigation() {
        navigationItem.title = "Посты"
    }
    
    private func setUpTable() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.identifier)
    }
    
    private func setUpRefreshControl() {
        refresh.addTarget(self, action: #selector(refreshPosts), for: .valueChanged)
        tableView.addSubview(refresh)
    }
    
    @objc private func refreshPosts() {
        viewModel.refreshData()
    }
    
    private func setUpLabel() {
        view.addSubview(loadingLabel)
        loadingLabel.text = "Загрузка..."
        loadingLabel.font = .systemFont(ofSize: 20, weight: .medium)
        loadingLabel.isHidden = true
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func bindViewModel() {
        viewModel.registerLoadingHandler { isLoading in
            DispatchQueue.main.async {
                self.handleLabel(isLoading: isLoading)
                self.handleRefreshControl(isLoading: isLoading)
                self.tableView.reloadData()
            }
        }
        viewModel.registerItemChangedHandler { index in
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
            }
        }
        viewModel.getPosts()
    }
    
    private func handleLabel(isLoading: Bool) {
        self.loadingLabel.isHidden = !isLoading
        isLoading ? animationClass.springAnimation(view: self.loadingLabel) : animationClass.stopAnimation(view: self.loadingLabel)
    }
    
    private func handleRefreshControl(isLoading: Bool) {
        !isLoading ? refresh.endRefreshing() : nil
    }
}

// MARK: - UITableViewDelegate
extension PostsListTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as? PostTableViewCell else {return UITableViewCell()}
        cell.delegate = self
        cell.configure(post: viewModel.postsItem(index: indexPath.row))
        return cell
    }
}

// MARK: - UITableViewDataSource
extension PostsListTableViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.postsCount()
    }
}

// MARK: - PostTableViewCellDelegate
extension PostsListTableViewController: PostTableViewCellDelegate {
    
    func likeWasTapped(post: Post) {
        viewModel.toggleLike(post: post)
    }
}

// MARK: - UIScrollViewDelegate
extension PostsListTableViewController {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        viewModel.handlePagination(offset: scrollView.contentOffset.y, contentHeight: scrollView.contentSize.height, frameHeight: scrollView.frame.size.height)
    }
}
