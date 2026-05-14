//
//  AuthResponseDTO+Fixture.swift
//  AppDataTests
//

import Foundation
@testable import AppData

extension SignupResponseDTO {
    static func fixture(
        userId: Int = 1,
        email: String = "test@example.com",
        nickname: String = "jch",
        role: String = "USER",
        status: String = "ACTIVE",
        createdAt: String = "2026-05-10T09:00:00Z"
    ) -> SignupResponseDTO {
        SignupResponseDTO(
            userId: userId,
            email: email,
            nickname: nickname,
            role: role,
            status: status,
            createdAt: createdAt
        )
    }
}

extension AuthSessionResponseDTO {
    static func fixture(
        token: AuthTokenResponseDTO = .fixture(),
        user: AuthUserResponseDTO = .fixture()
    ) -> AuthSessionResponseDTO {
        AuthSessionResponseDTO(token: token, user: user)
    }
}

extension AuthTokenResponseDTO {
    static func fixture(
        accessToken: String = "access-token",
        refreshToken: String = "refresh-token",
        accessTokenExpiresAt: String = "2026-05-10T09:15:00Z",
        refreshTokenExpiresAt: String = "2026-05-24T09:00:00Z"
    ) -> AuthTokenResponseDTO {
        AuthTokenResponseDTO(
            accessToken: accessToken,
            refreshToken: refreshToken,
            accessTokenExpiresAt: accessTokenExpiresAt,
            refreshTokenExpiresAt: refreshTokenExpiresAt
        )
    }
}

extension AuthUserResponseDTO {
    static func fixture(
        userId: Int = 1,
        email: String = "test@example.com",
        nickname: String = "jch",
        role: String = "USER",
        status: String = "ACTIVE"
    ) -> AuthUserResponseDTO {
        AuthUserResponseDTO(
            userId: userId,
            email: email,
            nickname: nickname,
            role: role,
            status: status
        )
    }
}
