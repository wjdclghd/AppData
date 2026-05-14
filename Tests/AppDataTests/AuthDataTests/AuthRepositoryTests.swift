//
//  AuthRepositoryTests.swift
//  AppDataTests
//
//  Created by jch on 5/10/26.
//

import Foundation
import XCTest
import AppDomain
import Keychain
import Persistence
@testable import AppData

/// AuthRepository의 Domain 계약, 로컬 저장 정책, 오류 변환을 검증합니다.
final class AuthRepositoryTests: XCTestCase {
    private enum TestFailure: Error {
        case expected
    }

    // MARK: - Properties

    private var sut: AuthRepository<
        SpyAuthRemoteDataSource,
        SpyAuthTokenLocalDataSource,
        SpyAuthSessionLocalDataSource
    >!
    private var remoteDataSource: SpyAuthRemoteDataSource!
    private var tokenLocalDataSource: SpyAuthTokenLocalDataSource!
    private var sessionLocalDataSource: SpyAuthSessionLocalDataSource!
    private var now: Date!

    // MARK: - Setup

    override func setUpWithError() throws {
        try super.setUpWithError()
        remoteDataSource = SpyAuthRemoteDataSource()
        tokenLocalDataSource = SpyAuthTokenLocalDataSource()
        sessionLocalDataSource = SpyAuthSessionLocalDataSource()
        now = Date(timeIntervalSince1970: 300)
        sut = AuthRepository(
            remoteDataSource: remoteDataSource,
            tokenLocalDataSource: tokenLocalDataSource,
            sessionLocalDataSource: sessionLocalDataSource,
            environment: "local",
            now: { [now] in now! }
        )
    }

    override func tearDownWithError() throws {
        sut = nil
        remoteDataSource = nil
        tokenLocalDataSource = nil
        sessionLocalDataSource = nil
        now = nil
        try super.tearDownWithError()
    }

    // MARK: - Tests

    func test_signup_whenRemoteSucceeds_returnsMappedUserAndDoesNotSaveLocalData() async throws {
        // given
        remoteDataSource.stubbedSignupResult = .success(.fixture(userId: 10))

        // when
        let user = try await sut.signup(
            email: "test@example.com",
            password: "password123",
            nickname: "jch"
        )

        // then
        XCTAssertEqual(user.userId, 10)
        XCTAssertEqual(remoteDataSource.signupCallCount, 1)
        XCTAssertEqual(tokenLocalDataSource.saveTokenCallCount, 0)
        XCTAssertEqual(sessionLocalDataSource.saveSessionCallCount, 0)
    }

    func test_signup_whenDuplicateEmail_mapsToDomainDuplicateEmail() async {
        // given
        remoteDataSource.stubbedSignupResult = .failure(AuthDataError.duplicateEmail)

        // when / then
        await assertThrowsAuthDomainError(.duplicateEmail) {
            _ = try await sut.signup(
                email: "test@example.com",
                password: "password123",
                nickname: "jch"
            )
        }
    }

    func test_login_whenRemoteSucceeds_savesTokenThenSessionAndReturnsSession() async throws {
        // given
        remoteDataSource.stubbedLoginResult = .success(
            .fixture(
                token: .fixture(accessToken: "new-access-token", refreshToken: "new-refresh-token"),
                user: .fixture(userId: 20)
            )
        )

        // when
        let session = try await sut.login(email: "test@example.com", password: "password123")

        // then
        XCTAssertEqual(session.token.accessToken, "new-access-token")
        XCTAssertEqual(session.token.refreshToken, "new-refresh-token")
        XCTAssertEqual(session.user.userId, 20)
        XCTAssertEqual(remoteDataSource.loginCallCount, 1)
        XCTAssertEqual(tokenLocalDataSource.saveTokenCallCount, 1)
        XCTAssertEqual(sessionLocalDataSource.saveSessionCallCount, 1)
        XCTAssertEqual(tokenLocalDataSource.receivedToken?.environment, "local")
        XCTAssertEqual(tokenLocalDataSource.receivedToken?.accessToken, "new-access-token")
        XCTAssertEqual(tokenLocalDataSource.receivedToken?.refreshToken, "new-refresh-token")
        XCTAssertEqual(tokenLocalDataSource.receivedToken?.updatedAt, now)
        XCTAssertEqual(sessionLocalDataSource.receivedSession?.environment, "local")
        XCTAssertEqual(sessionLocalDataSource.receivedSession?.userID, 20)
        XCTAssertEqual(sessionLocalDataSource.receivedSession?.lastRefreshedAt, now)
    }

    func test_login_whenTokenSaveFails_doesNotSaveSessionAndThrowsTemporarilyUnavailable() async {
        // given
        tokenLocalDataSource.stubbedSaveTokenResult = .failure(TestFailure.expected)

        // when / then
        await assertThrowsAuthDomainError(.temporarilyUnavailable) {
            _ = try await sut.login(email: "test@example.com", password: "password123")
        }
        XCTAssertEqual(tokenLocalDataSource.saveTokenCallCount, 1)
        XCTAssertEqual(sessionLocalDataSource.saveSessionCallCount, 0)
        XCTAssertEqual(tokenLocalDataSource.deleteTokenCallCount, 0)
    }

    func test_login_whenSessionSaveFails_deletesSavedTokenAndThrowsTemporarilyUnavailable() async {
        // given
        sessionLocalDataSource.stubbedSaveSessionResult = .failure(TestFailure.expected)

        // when / then
        await assertThrowsAuthDomainError(.temporarilyUnavailable) {
            _ = try await sut.login(email: "test@example.com", password: "password123")
        }
        XCTAssertEqual(tokenLocalDataSource.saveTokenCallCount, 1)
        XCTAssertEqual(sessionLocalDataSource.saveSessionCallCount, 1)
        XCTAssertEqual(tokenLocalDataSource.deleteTokenCallCount, 1)
        XCTAssertEqual(tokenLocalDataSource.receivedDeleteEnvironment, "local")
    }

    func test_refreshAuthToken_whenRemoteSucceeds_replacesTokenAndSession() async throws {
        // given
        remoteDataSource.stubbedRefreshAuthTokenResult = .success(
            .fixture(token: .fixture(accessToken: "rotated-access", refreshToken: "rotated-refresh"))
        )

        // when
        let session = try await sut.refreshAuthToken(refreshToken: "old-refresh")

        // then
        XCTAssertEqual(session.token.accessToken, "rotated-access")
        XCTAssertEqual(session.token.refreshToken, "rotated-refresh")
        XCTAssertEqual(remoteDataSource.receivedRefreshToken, "old-refresh")
        XCTAssertEqual(tokenLocalDataSource.receivedToken?.refreshToken, "rotated-refresh")
        XCTAssertEqual(sessionLocalDataSource.saveSessionCallCount, 1)
    }

    func test_refreshAuthToken_whenInvalidRefreshToken_clearsLocalDataAndThrowsInvalidRefreshToken() async {
        // given
        remoteDataSource.stubbedRefreshAuthTokenResult = .failure(AuthDataError.invalidRefreshToken)

        // when / then
        await assertThrowsAuthDomainError(.invalidRefreshToken) {
            _ = try await sut.refreshAuthToken(refreshToken: "expired-refresh")
        }
        XCTAssertEqual(tokenLocalDataSource.deleteTokenCallCount, 1)
        XCTAssertEqual(sessionLocalDataSource.deleteSessionCallCount, 1)
    }

    func test_refreshAuthToken_whenTemporaryFailure_doesNotClearLocalData() async {
        // given
        remoteDataSource.stubbedRefreshAuthTokenResult = .failure(AuthDataError.remoteFailure)

        // when / then
        await assertThrowsAuthDomainError(.temporarilyUnavailable) {
            _ = try await sut.refreshAuthToken(refreshToken: "refresh-token")
        }
        XCTAssertEqual(tokenLocalDataSource.deleteTokenCallCount, 0)
        XCTAssertEqual(sessionLocalDataSource.deleteSessionCallCount, 0)
    }

}

// MARK: - Helpers

private extension AuthRepositoryTests {
    func assertThrowsAuthDomainError(
        _ expectedError: AuthDomainError,
        operation: () async throws -> Void
    ) async {
        do {
            try await operation()
            XCTFail("Expected \(expectedError)")
        } catch let error as AuthDomainError {
            XCTAssertEqual(error, expectedError)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
