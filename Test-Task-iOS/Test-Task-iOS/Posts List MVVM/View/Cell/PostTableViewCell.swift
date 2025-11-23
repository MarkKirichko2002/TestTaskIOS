//
//  PostTableViewCell.swift
//  Test-Task-iOS
//
//  Created by Марк Киричко on 20.11.2025.
//

import UIKit

protocol PostTableViewCellDelegate: AnyObject {
    func likeWasTapped(post: Post)
}

final class PostTableViewCell: UITableViewCell {
    
    private let postTitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .black)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let postDescription: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let postImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "heart")
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 24)
        button.configuration = config
        button.tintColor = .red
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    static let identifier = "PostTableViewCell"
    var currentPost = Post(userId: 0, id: 0, title: "", body: "", isLiked: false)
    
    weak var delegate: PostTableViewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpCell() {
        contentView.addSubview(postTitle)
        contentView.addSubview(postDescription)
        contentView.addSubview(postImage)
        contentView.addSubview(likeButton)
        likeButton.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
        makeConstraints()
    }
    
    private func makeConstraints() {
        
        let textStackView = UIStackView(arrangedSubviews: [postTitle, postDescription])
        textStackView.axis = .vertical
        textStackView.spacing = 10
        textStackView.alignment = .fill
        textStackView.distribution = .fill
        
        contentView.addSubview(textStackView)
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            postImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            postImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            postImage.widthAnchor.constraint(equalToConstant: 100),
            postImage.heightAnchor.constraint(equalToConstant: 100),
            
            textStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            textStackView.leadingAnchor.constraint(equalTo: postImage.trailingAnchor, constant: 10),
            textStackView.trailingAnchor.constraint(equalTo: likeButton.leadingAnchor, constant: -20),
            textStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            likeButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            likeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            likeButton.widthAnchor.constraint(equalToConstant: 40),
            likeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func configure(post: Post) {
        postTitle.text = post.title
        postDescription.text = post.body
        likeButton.setImage(UIImage(systemName: (post.isLiked ?? false) ? "heart.fill" : "heart"), for: .normal)
        currentPost = post
    }
    
    @objc private func likeTapped() {
        delegate?.likeWasTapped(post: currentPost)
    }
}
