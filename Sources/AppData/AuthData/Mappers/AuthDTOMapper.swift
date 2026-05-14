//
//  AuthDTOMapper.swift
//  AppData
//
//  Created by jch on 5/10/26.
//

import Foundation
import AppDomain
import Keychain
import Persistence

/// Auth DTO와 Record를 Domain Entity로 변환합니다.
enum AuthDTOMapper {
    /// 회원가입 응답 DTO를 Domain Entity로 변환합니다.
    ///
    /// - Parameter dto: 회원가입 응답 DTO입니다.
    /// - Returns: `SignupUserEntity`입니다.
    /// - Throws: 날짜 형식이 올바르지 않으면 `AuthDataError.decodingFailure`를 던집니다.
    static func toSignupUserEntity(from dto: SignupResponseDTO) throws -> SignupUserEntity {
        SignupUserEntity(
            userId: dto.userId,
            email: dto.email,
            nickname: dto.nickname,
            role: dto.role,
            status: dto.status,
            createdAt: try parseDate(dto.createdAt)
        )
    }

    /// 인증 세션 응답 DTO를 Domain Entity로 변환합니다.
    ///
    /// - Parameter dto: 로그인 또는 토큰 재발급 응답 DTO입니다.
    /// - Returns: `AuthSessionEntity`입니다.
    /// - Throws: 날짜 형식이 올바르지 않으면 `AuthDataError.decodingFailure`를 던집니다.
    static func toAuthSessionEntity(from dto: AuthSessionResponseDTO) throws -> AuthSessionEntity {
        AuthSessionEntity(
            token: try toAuthTokenEntity(from: dto.token),
            user: toAuthenticatedUserEntity(from: dto.user)
        )
    }

    /// Domain token을 Keychain record로 변환합니다.
    ///
    /// - Parameters:
    ///   - entity: Domain token entity입니다.
    ///   - environment: 저장 환경 식별자입니다.
    ///   - updatedAt: token 저장 시각입니다.
    /// - Returns: `AuthTokenRecord`입니다.
    static func toAuthTokenRecord(
        from entity: AuthTokenEntity,
        environment: String,
        updatedAt: Date
    ) -> AuthTokenRecord {
        AuthTokenRecord(
            environment: environment,
            accessToken: entity.accessToken,
            refreshToken: entity.refreshToken,
            accessTokenExpiresAt: entity.accessTokenExpiresAt,
            refreshTokenExpiresAt: entity.refreshTokenExpiresAt,
            updatedAt: updatedAt
        )
    }

    /// Domain user를 Persistence record로 변환합니다.
    ///
    /// - Parameters:
    ///   - entity: 인증 사용자 entity입니다.
    ///   - environment: 저장 환경 식별자입니다.
    ///   - lastRefreshedAt: session 갱신 시각입니다.
    /// - Returns: `AuthSessionRecord`입니다.
    static func toAuthSessionRecord(
        from entity: AuthenticatedUserEntity,
        environment: String,
        lastRefreshedAt: Date
    ) -> AuthSessionRecord {
        AuthSessionRecord(
            environment: environment,
            userID: Int64(entity.userId),
            email: entity.email,
            nickname: entity.nickname,
            role: entity.role,
            status: entity.status,
            isLoggedIn: true,
            lastRefreshedAt: lastRefreshedAt
        )
    }
}

private extension AuthDTOMapper {
    static func toAuthTokenEntity(from dto: AuthTokenResponseDTO) throws -> AuthTokenEntity {
        AuthTokenEntity(
            accessToken: dto.accessToken,
            refreshToken: dto.refreshToken,
            accessTokenExpiresAt: try parseDate(dto.accessTokenExpiresAt),
            refreshTokenExpiresAt: try parseDate(dto.refreshTokenExpiresAt)
        )
    }

    static func toAuthenticatedUserEntity(from dto: AuthUserResponseDTO) -> AuthenticatedUserEntity {
        AuthenticatedUserEntity(
            userId: dto.userId,
            email: dto.email,
            nickname: dto.nickname,
            role: dto.role,
            status: dto.status
        )
    }

    static func parseDate(_ value: String) throws -> Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = formatter.date(from: value) {
            return date
        }

        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: value) {
            return date
        }

        throw AuthDataError.decodingFailure
    }
}
