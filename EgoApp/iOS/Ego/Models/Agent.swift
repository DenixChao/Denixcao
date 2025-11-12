//
//  Agent.swift
//  Ego
//
//  RAG Agent模型 - 用户的AI数字分身
//

import Foundation

// MARK: - User Agent
struct UserAgent: Codable, Identifiable {
    let id: String
    let userId: String

    // Agent状态
    var status: AgentStatus
    var lastActive: Date

    // 知识库统计
    var knowledgeBaseStats: KnowledgeBaseStats

    // 关系预测
    var relationshipPredictions: [RelationshipPrediction]

    // 自我洞察
    var insights: [Insight]

    enum AgentStatus: String, Codable {
        case active
        case learning    // 正在学习新数据
        case idle
    }
}

// MARK: - 知识库统计
struct KnowledgeBaseStats: Codable {
    var totalDocuments: Int      // 总文档数（事件、技能等）
    var vectorDimension: Int     // 向量维度
    var lastUpdated: Date
    var completeness: Double     // 完整度 0-1
}

// MARK: - 关系预测
struct RelationshipPrediction: Codable, Identifiable {
    let id: String

    // 预测的人群画像
    var archetype: String        // 如: "深夜创作者", "理性浪漫主义者"
    var traits: [String]         // 关键特质
    var matchScore: Double       // 匹配分数 0-1

    // 共同点
    var commonQuirks: [String]   // 共同的"异类"特质
    var commonInterests: [String]

    // 洞察
    var insight: String          // AI生成的洞察文本

    // 匹配到的真实用户数
    var matchedUsersCount: Int

    var generatedAt: Date
}

// MARK: - 自我洞察
struct Insight: Codable, Identifiable {
    let id: String

    var type: InsightType
    var title: String
    var content: String
    var confidence: Double       // 置信度 0-1

    // 支撑数据
    var supportingData: [String] // 相关事件ID等

    var generatedAt: Date
    var isRead: Bool

    enum InsightType: String, Codable {
        case personality     // 性格洞察
        case pattern        // 行为模式
        case relationship   // 关系模式
        case growth         // 成长建议
        case commonality    // "你并不孤单"类型
    }
}

// MARK: - Agent对话消息
struct AgentMessage: Codable, Identifiable {
    let id: String
    var role: Role
    var content: String
    var timestamp: Date

    // RAG检索的上下文（调试用）
    var retrievedContext: [String]?

    enum Role: String, Codable {
        case user
        case agent
        case system
    }
}

// MARK: - Agent查询请求
struct AgentQuery: Codable {
    var question: String
    var userId: String
    var context: QueryContext?

    struct QueryContext: Codable {
        var conversationHistory: [AgentMessage]
        var focusAreas: [String]  // 用户希望关注的方面
    }
}

// MARK: - Agent查询响应
struct AgentResponse: Codable {
    var answer: String
    var confidence: Double
    var sources: [Source]     // 引用的数据源
    var suggestedFollowUps: [String]  // 建议的后续问题

    struct Source: Codable, Identifiable {
        let id: String
        var type: SourceType
        var reference: String  // 如事件标题
        var relevance: Double

        enum SourceType: String, Codable {
            case event
            case skill
            case interest
            case quirk
            case personalityTrait
        }
    }
}

// MARK: - 相似灵魂匹配
struct SoulMatch: Codable, Identifiable {
    let id: String

    // 匹配用户（可以是匿名的）
    var matchedUser: MatchedUser
    var overallScore: Double

    // 详细匹配维度
    var dimensions: [MatchDimension]

    // 共鸣点
    var resonancePoints: [ResonancePoint]

    var discoveredAt: Date

    struct MatchedUser: Codable {
        var userId: String
        var displayName: String  // 可以是匿名昵称
        var avatar: String?
        var isAnonymous: Bool
    }

    struct MatchDimension: Codable {
        var name: String         // 如: "价值观", "兴趣", "异类特质"
        var score: Double
        var details: String
    }

    struct ResonancePoint: Codable, Identifiable {
        let id: String
        var description: String  // 如: "你们都喜欢在暴雨中独自散步"
        var rarity: Double      // 稀有度，越高越"异类"
    }
}
