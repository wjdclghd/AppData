//
//  AuthRequestDTO.swift
//  AppData
//
//  Created by jch on 5/10/26.
//

import Foundation

/// 회원가입 API 요청 DTO입니다.
public struct SignupRequestDTO: Encodable, Sendable {
    public let email: String
    public let password: String
    public let nickname: String

    public init(
        email: String,
        password: String,
        nickname: String
    ) {
        self.email = email
        self.password = password
        self.nickname = nickname
    }
}

/// 로그인 API 요청 DTO입니다.
public struct LoginRequestDTO: Encodable, Sendable {
    public let email: String
    public let password: String

    public init(
        email: String,
        password: String
    ) {
        self.email = email
        self.password = password
    }
}

/// 토큰 재발급 API 요청 DTO입니다.
public struct RefreshAuthTokenRequestDTO: Encodable, Sendable {
    public let refreshToken: String

    public init(refreshToken: String) {
        self.refreshToken = refreshToken
    }
}

/// 로그아웃 API 요청 DTO입니다.
public struct LogoutRequestDTO: Encodable, Sendable {
    public let refreshToken: String

    public init(refreshToken: String) {
        self.refreshToken = refreshToken
    }
}
