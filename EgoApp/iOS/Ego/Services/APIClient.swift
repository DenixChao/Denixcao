//
//  APIClient.swift
//  Ego
//
//  统一的API客户端
//

import Foundation

class APIClient {
    static let shared = APIClient()

    private let baseURL: URL
    private let session: URLSession

    init(baseURL: String = "https://api.ego.app") {
        self.baseURL = URL(string: baseURL)!
        self.session = URLSession.shared
    }

    // MARK: - 通用请求方法
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get,
        queryParams: [String: String]? = nil,
        body: Encodable? = nil
    ) async throws -> T {
        var urlComponents = URLComponents(url: baseURL.appendingPathComponent(endpoint), resolvingAgainstBaseURL: false)!

        // 添加查询参数
        if let queryParams = queryParams {
            urlComponents.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // 添加认证token
        if let token = KeychainManager.shared.getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // 添加请求体
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
    }

    // MARK: - 认证相关
    func login(email: String, password: String) async throws -> AuthResponse {
        try await request(
            endpoint: "/auth/login",
            method: .post,
            body: ["email": email, "password": password]
        )
    }

    func register(username: String, email: String, password: String) async throws -> AuthResponse {
        try await request(
            endpoint: "/auth/register",
            method: .post,
            body: [
                "username": username,
                "email": email,
                "password": password
            ]
        )
    }

    func getCurrentUser(token: String) async throws -> User {
        try await request(endpoint: "/auth/me", method: .get)
    }

    // MARK: - 用户画像
    func getUserProfile() async throws -> UserProfile {
        try await request(endpoint: "/profile", method: .get)
    }

    func addKeyEvent(_ event: KeyEvent) async throws -> UserProfile {
        try await request(
            endpoint: "/profile/events",
            method: .post,
            body: event
        )
    }

    func updatePersonalityTraits(_ traits: [PersonalityTrait]) async throws -> UserProfile {
        try await request(
            endpoint: "/profile/personality",
            method: .put,
            body: ["traits": traits]
        )
    }

    func addSkill(_ skill: Skill) async throws -> UserProfile {
        try await request(
            endpoint: "/profile/skills",
            method: .post,
            body: skill
        )
    }

    func addInterest(_ interest: Interest) async throws -> UserProfile {
        try await request(
            endpoint: "/profile/interests",
            method: .post,
            body: interest
        )
    }

    func addQuirk(_ quirk: Quirk) async throws -> UserProfile {
        try await request(
            endpoint: "/profile/quirks",
            method: .post,
            body: quirk
        )
    }

    func updateUserEmbedding() async throws {
        let _: EmptyResponse = try await request(
            endpoint: "/profile/update-embedding",
            method: .post
        )
    }

    // MARK: - Web3
    func mintDataAssetNFT() async throws -> String {
        let response: NFTMintResponse = try await request(
            endpoint: "/web3/mint-data-asset",
            method: .post
        )
        return response.tokenId
    }
}

// MARK: - 辅助类型
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的URL"
        case .invalidResponse:
            return "无效的响应"
        case .httpError(let statusCode):
            return "HTTP错误: \(statusCode)"
        case .decodingError:
            return "数据解析失败"
        }
    }
}

struct AuthResponse: Codable {
    let token: String
    let user: User
}

struct EmptyResponse: Codable {}

struct NFTMintResponse: Codable {
    let tokenId: String
    let transactionHash: String
}
