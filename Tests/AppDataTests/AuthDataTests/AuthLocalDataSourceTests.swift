//
//  AuthLocalDataSourceTests.swift
//  AppDataTests
//
//  Created by jch on 5/10/26.
//

import Foundation
import XCTest
import Keychain
import Persistence
@testable import AppData

/// Auth local data source의 Core 저장소 위임과 오류 매핑을 검증합니다.
final class AuthLocalDataSourceTests: XCTestCase {
    private enum TestFailure: Error {
        case expected
    }

    // MARK: - Tests

    func test_authTokenLocalDataSource_delegatesStoreOperations() async throws {
        // given
        let store = SpyAuthTokenStore()
        let token = AuthTokenRecord.fixture(environment: "local")
        store.stubbedFetchTokenResult = .success(token)
        let sut = AuthTokenLocalDataSource(store: store)

        // when
        let fetchedToken = try await sut.fetchToken(environment: "local")
        try await sut.saveToken(token)
        try await sut.deleteToken(environment: "local")
        try await sut.deleteAllTokens()

        // then
        XCTAssertEqual(fetchedToken, token)
        XCTAssertEqual(store.fetchTokenCallCount, 1)
        XCTAssertEqual(store.saveCallCount, 1)
        XCTAssertEqual(store.deleteCallCount, 1)
        XCTAssertEqual(store.deleteAllCallCount, 1)
        XCTAssertEqual(store.receivedFetchEnvironment, "local")
        XCTAssertEqual(store.receivedToken, token)
        XCTAssertEqual(store.receivedDeleteEnvironment, "local")
    }

    func test_authTokenLocalDataSource_whenStoreThrows_mapsToKeychainFailure() async {
        // given
        let store = SpyAuthTokenStore()
        store.stubbedSaveResult = .failure(TestFailure.expected)
        let sut = AuthTokenLocalDataSource(store: store)

        // when / then
        do {
            try await sut.saveToken(.fixture())
            XCTFail("Expected keychainFailure")
        } catch let error as AuthDataError {
            XCTAssertEqual(error, .keychainFailure)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_authSessionLocalDataSource_delegatesStoreOperations() async throws {
        // given
        let store = SpyAuthSessionStore()
        let session = AuthSessionRecord.fixture(environment: "local")
        store.stubbedFetchSessionResult = .success(session)
        let sut = AuthSessionLocalDataSource(store: store)

        // when
        let fetchedSession = try await sut.fetchSession(environment: "local")
        try await sut.saveSession(session)
        try await sut.deleteSession(environment: "local")
        try await sut.deleteAllSessions()

        // then
        XCTAssertEqual(fetchedSession, session)
        XCTAssertEqual(store.fetchSessionCallCount, 1)
        XCTAssertEqual(store.saveCallCount, 1)
        XCTAssertEqual(store.deleteCallCount, 1)
        XCTAssertEqual(store.deleteAllCallCount, 1)
        XCTAssertEqual(store.receivedFetchEnvironment, "local")
        XCTAssertEqual(store.receivedSession, session)
        XCTAssertEqual(store.receivedDeleteEnvironment, "local")
    }

    func test_authSessionLocalDataSource_whenStoreThrows_mapsToPersistenceFailure() async {
        // given
        let store = SpyAuthSessionStore()
        store.stubbedSaveResult = .failure(TestFailure.expected)
        let sut = AuthSessionLocalDataSource(store: store)

        // when / then
        do {
            try await sut.saveSession(.fixture())
            XCTFail("Expected persistenceFailure")
        } catch let error as AuthDataError {
            XCTAssertEqual(error, .persistenceFailure)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
