//
//  EgoApp.swift
//  Ego - AI时代的自我认知社交App
//
//  Created by Denix
//  底层哲学: 人是社会关系的总和
//

import SwiftUI

@main
struct EgoApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var authService = AuthenticationService()
    @StateObject private var profileService = ProfileService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(authService)
                .environmentObject(profileService)
                .onAppear {
                    // 初始化应用
                    Task {
                        await initializeApp()
                    }
                }
        }
    }

    private func initializeApp() async {
        // 检查用户认证状态
        await authService.checkAuthStatus()

        // 加载用户配置
        if authService.isAuthenticated {
            await profileService.loadUserProfile()
        }
    }
}

// MARK: - App State Manager
class AppState: ObservableObject {
    @Published var isLoading = false
    @Published var currentTab: Tab = .feed
    @Published var showError = false
    @Published var errorMessage = ""

    enum Tab {
        case feed       // 双瀑布流首页
        case agent      // AI Agent
        case profile    // 个人画像
        case wallet     // Web3钱包
    }

    func showErrorAlert(_ message: String) {
        errorMessage = message
        showError = true
    }
}
