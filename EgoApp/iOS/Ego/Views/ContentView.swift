//
//  ContentView.swift
//  Ego
//
//  主视图 - Tab导航结构
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authService: AuthenticationService

    var body: some View {
        Group {
            if authService.isAuthenticated {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .alert("错误", isPresented: $appState.showError) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(appState.errorMessage)
        }
    }
}

// MARK: - 主Tab视图
struct MainTabView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        TabView(selection: $appState.currentTab) {
            // Tab 1: 双瀑布流Feed
            FeedView()
                .tabItem {
                    Label("发现", systemImage: "sparkles")
                }
                .tag(AppState.Tab.feed)

            // Tab 2: AI Agent
            AgentView()
                .tabItem {
                    Label("灵魂", systemImage: "brain.head.profile")
                }
                .tag(AppState.Tab.agent)

            // Tab 3: 个人画像
            ProfileView()
                .tabItem {
                    Label("我", systemImage: "person.circle")
                }
                .tag(AppState.Tab.profile)

            // Tab 4: Web3钱包
            WalletView()
                .tabItem {
                    Label("资产", systemImage: "bitcoinsign.circle")
                }
                .tag(AppState.Tab.wallet)
        }
        .accentColor(.purple)
    }
}

// MARK: - 预览
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
            .environmentObject(AuthenticationService())
            .environmentObject(ProfileService())
    }
}
