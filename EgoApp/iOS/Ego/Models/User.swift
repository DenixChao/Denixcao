//
//  User.swift
//  Ego
//
//  用户模型 - 包含完整的用户画像数据
//

import Foundation

// MARK: - 用户基础信息
struct User: Codable, Identifiable {
    let id: String
    var username: String
    var walletAddress: String?
    var profileImage: String?
    var createdAt: Date
    var nftTokenId: String?  // Web3数据资产NFT ID

    // 用户画像
    var profile: UserProfile?

    // 统计数据
    var stats: UserStats
}

// MARK: - 用户画像
struct UserProfile: Codable {
    var id: String
    var userId: String

    // 性格测试结果
    var personalityTraits: [PersonalityTrait]

    // 关键事件
    var keyEvents: [KeyEvent]

    // 擅长
    var skills: [Skill]

    // 喜好
    var interests: [Interest]

    // 癖好（高度隐私）
    var quirks: [Quirk]

    // 向量化表示（用于RAG匹配）
    var embedding: [Double]?

    var updatedAt: Date
}

// MARK: - 性格特质
struct PersonalityTrait: Codable, Identifiable {
    let id: String
    var name: String          // 如: "黑暗三元素-自恋"
    var score: Double         // 0-100
    var category: Category
    var isPublic: Bool        // 是否公开

    enum Category: String, Codable {
        case darkTriad        // 黑暗三元素
        case bigFive         // 五大人格
        case custom          // 自定义
    }
}

// MARK: - 关键事件
struct KeyEvent: Codable, Identifiable {
    let id: String
    var title: String
    var description: String
    var emotionalImpact: Int  // -10 到 +10
    var privacyLevel: PrivacyLevel
    var tags: [String]
    var timestamp: Date

    // 社交数据（裸奔模式）
    var likes: Int
    var comments: [Comment]

    enum PrivacyLevel: String, Codable {
        case `private`  // 完全私密，只有用户和AI知道
        case semi       // 半公开，用于匿名匹配
        case `public`   // 裸奔模式，在Feed流展示
    }
}

// MARK: - 技能
struct Skill: Codable, Identifiable {
    let id: String
    var name: String
    var level: Int           // 1-10
    var verifiedBy: [String] // 验证者（未来可以是其他用户）
}

// MARK: - 兴趣
struct Interest: Codable, Identifiable {
    let id: String
    var name: String
    var intensity: Int       // 1-10
    var category: String
}

// MARK: - 癖好（高度隐私）
struct Quirk: Codable, Identifiable {
    let id: String
    var description: String
    var tags: [String]
    var isUncommon: Bool     // 是否是"异类"特质
}

// MARK: - 评论
struct Comment: Codable, Identifiable {
    let id: String
    var userId: String
    var content: String
    var timestamp: Date
    var isAnonymous: Bool
}

// MARK: - 用户统计
struct UserStats: Codable {
    var totalEvents: Int
    var publicEvents: Int
    var totalLikes: Int
    var matchedSouls: Int    // 匹配到的灵魂相似者数量
    var dataAssetValue: Double // 数据资产价值（$EGO代币）
}

// MARK: - Feed内容项
struct FeedItem: Codable, Identifiable {
    let id: String
    var event: KeyEvent
    var author: FeedAuthor   // 可以是匿名的
    var matchScore: Double   // 与当前用户的匹配分数
    var isQuirkyMatch: Bool  // 是否是"异类共鸣"匹配

    struct FeedAuthor: Codable {
        var userId: String
        var username: String
        var isAnonymous: Bool
    }
}
