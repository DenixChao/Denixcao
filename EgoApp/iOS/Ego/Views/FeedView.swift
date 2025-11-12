//
//  FeedView.swift
//  Ego
//
//  双瀑布流Feed - 发现共鸣的事件段子
//

import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        NavigationView {
            ZStack {
                // 背景渐变
                LinearGradient(
                    colors: [.purple.opacity(0.1), .blue.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 20) {
                        // 顶部统计卡片
                        StatsHeaderCard(stats: viewModel.dailyStats)
                            .padding(.horizontal)

                        // 双列瀑布流
                        WaterfallGrid(items: viewModel.feedItems) { item in
                            FeedItemCard(item: item)
                                .onTapGesture {
                                    viewModel.selectItem(item)
                                }
                                .onAppear {
                                    // 预加载
                                    if viewModel.shouldLoadMore(item: item) {
                                        Task {
                                            await viewModel.loadMoreItems()
                                        }
                                    }
                                }
                        }
                        .padding(.horizontal)

                        // 加载指示器
                        if viewModel.isLoading {
                            ProgressView()
                                .padding()
                        }
                    }
                    .padding(.vertical)
                }
                .refreshable {
                    await viewModel.refresh()
                }
            }
            .navigationTitle("发现共鸣")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $viewModel.selectedItem) { item in
                FeedItemDetailView(item: item)
            }
            .task {
                await viewModel.loadInitialFeed()
            }
        }
    }
}

// MARK: - 统计卡片
struct StatsHeaderCard: View {
    let stats: DailyStats

    var body: some View {
        HStack(spacing: 20) {
            StatItem(
                icon: "person.2.fill",
                value: "\(stats.similarSoulsFound)",
                label: "相似灵魂"
            )

            Divider()
                .frame(height: 40)

            StatItem(
                icon: "heart.fill",
                value: "\(stats.totalLikes)",
                label: "收获认同"
            )

            Divider()
                .frame(height: 40)

            StatItem(
                icon: "sparkles",
                value: "\(stats.quirkyMatches)",
                label: "异类共鸣"
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}

struct StatItem: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.purple)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Feed项目卡片
struct FeedItemCard: View {
    let item: FeedItem
    @State private var isLiked = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 匹配标签
            if item.isQuirkyMatch {
                HStack {
                    Image(systemName: "sparkle")
                    Text("异类共鸣")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.orange)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.orange.opacity(0.15))
                )
            }

            // 事件内容
            VStack(alignment: .leading, spacing: 8) {
                Text(item.event.title)
                    .font(.headline)
                    .lineLimit(2)

                Text(item.event.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(4)
            }

            // 标签
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(item.event.tags, id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(Color.purple.opacity(0.1))
                            )
                    }
                }
            }

            Divider()

            // 底部操作栏
            HStack {
                // 作者（可能匿名）
                HStack(spacing: 6) {
                    Image(systemName: item.author.isAnonymous ? "person.fill.questionmark" : "person.circle.fill")
                        .font(.caption)
                    Text(item.author.username)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // 匹配度
                HStack(spacing: 4) {
                    Image(systemName: "arrow.triangle.merge")
                        .font(.caption)
                    Text("\(Int(item.matchScore * 100))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.purple)

                // 点赞按钮："有点东西"
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isLiked.toggle()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                            .font(.caption)
                        Text(isLiked ? "\(item.event.likes + 1)" : "\(item.event.likes)")
                            .font(.caption)
                    }
                    .foregroundColor(isLiked ? .orange : .gray)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - 瀑布流布局
struct WaterfallGrid<Content: View, Item: Identifiable>: View {
    let items: [Item]
    let content: (Item) -> Content
    let columns = 2
    let spacing: CGFloat = 16

    var body: some View {
        GeometryReader { geometry in
            let columnWidth = (geometry.size.width - spacing * CGFloat(columns - 1)) / CGFloat(columns)

            HStack(alignment: .top, spacing: spacing) {
                ForEach(0..<columns, id: \.self) { column in
                    LazyVStack(spacing: spacing) {
                        ForEach(itemsForColumn(column)) { item in
                            content(item)
                                .frame(width: columnWidth)
                        }
                    }
                }
            }
        }
        .frame(height: estimatedHeight())
    }

    private func itemsForColumn(_ column: Int) -> [Item] {
        items.enumerated()
            .filter { $0.offset % columns == column }
            .map { $0.element }
    }

    private func estimatedHeight() -> CGFloat {
        // 简单估算，实际应该根据内容动态计算
        let itemsPerColumn = CGFloat(items.count / columns + 1)
        return itemsPerColumn * 250  // 假设每个卡片平均高度250
    }
}

// MARK: - 每日统计数据
struct DailyStats {
    var similarSoulsFound: Int
    var totalLikes: Int
    var quirkyMatches: Int
}

// MARK: - 预览
struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}
