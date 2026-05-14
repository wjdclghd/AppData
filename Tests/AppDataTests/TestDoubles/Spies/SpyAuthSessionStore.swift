//
//  SpyAuthSessionStore.swift
//  AppDataTests
//

import Foundation
import Persistence

/// AuthSessionStore 호출 횟수와 전달 인자를 기록하는 Spy입니다.
final class SpyAuthSessionStore: AuthSessionStoreProtocol, @unchecked Sendable {
    var fetchAllCallCount = 0
    var fetchSessionCallCount = 0
    var saveCallCount = 0
    var deleteCallCount = 0
    var deleteAllCallCount = 0

    var receivedFetchEnvironment: String?
    var receivedSession: AuthSessionRecord?
    var receivedDeleteEnvironment: String?

    var stubbedFetchAllResult: Result<[AuthSessionRecord], Error> = .success([])
    var stubbedFetchSessionResult: Result<AuthSessionRecord?, Error> = .success(nil)
    var stubbedSaveResult: Result<Void, Error> = .success(())
    var stubbedDeleteResult: Result<Void, Error> = .success(())
    var stubbedDeleteAllResult: Result<Void, Error> = .success(())

    func fetchAll() async throws -> [AuthSessionRecord] {
        fetchAllCallCount += 1
        return try stubbedFetchAllResult.get()
    }

    func fetchSession(for environment: String) async throws -> AuthSessionRecord? {
        fetchSessionCallCount += 1
        receivedFetchEnvironment = environment
        return try stubbedFetchSessionResult.get()
    }

    func save(_ session: AuthSessionRecord) async throws {
        saveCallCount += 1
        receivedSession = session
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
