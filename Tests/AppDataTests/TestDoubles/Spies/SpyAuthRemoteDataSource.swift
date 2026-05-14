//
//  SpyAuthRemoteDataSource.swift
//  AppDataTests
//

import Foundation
@testable import AppData

/// AuthRemoteDataSource 호출 횟수와 전달 인자를 기록하는 Spy입니다.
final class SpyAuthRemoteDataSource: AuthRemoteDataSourceProtocol, @unchecked Sendable {
    var signupCallCount = 0
    var loginCallCount = 0
    var refreshAuthTokenCallCount = 0
    var logoutCallCount = 0

    var receivedSignupEmail: String?
    var receivedSignupPassword: String?
    var receivedSignupNickname: String?
    var receivedLoginEmail: String?
    var receivedLoginPassword: String?
    var receivedRefreshToken: String?
    var receivedLogoutRefreshToken: String?

    var stubbedSignupResult: Result<SignupResponseDTO, Error> = .success(.fixture())
    var stubbedLoginResult: Result<AuthSessionResponseDTO, Error> = .success(.fixture())
    var stubbedRefreshAuthTokenResult: Result<AuthSessionResponseDTO, Error> = .success(.fixture())
    var stubbedLogoutResult: Result<Void, Error> = .success(())

    func signup(
        email: String,
        password: String,
        nickname: String
    ) async throws -> SignupResponseDTO {
        signupCallCount += 1
        receivedSignupEmail = email
        receivedSignupPassword = password
        receivedSignupNickname = nickname
        return try stubbedSignupResult.get()
    }

    func login(
        email: String,
        password: String
    ) async throws -> AuthSessionResponseDTO {
        loginCallCount += 1
        receivedLoginEmail = email
        receivedLoginPassword = password
        return try stubbedLoginResult.get()
    }

    func refreshAuthToken(refreshToken: String) async throws -> AuthSessionResponseDTO {
        refreshAuthTokenCallCount += 1
        receivedRefreshToken = refreshToken
        return try stubbedRefreshAuthTokenResult.get()
    }

    func logout(refreshToken: String) async throws {
        logoutCallCount += 1
        receivedLogoutRefreshToken = refreshToken
        try stubbedLogoutResult.get()
    }
}
