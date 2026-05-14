//
//  SpyAuthTokenLocalDataSource.swift
//  AppDataTests
//

import Foundation
import Keychain
@testable import AppData

/// AuthTokenLocalDataSource 호출 횟수와 전달 인자를 기록하는 Spy입니다.
final class SpyAuthTokenLocalDataSource: AuthTokenLocalDataSourceProtocol, @unchecked Sendable {
    var fetchTokenCallCount = 0
    var saveTokenCallCount = 0
    var deleteTokenCallCount = 0
    var deleteAllTokensCallCount = 0

    var receivedFetchEnvironment: String?
    var receivedToken: AuthTokenRecord?
    var receivedDeleteEnvironment: String?

    var stubbedFetchTokenResult: Result<AuthTokenRecord?, Error> = .success(nil)
    var stubbedSaveTokenResult: Result<Void, Error> = .success(())
    var stubbedDeleteTokenResult: Result<Void, Error> = .success(())
    var stubbedDeleteAllTokensResult: Result<Void, Error> = .success(())

    func fetchToken(environment: String) async throws -> AuthTokenRecord? {
        fetchTokenCallCount += 1
        receivedFetchEnvironment = environment
        return try stubbedFetchTokenResult.get()
    }

    func saveToken(_ token: AuthTokenRecord) async throws {
        saveTokenCallCount += 1
        receivedToken = token
        try stubbedSaveTokenResult.get()
    }

    func deleteToken(environment: String) async throws {
        deleteTokenCallCount += 1
        receivedDeleteEnvironment = environment
        try stubbedDeleteTokenResult.get()
    }

    func deleteAllTokens() async throws {
        deleteAllTokensCallCount += 1
        try stubbedDeleteAllTokensResult.get()
    }
}
