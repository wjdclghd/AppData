//
//  AuthRecord+Fixture.swift
//  AppDataTests
//

import Foundation
import Keychain
import Persistence

extension AuthTokenRecord {
    static func fixture(
        environment: String = "local",
        accessToken: String? = "access-token",
        refreshToken: String = "refresh-token",
        accessTokenExpiresAt: Date? = Date(timeIntervalSince1970: 100),
        refreshTokenExpiresAt: Date? = Date(timeIntervalSince1970: 200),
        updatedAt: Date = Date(timeIntervalSince1970: 300)
    ) -> AuthTokenRecord {
        AuthTokenRecord(
            environment: environment,
            accessToken: accessToken,
            refreshToken: refreshToken,
            accessTokenExpiresAt: accessTokenExpiresAt,
            refreshTokenExpiresAt: refreshTokenExpiresAt,
            updatedAt: updatedAt
        )
    }
}

extension AuthSessionRecord {
    static func fixture(
        environment: String = "local",
        userID: Int64 = 1,
        email: String = "test@example.com",
        nickname: String = "jch",
        role: String = "USER",
        status: String = "ACTIVE",
        isLoggedIn: Bool = true,
        lastRefreshedAt: Date = Date(timeIntervalSince1970: 300)
    ) -> AuthSessionRecord {
        AuthSessionRecord(
            environment: environment,
            userID: userID,
            email: email,
            nickname: nickname,
            role: role,
            status: status,
            isLoggedIn: isLoggedIn,
            lastRefreshedAt: lastRefreshedAt
        )
    }
}
