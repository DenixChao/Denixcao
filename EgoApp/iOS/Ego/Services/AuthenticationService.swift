//
//  AuthenticationService.swift
//  Ego
//
//  认证服务 - 支持Web3钱包和传统邮箱登录
//

import Foundation
import Combine

@MainActor
class AuthenticationService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var walletAddress: String?

    private let apiClient: APIClient

    init(apiClient: APIClient = APIClient.shared) {
        self.apiClient = apiClient
    }

    // MARK: - 检查认证状态
    func checkAuthStatus() async {
        // 从Keychain读取token
        if let token = KeychainManager.shared.getAuthToken() {
            do {
                currentUser = try await apiClient.getCurrentUser(token: token)
                isAuthenticated = true
            } catch {
                // Token过期，清除
                KeychainManager.shared.deleteAuthToken()
                isAuthenticated = false
            }
        }
    }

    // MARK: - Web3钱包登录
    func connectWallet() async throws {
        // TODO: 集成WalletConnect
        // 1. 连接钱包
        // 2. 请求签名消息
        // 3. 验证签名
        // 4. 获取JWT token

        throw AuthError.notImplemented
    }

    // MARK: - 邮箱登录
    func loginWithEmail(email: String, password: String) async throws {
        let response = try await apiClient.login(email: email, password: password)

        // 保存token
        KeychainManager.shared.saveAuthToken(response.token)

        // 加载用户信息
        currentUser = response.user
        isAuthenticated = true
    }

    // MARK: - 注册
    func register(username: String, email: String, password: String) async throws {
        let response = try await apiClient.register(
            username: username,
            email: email,
            password: password
        )

        KeychainManager.shared.saveAuthToken(response.token)
        currentUser = response.user
        isAuthenticated = true
    }

    // MARK: - 登出
    func logout() {
        KeychainManager.shared.deleteAuthToken()
        currentUser = nil
        walletAddress = nil
        isAuthenticated = false
    }
}

// MARK: - 错误类型
enum AuthError: LocalizedError {
    case notImplemented
    case invalidCredentials
    case networkError
    case walletConnectionFailed

    var errorDescription: String? {
        switch self {
        case .notImplemented:
            return "功能开发中"
        case .invalidCredentials:
            return "用户名或密码错误"
        case .networkError:
            return "网络连接失败"
        case .walletConnectionFailed:
            return "钱包连接失败"
        }
    }
}

// MARK: - Keychain管理器
class KeychainManager {
    static let shared = KeychainManager()

    private let tokenKey = "ego.auth.token"

    func saveAuthToken(_ token: String) {
        // TODO: 使用Keychain安全存储
        UserDefaults.standard.set(token, forKey: tokenKey)
    }

    func getAuthToken() -> String? {
        UserDefaults.standard.string(forKey: tokenKey)
    }

    func deleteAuthToken() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
    }
}
