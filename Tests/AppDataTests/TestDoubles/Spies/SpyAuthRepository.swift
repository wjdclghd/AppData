//
//  SpyAuthRepository.swift
//  AppDataTests
//

import Foundation
import AppDomain

/// AuthRepositoryProtocol 호출 횟수, 전달 인자, 반환값을 제어하는 Spy입니다.
final class SpyAuthRepository: AuthRepositoryProtocol, @unchecked Sendable {

    // MARK: - Call Counts

    var fetchStoredTokenCallCount = 0
    var fetchStoredSessionCallCount = 0
    var clearLocalSessionCallCount = 0
    var requestLogoutCallCount = 0
    var refreshAuthTokenCallCount = 0
    var loginCallCount = 0
    var signupCallCount = 0

    // MARK: - Received Arguments

    var receivedRequestLogoutRefreshToken: String?
    var receivedRefreshAuthTokenRefreshToken: String?

    // MARK: - Stubs

    var stubbedFetchStoredTokenResult: Result<AuthStoredTokenEntity?, Error> = .success(nil)
    var stubbedFetchStoredSessionResult: Result<AuthenticatedUserEntity?, Error> = .success(nil)
    var stubbedClearLocalSessionResult: Result<Void, Error> = .success(())
    var stubbedRequestLogoutResult: Result<Void, Error> = .success(())
    var stubbedRefreshAuthTokenResult: Result<AuthSessionEntity, Error> = .success(.fixture())
    var stubbedLoginResult: Result<AuthSessionEntity, Error> = .success(.fixture())
    var stubbedSignupResult: Result<SignupUserEntity, Error> = .success(.fixture())

    // MARK: - Protocol

    func fetchStoredToken() async throws -> AuthStoredTokenEntity? {
        fetchStoredTokenCallCount += 1
        return try stubbedFetchStoredTokenResult.get()
    }

    func fetchStoredSession() async throws -> AuthenticatedUserEntity? {
        fetchStoredSessionCallCount += 1
        return try stubbedFetchStoredSessionResult.get()
    }

    func clearLocalSession() async throws {
        clearLocalSessionCallCount += 1
        try stubbedClearLocalSessionResult.get()
    }

    func requestLogout(refreshToken: String) async throws {
        requestLogoutCallCount += 1
        receivedRequestLogoutRefreshToken = refreshToken
        try stubbedRequestLogoutResult.get()
    }

    func refreshAuthToken(refreshToken: String) async throws -> AuthSessionEntity {
        refreshAuthTokenCallCount += 1
        receivedRefreshAuthTokenRefreshToken = refreshToken
        return try stubbedRefreshAuthTokenResult.get()
    }

    func login(email: String, password: String) async throws -> AuthSessionEntity {
        loginCallCount += 1
        return try stubbedLoginResult.get()
    }

    func signup(email: String, password: String, nickname: String) async throws -> SignupUserEntity {
        signupCallCount += 1
        return try stubbedSignupResult.get()
    }
}
