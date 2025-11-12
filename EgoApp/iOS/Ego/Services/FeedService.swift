//
//  FeedService.swift
//  Ego
//
//  Feed流服务 - 推荐算法与内容获取
//

import Foundation

class FeedService {
    private let apiClient: APIClient

    init(apiClient: APIClient = APIClient.shared) {
        self.apiClient = apiClient
    }

    // MARK: - 获取Feed内容
    func getFeedItems(page: Int, pageSize: Int) async throws -> [FeedItem] {
        try await apiClient.request(
            endpoint: "/feed",
            method: .get,
            queryParams: [
                "page": "\(page)",
                "pageSize": "\(pageSize)"
            ]
        )
    }

    // MARK: - 获取每日统计
    func getDailyStats() async throws -> DailyStats {
        try await apiClient.request(
            endpoint: "/feed/daily-stats",
            method: .get
        )
    }

    // MARK: - 点赞事件
    func likeEvent(_ eventId: String) async throws {
        try await apiClient.request(
            endpoint: "/events/\(eventId)/like",
            method: .post
        )
    }

    // MARK: - 获取事件详情
    func getEventDetail(_ eventId: String) async throws -> KeyEvent {
        try await apiClient.request(
            endpoint: "/events/\(eventId)",
            method: .get
        )
    }

    // MARK: - 获取事件评论
    func getEventComments(_ eventId: String) async throws -> [Comment] {
        try await apiClient.request(
            endpoint: "/events/\(eventId)/comments",
            method: .get
        )
    }

    // MARK: - 添加评论
    func addComment(_ eventId: String, content: String, isAnonymous: Bool) async throws {
        try await apiClient.request(
            endpoint: "/events/\(eventId)/comments",
            method: .post,
            body: [
                "content": content,
                "isAnonymous": isAnonymous
            ]
        )
    }
}
