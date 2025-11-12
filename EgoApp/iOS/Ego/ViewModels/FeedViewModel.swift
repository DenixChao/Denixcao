//
//  FeedViewModel.swift
//  Ego
//
//  Feed流的ViewModel
//

import Foundation
import Combine

@MainActor
class FeedViewModel: ObservableObject {
    @Published var feedItems: [FeedItem] = []
    @Published var isLoading = false
    @Published var selectedItem: FeedItem?
    @Published var dailyStats = DailyStats(
        similarSoulsFound: 0,
        totalLikes: 0,
        quirkyMatches: 0
    )

    private let feedService: FeedService
    private var currentPage = 0
    private let pageSize = 20

    init(feedService: FeedService = FeedService()) {
        self.feedService = feedService
    }

    func loadInitialFeed() async {
        isLoading = true
        defer { isLoading = false }

        do {
            // 加载每日统计
            dailyStats = try await feedService.getDailyStats()

            // 加载第一页Feed
            currentPage = 0
            feedItems = try await feedService.getFeedItems(
                page: currentPage,
                pageSize: pageSize
            )
        } catch {
            print("Error loading feed: \(error)")
        }
    }

    func loadMoreItems() async {
        guard !isLoading else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            currentPage += 1
            let newItems = try await feedService.getFeedItems(
                page: currentPage,
                pageSize: pageSize
            )
            feedItems.append(contentsOf: newItems)
        } catch {
            print("Error loading more items: \(error)")
            currentPage -= 1
        }
    }

    func refresh() async {
        await loadInitialFeed()
    }

    func shouldLoadMore(item: FeedItem) -> Bool {
        guard let index = feedItems.firstIndex(where: { $0.id == item.id }) else {
            return false
        }
        return index >= feedItems.count - 5
    }

    func selectItem(_ item: FeedItem) {
        selectedItem = item
    }

    func likeItem(_ item: FeedItem) async {
        do {
            try await feedService.likeEvent(item.event.id)

            // 更新本地数据
            if let index = feedItems.firstIndex(where: { $0.id == item.id }) {
                feedItems[index].event.likes += 1
            }
        } catch {
            print("Error liking item: \(error)")
        }
    }
}
