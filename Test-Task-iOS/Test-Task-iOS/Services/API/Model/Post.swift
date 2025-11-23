//
//  Post.swift
//  Test-Task-iOS
//
//  Created by Марк Киричко on 20.11.2025.
//

import Foundation

// MARK: - Post
struct Post: Codable {
    let userId, id: Int
    let title, body: String
    var isLiked: Bool?
}
