//
//  AuthResponseDTO.swift
//  AppData
//
//  Created by jch on 5/10/26.
//

import Foundation

/// 회원가입 API 응답 DTO입니다.
public struct SignupResponseDTO: Decodable, Equatable, Sendable {
    public let userId: Int
    public let email: String
    public let nickname: String
    public let role: String
    public let status: String
    public let createdAt: String

    public init(
        userId: Int,
        email: String,
        nickname: String,
        role: String,
        status: String,
        createdAt: String
    ) {
        self.userId = userId
        self.email = email
        self.nickname = nickname
        self.role = role
        self.status = status
        self.createdAt = createdAt
    }
}

/// 로그인과 토큰 재발급 API 응답 DTO입니다.
public struct AuthSessionResponseDTO: Decodable, Equatable, Sendable {
    public let token: AuthTokenResponseDTO
    public let user: AuthUserResponseDTO

    public init(
        token: AuthTokenResponseDTO,
        user: AuthUserResponseDTO
    ) {
        self.token = token
        self.user = user
    }
}

/// 인증 토큰 API 응답 DTO입니다.
public struct AuthTokenResponseDTO: Decodable, Equatable, Sendable {
    public let accessToken: String
    public let refreshToken: String
    public let accessTokenExpiresAt: String
    public let refreshTokenExpiresAt: String

    public init(
        accessToken: String,
        refreshToken: String,
        accessTokenExpiresAt: String,
        refreshTokenExpiresAt: String
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.accessTokenExpiresAt = accessTokenExpiresAt
        self.refreshTokenExpiresAt = refreshTokenExpiresAt
    }
}

/// 인증 사용자 API 응답 DTO입니다.
public struct AuthUserResponseDTO: Decodable, Equatable, Sendable {
    public let userId: Int
    public let email: String
    public let nickname: String
    public let role: String
    public let status: String

    public init(
        userId: Int,
        email: String,
        nickname: String,
        role: String,
        status: String
    ) {
        self.userId = userId
        self.email = email
        self.nickname = nickname
        self.role = role
        self.status = status
    }
}

/// 인증 API 오류 응답 DTO입니다.
public struct AuthErrorResponseDTO: Decodable, Equatable, Sendable {
    public let code: String
    public let message: String
    public let details: [String]
    public let timestamp: String

    public init(
        code: String,
        message: String,
        details: [String],
        timestamp: String
    ) {
        self.code = code
        self.message = message
        self.details = details
        self.timestamp = timestamp
    }
}
