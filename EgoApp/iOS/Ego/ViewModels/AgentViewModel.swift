//
//  AgentViewModel.swift
//  Ego
//
//  AI Agent的ViewModel
//

import Foundation
import Combine

@MainActor
class AgentViewModel: ObservableObject {
    @Published var userAgent: UserAgent?
    @Published var messages: [AgentMessage] = []
    @Published var insights: [Insight] = []
    @Published var predictions: [RelationshipPrediction] = []
    @Published var isProcessing = false

    private let agentService: AgentService
    private var cancellables = Set<AnyCancellable>()

    init(agentService: AgentService = AgentService()) {
        self.agentService = agentService
    }

    func loadAgentData() async {
        do {
            // 加载Agent状态
            userAgent = try await agentService.getUserAgent()

            // 加载最新洞察
            insights = try await agentService.getLatestInsights(limit: 5)

            // 加载关系预测
            predictions = try await agentService.getRelationshipPredictions()

            // 加载对话历史
            messages = try await agentService.getConversationHistory(limit: 50)
        } catch {
            print("Error loading agent data: \(error)")
        }
    }

    func sendMessage(_ text: String) async {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        // 添加用户消息
        let userMessage = AgentMessage(
            id: UUID().uuidString,
            role: .user,
            content: text,
            timestamp: Date()
        )
        messages.append(userMessage)

        isProcessing = true
        defer { isProcessing = false }

        do {
            // 调用RAG Agent
            let response = try await agentService.queryAgent(
                question: text,
                conversationHistory: messages
            )

            // 添加Agent回复
            let agentMessage = AgentMessage(
                id: UUID().uuidString,
                role: .agent,
                content: response.answer,
                timestamp: Date(),
                retrievedContext: response.sources.map { $0.reference }
            )
            messages.append(agentMessage)

        } catch {
            print("Error querying agent: \(error)")

            // 错误消息
            let errorMessage = AgentMessage(
                id: UUID().uuidString,
                role: .system,
                content: "抱歉，我遇到了一些问题。请稍后再试。",
                timestamp: Date()
            )
            messages.append(errorMessage)
        }
    }

    func markInsightAsRead(_ insight: Insight) async {
        do {
            try await agentService.markInsightAsRead(insight.id)

            // 更新本地状态
            if let index = insights.firstIndex(where: { $0.id == insight.id }) {
                insights[index].isRead = true
            }
        } catch {
            print("Error marking insight as read: \(error)")
        }
    }
}
