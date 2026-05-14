//
//  SpyAuthTokenStore.swift
//  AppDataTests
//

import Foundation
import Keychain

/// AuthTokenStore 호출 횟수와 전달 인자를 기록하는 Spy입니다.
final class SpyAuthTokenStore: AuthTokenStoreProtocol, @unchecked Sendable {
    var fetchTokenCallCount = 0
    var saveCallCount = 0
    var deleteCallCount = 0
    var deleteAllCallCount = 0

    var receivedFetchEnvironment: String?
    var receivedToken: AuthTokenRecord?
    var receivedDeleteEnvironment: String?

    var stubbedFetchTokenResult: Result<AuthTokenRecord?, Error> = .success(nil)
    var stubbedSaveResult: Result<Void, Error> = .success(())
    var stubbedDeleteResult: Result<Void, Error> = .success(())
    var stubbedDeleteAllResult: Result<Void, Error> = .success(())

    func fetchToken(for environment: String) async throws -> AuthTokenRecord? {
        fetchTokenCallCount += 1
        receivedFetchEnvironment = environment
        return try stubbedFetchTokenResult.get()
    }

    func save(_ token: AuthTokenRecord) async throws {
        saveCallCount += 1
        receivedToken = token
        try stubbedSaveResult.get()
    }

    func delete(environment: String) async throws {
        deleteCallCount += 1
        receivedDeleteEnvironment = environment
        try stubbedDeleteResult.get()
    }

    func deleteAll() async throws {
        deleteAllCallCount += 1
        try stubbedDeleteAllResult.get()
    }
}
