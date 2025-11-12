//
//  PersonalityTest.swift
//  Ego
//
//  快速性格测试 - 类似小红书黑暗人格测试
//  特点: 趣味化、去社会期待、无观察者效应
//

import Foundation

// MARK: - 性格测试
struct PersonalityTest: Codable, Identifiable {
    let id: String
    var title: String
    var description: String
    var version: String
    var questions: [TestQuestion]
    var estimatedMinutes: Int

    // 测试类型
    var testType: TestType

    enum TestType: String, Codable {
        case darkTriad       // 黑暗三元素
        case bigFive         // 五大人格
        case mixed           // 混合型
        case fun             // 趣味测试
    }
}

// MARK: - 测试题目
struct TestQuestion: Codable, Identifiable {
    let id: String
    var text: String
    var type: QuestionType
    var options: [QuestionOption]

    // 题目元数据
    var category: String         // 如: "自恋", "开放性"
    var weight: Double           // 权重
    var isReversed: Bool         // 是否反向计分

    enum QuestionType: String, Codable {
        case singleChoice        // 单选
        case multipleChoice      // 多选
        case scale              // 量表（1-5分）
        case binary             // 二选一
    }
}

// MARK: - 题目选项
struct QuestionOption: Codable, Identifiable {
    let id: String
    var text: String
    var value: Int               // 分值
    var emoji: String?           // 可选的emoji

    // 趣味化元素
    var funDescription: String?  // 如: "你就是夜晚的王者"
}

// MARK: - 用户答题记录
struct TestSubmission: Codable, Identifiable {
    let id: String
    var userId: String
    var testId: String
    var answers: [Answer]
    var startedAt: Date
    var completedAt: Date?
    var results: TestResult?

    struct Answer: Codable, Identifiable {
        let id: String
        var questionId: String
        var selectedOptions: [String]  // 选项ID数组
        var answeredAt: Date
    }
}

// MARK: - 测试结果
struct TestResult: Codable, Identifiable {
    let id: String

    // 主要维度得分
    var dimensionScores: [DimensionScore]

    // 生成的人格画像
    var archetype: Archetype

    // 详细分析
    var analysis: String

    // 可视化数据
    var radarChartData: [String: Double]  // 雷达图数据
    var tags: [String]                    // 标签云

    struct DimensionScore: Codable, Identifiable {
        let id: String
        var dimension: String    // 维度名称
        var score: Double       // 0-100
        var percentile: Int     // 百分位（与其他用户比较）
        var interpretation: String
    }

    struct Archetype: Codable {
        var name: String         // 如: "黑暗骑士", "理性浪漫主义者"
        var description: String
        var emoji: String
        var imageUrl: String?

        // 相似人群比例
        var populationPercentage: Double
    }
}

// MARK: - 示例测试题库
struct TestBank {
    // 黑暗三元素快速测试（10题）
    static let darkTriadQuickTest = PersonalityTest(
        id: "dark-triad-quick",
        title: "你的黑暗人格指数",
        description: "10道题测出你隐藏的另一面",
        version: "1.0",
        questions: [
            // 示例题目
            TestQuestion(
                id: "q1",
                text: "深夜独自一人时，你更可能...",
                type: .singleChoice,
                options: [
                    QuestionOption(
                        id: "q1_a",
                        text: "回顾今天操控他人的瞬间",
                        value: 5,
                        emoji: "👑",
                        funDescription: "你是黑暗中的棋手"
                    ),
                    QuestionOption(
                        id: "q1_b",
                        text: "思考如何变得更完美",
                        value: 3,
                        emoji: "💎",
                        funDescription: "自恋是你的勋章"
                    ),
                    QuestionOption(
                        id: "q1_c",
                        text: "计划明天的冒险",
                        value: 4,
                        emoji: "🎲",
                        funDescription: "危险让你兴奋"
                    ),
                    QuestionOption(
                        id: "q1_d",
                        text: "刷手机直到睡着",
                        value: 1,
                        emoji: "📱",
                        funDescription: "你是普通人类"
                    )
                ],
                category: "自恋倾向",
                weight: 1.0,
                isReversed: false
            ),
            TestQuestion(
                id: "q2",
                text: "如果能读心，你会...",
                type: .singleChoice,
                options: [
                    QuestionOption(
                        id: "q2_a",
                        text: "先看看别人怎么评价我",
                        value: 4,
                        emoji: "🪞",
                        funDescription: "镜子里的你最重要"
                    ),
                    QuestionOption(
                        id: "q2_b",
                        text: "找到所有人的弱点",
                        value: 5,
                        emoji: "🎯",
                        funDescription: "信息就是权力"
                    ),
                    QuestionOption(
                        id: "q2_c",
                        text: "不想读，太吵了",
                        value: 1,
                        emoji: "🙉",
                        funDescription: "你还是个好人"
                    )
                ],
                category: "马基雅维利主义",
                weight: 1.2,
                isReversed: false
            ),
            TestQuestion(
                id: "q3",
                text: "朋友找你倾诉失恋，你内心真实想法是...",
                type: .singleChoice,
                options: [
                    QuestionOption(
                        id: "q3_a",
                        text: "这是个展示我情商的机会",
                        value: 3,
                        emoji: "🎭",
                        funDescription: "人生如戏"
                    ),
                    QuestionOption(
                        id: "q3_b",
                        text: "无聊，但得装作关心",
                        value: 5,
                        emoji: "😶",
                        funDescription: "共情？不存在的"
                    ),
                    QuestionOption(
                        id: "q3_c",
                        text: "真心感到难过",
                        value: 0,
                        emoji: "💔",
                        funDescription: "你可能不适合这个测试"
                    )
                ],
                category: "精神病态",
                weight: 1.5,
                isReversed: false
            )
            // 更多题目...
        ],
        estimatedMinutes: 5,
        testType: .darkTriad
    )
}
