//
//  AgentView.swift
//  Ego
//
//  AI Agent视图 - 用户的数字分身
//

import SwiftUI

struct AgentView: View {
    @StateObject private var viewModel = AgentViewModel()
    @State private var inputText = ""
    @FocusState private var isInputFocused: Bool

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 顶部Agent状态卡片
                AgentStatusCard(agent: viewModel.userAgent)
                    .padding()

                // 快捷洞察卡片
                if !viewModel.insights.isEmpty {
                    InsightsCarousel(insights: viewModel.insights)
                        .frame(height: 160)
                }

                // 关系预测区域
                if !viewModel.predictions.isEmpty {
                    PredictionsSection(predictions: viewModel.predictions)
                }

                Divider()

                // 对话区域
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }

                            if viewModel.isProcessing {
                                TypingIndicator()
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        if let lastMessage = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }

                // 输入框
                MessageInputBar(
                    text: $inputText,
                    isFocused: _isInputFocused,
                    onSend: {
                        Task {
                            await viewModel.sendMessage(inputText)
                            inputText = ""
                        }
                    }
                )
            }
            .navigationTitle("AI分身")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.loadAgentData()
            }
        }
    }
}

// MARK: - Agent状态卡片
struct AgentStatusCard: View {
    let agent: UserAgent?

    var body: some View {
        HStack(spacing: 16) {
            // Agent头像
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)

                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("你的数字分身")
                    .font(.headline)

                if let agent = agent {
                    HStack(spacing: 12) {
                        StatusBadge(
                            text: agent.status.displayText,
                            color: agent.status.color
                        )

                        Text("知识库: \(agent.knowledgeBaseStats.totalDocuments)条")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // 完整度进度条
                    ProgressView(value: agent.knowledgeBaseStats.completeness)
                        .tint(.purple)
                }
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}

extension UserAgent.AgentStatus {
    var displayText: String {
        switch self {
        case .active: return "活跃"
        case .learning: return "学习中"
        case .idle: return "待机"
        }
    }

    var color: Color {
        switch self {
        case .active: return .green
        case .learning: return .orange
        case .idle: return .gray
        }
    }
}

struct StatusBadge: View {
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(text)
                .font(.caption)
                .foregroundColor(color)
        }
    }
}

// MARK: - 洞察轮播
struct InsightsCarousel: View {
    let insights: [Insight]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(insights) { insight in
                    InsightCard(insight: insight)
                        .frame(width: 300)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct InsightCard: View {
    let insight: Insight

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: insight.type.icon)
                    .foregroundColor(insight.type.color)

                Text(insight.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Spacer()

                if !insight.isRead {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                }
            }

            Text(insight.content)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(3)

            HStack {
                Text("置信度 \(Int(insight.confidence * 100))%")
                    .font(.caption)
                    .foregroundColor(.purple)

                Spacer()

                Text(insight.generatedAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(insight.type.color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(insight.type.color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

extension Insight.InsightType {
    var icon: String {
        switch self {
        case .personality: return "person.fill.viewfinder"
        case .pattern: return "chart.line.uptrend.xyaxis"
        case .relationship: return "person.2.fill"
        case .growth: return "arrow.up.right"
        case .commonality: return "hands.sparkles.fill"
        }
    }

    var color: Color {
        switch self {
        case .personality: return .purple
        case .pattern: return .blue
        case .relationship: return .pink
        case .growth: return .green
        case .commonality: return .orange
        }
    }
}

// MARK: - 关系预测区域
struct PredictionsSection: View {
    let predictions: [RelationshipPrediction]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("你可能与这些人产生连接")
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(predictions.prefix(5)) { prediction in
                        PredictionCard(prediction: prediction)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
}

struct PredictionCard: View {
    let prediction: RelationshipPrediction

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 原型标签
            Text(prediction.archetype)
                .font(.title3)
                .fontWeight(.bold)

            // 匹配分数
            HStack {
                Text("匹配度")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text("\(Int(prediction.matchScore * 100))%")
                    .font(.headline)
                    .foregroundColor(.purple)
            }

            // 共同异类特质
            if !prediction.commonQuirks.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("共同的异类特质")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    ForEach(prediction.commonQuirks.prefix(2), id: \.self) { quirk in
                        HStack(spacing: 4) {
                            Image(systemName: "sparkle")
                                .font(.caption2)
                            Text(quirk)
                                .font(.caption)
                        }
                        .foregroundColor(.orange)
                    }
                }
            }

            Spacer()

            // 已发现人数
            Text("已发现 \(prediction.matchedUsersCount) 人")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 200, height: 180)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.background)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - 消息气泡
struct MessageBubble: View {
    let message: AgentMessage

    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
            }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 6) {
                Text(message.content)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(message.role == .user ? Color.purple : Color.gray.opacity(0.2))
                    )
                    .foregroundColor(message.role == .user ? .white : .primary)

                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            if message.role == .agent {
                Spacer()
            }
        }
    }
}

// MARK: - 输入中指示器
struct TypingIndicator: View {
    @State private var dotCount = 0

    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 8, height: 8)
                        .opacity(dotCount == index ? 1.0 : 0.3)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.2))
            )

            Spacer()
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                dotCount = (dotCount + 1) % 3
            }
        }
    }
}

// MARK: - 消息输入栏
struct MessageInputBar: View {
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding
    let onSend: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            TextField("问问你的AI分身...", text: $text, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray.opacity(0.1))
                )
                .focused(isFocused)

            Button(action: onSend) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundColor(text.isEmpty ? .gray : .purple)
            }
            .disabled(text.isEmpty)
        }
        .padding()
        .background(.background)
    }
}

// MARK: - 预览
struct AgentView_Previews: PreviewProvider {
    static var previews: some View {
        AgentView()
    }
}
