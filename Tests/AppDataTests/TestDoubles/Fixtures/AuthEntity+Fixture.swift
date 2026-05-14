//
//  AuthEntity+Fixture.swift
//  AppDataTests
//

import Foundation
import AppDomain

extension AuthenticatedUserEntity {
    static func fixture(
        userId: Int = 1,
        email: String = "test@example.com",
        nickname: String = "jch",
        role: String = "USER",
        status: String = "ACTIVE"
    ) -> AuthenticatedUserEntity {
        AuthenticatedUserEntity(
            userId: userId,
            email: email,
            nickname: nickname,
            role: role,
            status: status
        )
    }
}

extension AuthSessionEntity {
    static func fixture(
        user: AuthenticatedUserEntity = .fixture(),
        token: AuthTokenEntity = .fixture()
    ) -> AuthSessionEntity {
        AuthSessionEntity(token: token, user: user)
    }
}

extension AuthTokenEntity {
    static func fixture(
        accessToken: String = "access-token",
        refreshToken: String = "refresh-token",
        accessTokenExpiresAt: Date = Date(timeIntervalSince1970: 100),
        refreshTokenExpiresAt: Date = Date(timeIntervalSince1970: 200)
    ) -> AuthTokenEntity {
        AuthTokenEntity(
            accessToken: accessToken,
            refreshToken: refreshToken,
            accessTokenExpiresAt: accessTokenExpiresAt,
            refreshTokenExpiresAt: refreshTokenExpiresAt
        )
    }
}

extension SignupUserEntity {
    static func fixture(
        userId: Int = 1,
        email: String = "test@example.com",
        nickname: String = "jch",
        role: String = "USER",
        status: String = "ACTIVE",
        createdAt: Date = Date(timeIntervalSince1970: 0)
    ) -> SignupUserEntity {
        SignupUserEntity(
            userId: userId,
            email: email,
            nickname: nickname,
            role: role,
            status: status,
            createdAt: createdAt
        )
    }
}

extension AuthStoredTokenEntity {
    static func fixture(
        refreshToken: String = "refresh-token",
        accessToken: String? = "access-token",
        accessTokenExpiresAt: Date? = Date(timeIntervalSince1970: 100),
        refreshTokenExpiresAt: Date? = Date(timeIntervalSince1970: 200)
    ) -> AuthStoredTokenEntity {
        AuthStoredTokenEntity(
            refreshToken: refreshToken,
            accessToken: accessToken,
            accessTokenExpiresAt: accessTokenExpiresAt,
            refreshTokenExpiresAt: refreshTokenExpiresAt
        )
    }
}
