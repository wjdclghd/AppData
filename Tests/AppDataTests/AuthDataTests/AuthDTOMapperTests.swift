//
//  AuthDTOMapperTests.swift
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

/// AuthDTOMapper의 Domain Entity와 Core Record 변환을 검증합니다.
final class AuthDTOMapperTests: XCTestCase {

    // MARK: - Tests

    func test_toSignupUserEntity_mapsAllFieldsAndISODate() throws {
        // given
        let dto = SignupResponseDTO.fixture(
            userId: 10,
            email: "user@example.com",
            nickname: "tester",
            role: "USER",
            status: "ACTIVE",
            createdAt: "2026-05-10T09:00:00Z"
        )

        // when
        let entity = try AuthDTOMapper.toSignupUserEntity(from: dto)

        // then
        XCTAssertEqual(entity.userId, 10)
        XCTAssertEqual(entity.email, "user@example.com")
        XCTAssertEqual(entity.nickname, "tester")
        XCTAssertEqual(entity.role, "USER")
        XCTAssertEqual(entity.status, "ACTIVE")
        XCTAssertEqual(entity.createdAt, try date("2026-05-10T09:00:00Z"))
    }

    func test_toAuthSessionEntity_mapsTokenAndUser() throws {
        // given
        let dto = AuthSessionResponseDTO.fixture(
            token: .fixture(
                accessToken: "access-token",
                refreshToken: "refresh-token",
                accessTokenExpiresAt: "2026-05-10T09:15:00Z",
                refreshTokenExpiresAt: "2026-05-24T09:00:00Z"
            ),
            user: .fixture(
                userId: 20,
                email: "login@example.com",
                nickname: "login",
                role: "ADMIN",
                status: "ACTIVE"
            )
        )

        // when
        let entity = try AuthDTOMapper.toAuthSessionEntity(from: dto)

        // then
        XCTAssertEqual(entity.token.accessToken, "access-token")
        XCTAssertEqual(entity.token.refreshToken, "refresh-token")
        XCTAssertEqual(entity.token.accessTokenExpiresAt, try date("2026-05-10T09:15:00Z"))
        XCTAssertEqual(entity.token.refreshTokenExpiresAt, try date("2026-05-24T09:00:00Z"))
        XCTAssertEqual(entity.user.userId, 20)
        XCTAssertEqual(entity.user.email, "login@example.com")
        XCTAssertEqual(entity.user.nickname, "login")
        XCTAssertEqual(entity.user.role, "ADMIN")
        XCTAssertEqual(entity.user.status, "ACTIVE")
    }

    func test_toAuthTokenRecord_mapsDomainToken() throws {
        // given
        let session = try AuthDTOMapper.toAuthSessionEntity(from: .fixture())
        let updatedAt = Date(timeIntervalSince1970: 300)

        // when
        let record = AuthDTOMapper.toAuthTokenRecord(
            from: session.token,
            environment: "local",
            updatedAt: updatedAt
        )

        // then
        XCTAssertEqual(record.environment, "local")
        XCTAssertEqual(record.accessToken, "access-token")
        XCTAssertEqual(record.refreshToken, "refresh-token")
        XCTAssertEqual(record.updatedAt, updatedAt)
    }

    func test_toAuthSessionRecord_mapsDomainUser() throws {
        // given
        let session = try AuthDTOMapper.toAuthSessionEntity(from: .fixture(user: .fixture(userId: 30)))
        let refreshedAt = Date(timeIntervalSince1970: 400)

        // when
        let record = AuthDTOMapper.toAuthSessionRecord(
            from: session.user,
            environment: "local",
            lastRefreshedAt: refreshedAt
        )

        // then
        XCTAssertEqual(record.environment, "local")
        XCTAssertEqual(record.userID, 30)
        XCTAssertEqual(record.email, "test@example.com")
        XCTAssertEqual(record.nickname, "jch")
        XCTAssertEqual(record.isLoggedIn, true)
        XCTAssertEqual(record.lastRefreshedAt, refreshedAt)
    }

    func test_toSignupUserEntity_whenDateInvalid_throwsDecodingFailure() {
        // given
        let dto = SignupResponseDTO.fixture(createdAt: "invalid-date")

        // when / then
        XCTAssertThrowsError(try AuthDTOMapper.toSignupUserEntity(from: dto)) { error in
            XCTAssertEqual(error as? AuthDataError, .decodingFailure)
        }
    }
}

// MARK: - Helpers

private extension AuthDTOMapperTests {
    func date(_ value: String) throws -> Date {
        let formatter = ISO8601DateFormatter()
        return try XCTUnwrap(formatter.date(from: value))
    }
}
