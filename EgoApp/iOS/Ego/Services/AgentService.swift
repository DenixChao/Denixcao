//
//  AgentService.swift
//  Ego
//
//  AI Agent服务 - RAG系统核心
//

import Foundation

class AgentService {
    private let apiClient: APIClient

    init(apiClient: APIClient = APIClient.shared) {
        self.apiClient = apiClient
    }

    // MARK: - 获取用户Agent
    func getUserAgent() async throws -> UserAgent {
        try await apiClient.request(
            endpoint: "/agent",
            method: .get
        )
    }

    // MARK: - 查询Agent（RAG）
    func queryAgent(question: String, conversationHistory: [AgentMessage]) async throws -> AgentResponse {
        let query = AgentQuery(
            question: question,
            userId: "", // 将从token中获取
            context: AgentQuery.QueryContext(
                conversationHistory: conversationHistory,
                focusAreas: []
            )
        )

        return try await apiClient.request(
            endpoint: "/agent/query",
            method: .post,
            body: query
        )
    }

    // MARK: - 获取洞察
    func getLatestInsights(limit: Int = 10) async throws -> [Insight] {
        try await apiClient.request(
            endpoint: "/agent/insights",
            method: .get,
            queryParams: ["limit": "\(limit)"]
        )
    }

    // MARK: - 标记洞察已读
    func markInsightAsRead(_ insightId: String) async throws {
        try await apiClient.request(
            endpoint: "/agent/insights/\(insightId)/read",
            method: .post
        )
    }

    // MARK: - 获取关系预测
    func getRelationshipPredictions() async throws -> [RelationshipPrediction] {
        try await apiClient.request(
            endpoint: "/agent/predictions",
            method: .get
        )
    }

    // MARK: - 获取对话历史
    func getConversationHistory(limit: Int = 50) async throws -> [AgentMessage] {
        try await apiClient.request(
            endpoint: "/agent/conversations",
            method: .get,
            queryParams: ["limit": "\(limit)"]
        )
    }

    // MARK: - 发现相似灵魂
    func findSimilarSouls() async throws -> [SoulMatch] {
        try await apiClient.request(
            endpoint: "/agent/similar-souls",
            method: .get
        )
    }

    // MARK: - 触发Agent学习
    func triggerLearning() async throws {
        // 触发Agent重新学习用户数据，更新知识库
        try await apiClient.request(
            endpoint: "/agent/learn",
            method: .post
        )
    }
}
