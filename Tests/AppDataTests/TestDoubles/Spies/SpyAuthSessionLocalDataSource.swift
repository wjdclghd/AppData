//
//  SpyAuthSessionLocalDataSource.swift
//  AppDataTests
//

import Foundation
import Persistence
@testable import AppData

/// AuthSessionLocalDataSource 호출 횟수와 전달 인자를 기록하는 Spy입니다.
final class SpyAuthSessionLocalDataSource: AuthSessionLocalDataSourceProtocol, @unchecked Sendable {
    var fetchSessionCallCount = 0
    var saveSessionCallCount = 0
    var deleteSessionCallCount = 0
    var deleteAllSessionsCallCount = 0

    var receivedFetchEnvironment: String?
    var receivedSession: AuthSessionRecord?
    var receivedDeleteEnvironment: String?

    var stubbedFetchSessionResult: Result<AuthSessionRecord?, Error> = .success(nil)
    var stubbedSaveSessionResult: Result<Void, Error> = .success(())
    var stubbedDeleteSessionResult: Result<Void, Error> = .success(())
    var stubbedDeleteAllSessionsResult: Result<Void, Error> = .success(())

    func fetchSession(environment: String) async throws -> AuthSessionRecord? {
        fetchSessionCallCount += 1
        receivedFetchEnvironment = environment
        return try stubbedFetchSessionResult.get()
    }

    func saveSession(_ session: AuthSessionRecord) async throws {
        saveSessionCallCount += 1
        receivedSession = session
        try stubbedSaveSessionResult.get()
    }

    func deleteSession(environment: String) async throws {
        deleteSessionCallCount += 1
        receivedDeleteEnvironment = environment
        try stubbedDeleteSessionResult.get()
    }

    func deleteAllSessions() async throws {
        deleteAllSessionsCallCount += 1
        try stubbedDeleteAllSessionsResult.get()
    }
}
