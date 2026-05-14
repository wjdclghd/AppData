//
//  AuthRemoteDataSource.swift
//  AppData
//
//  Created by jch on 5/10/26.
//

import Foundation
import Networking

/// Networking 클라이언트로 Auth API를 호출합니다.
public struct AuthRemoteDataSource<NetworkClient: NetworkClientProtocol>: AuthRemoteDataSourceProtocol, Sendable {
    private let networkClient: NetworkClient
    private let baseURL: URL

    /// AuthRemoteDataSource를 생성합니다.
    ///
    /// - Parameters:
    ///   - networkClient: 원격 요청을 수행할 Networking 모듈의 클라이언트입니다.
    ///   - baseURL: Auth API 서버 기준 URL입니다. App Target의 `AppEnvironment.authBaseURL`에서 주입합니다.
    public init(
        networkClient: NetworkClient,
        baseURL: URL
    ) {
        self.networkClient = networkClient
        self.baseURL = baseURL
    }

    /// 회원가입 응답을 조회합니다.
    public func signup(
        email: String,
        password: String,
        nickname: String
    ) async throws -> SignupResponseDTO {
        let endpoint = AuthEndpoint.signup(
            SignupRequestDTO(
                email: email,
                password: password,
                nickname: nickname
            ),
            baseURL: baseURL
        )
        return try await request(endpoint: endpoint, as: SignupResponseDTO.self, operation: .signup)
    }

    /// 로그인 응답을 조회합니다.
    public func login(
        email: String,
        password: String
    ) async throws -> AuthSessionResponseDTO {
        let endpoint = AuthEndpoint.login(
            LoginRequestDTO(
                email: email,
                password: password
            ),
            baseURL: baseURL
        )
        return try await request(endpoint: endpoint, as: AuthSessionResponseDTO.self, operation: .login)
    }

    /// 토큰 재발급 응답을 조회합니다.
    public func refreshAuthToken(refreshToken: String) async throws -> AuthSessionResponseDTO {
        let endpoint = AuthEndpoint.refresh(
            RefreshAuthTokenRequestDTO(refreshToken: refreshToken),
            baseURL: baseURL
        )
        return try await request(endpoint: endpoint, as: AuthSessionResponseDTO.self, operation: .refresh)
    }

    /// 로그아웃 API를 호출합니다.
    public func logout(refreshToken: String) async throws {
        let endpoint = AuthEndpoint.logout(
            LogoutRequestDTO(refreshToken: refreshToken),
            baseURL: baseURL
        )

        do {
            _ = try await networkClient.request(endpoint)
        } catch let error as AuthDataError {
            throw error
        } catch let error as NetworkError {
            throw AuthDataErrorMapper.toDataError(from: error, operation: .logout)
        } catch {
            throw AuthDataError.remoteFailure
        }
    }
}

private extension AuthRemoteDataSource {
    func request<Response: Decodable & Sendable>(
        endpoint: Endpoint,
        as responseType: Response.Type,
        operation: AuthRemoteOperation
    ) async throws -> Response {
        do {
            return try await networkClient.request(endpoint, as: responseType)
        } catch let error as AuthDataError {
            throw error
        } catch let error as NetworkError {
            throw AuthDataErrorMapper.toDataError(from: error, operation: operation)
        } catch {
            throw AuthDataError.remoteFailure
        }
    }
}
