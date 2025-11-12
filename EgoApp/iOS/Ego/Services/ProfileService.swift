//
//  ProfileService.swift
//  Ego
//
//  用户画像服务
//

import Foundation

@MainActor
class ProfileService: ObservableObject {
    @Published var userProfile: UserProfile?

    private let apiClient: APIClient

    init(apiClient: APIClient = APIClient.shared) {
        self.apiClient = apiClient
    }

    // MARK: - 加载用户画像
    func loadUserProfile() async {
        do {
            userProfile = try await apiClient.getUserProfile()
        } catch {
            print("Error loading profile: \(error)")
        }
    }

    // MARK: - 添加关键事件
    func addKeyEvent(_ event: KeyEvent) async throws {
        let updatedProfile = try await apiClient.addKeyEvent(event)
        userProfile = updatedProfile

        // 如果是裸奔模式，触发向量更新
        if event.privacyLevel == .public {
            try await updateEmbedding()
        }
    }

    // MARK: - 更新性格特质
    func updatePersonalityTraits(_ traits: [PersonalityTrait]) async throws {
        let updatedProfile = try await apiClient.updatePersonalityTraits(traits)
        userProfile = updatedProfile
    }

    // MARK: - 添加技能
    func addSkill(_ skill: Skill) async throws {
        let updatedProfile = try await apiClient.addSkill(skill)
        userProfile = updatedProfile
    }

    // MARK: - 添加兴趣
    func addInterest(_ interest: Interest) async throws {
        let updatedProfile = try await apiClient.addInterest(interest)
        userProfile = updatedProfile
    }

    // MARK: - 添加癖好
    func addQuirk(_ quirk: Quirk) async throws {
        let updatedProfile = try await apiClient.addQuirk(quirk)
        userProfile = updatedProfile

        // 癖好更新后重新计算向量
        try await updateEmbedding()
    }

    // MARK: - 更新向量嵌入
    private func updateEmbedding() async throws {
        // 触发后端重新计算用户画像的向量表示
        try await apiClient.updateUserEmbedding()
    }

    // MARK: - 铸造数据资产NFT
    func mintDataAssetNFT() async throws -> String {
        let tokenId = try await apiClient.mintDataAssetNFT()
        return tokenId
    }
}
