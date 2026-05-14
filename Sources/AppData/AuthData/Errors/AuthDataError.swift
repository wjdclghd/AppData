//
//  AuthDataError.swift
//  AppData
//
//  Created by jch on 5/10/26.
//

import Foundation

/// Auth data 계층 내부에서 사용하는 오류 타입입니다.
public enum AuthDataError: Error, Equatable, LocalizedError, Sendable {
    case duplicateEmail
    case invalidCredentials
    case invalidRefreshToken
    case invalidAccessToken
    case inactiveUser
    case accessDenied
    case rateLimitExceeded
    case invalidRequest
    case remoteFailure
    case invalidResponse
    case decodingFailure
    case keychainFailure
    case persistenceFailure

    public var errorDescription: String? {
        switch self {
        case .duplicateEmail:
            return "이미 사용 중인 이메일입니다."
        case .invalidCredentials:
            return "이메일 또는 비밀번호가 올바르지 않습니다."
        case .invalidRefreshToken:
            return "Refresh Token이 올바르지 않습니다."
        case .invalidAccessToken:
            return "Access Token이 올바르지 않습니다."
        case .inactiveUser:
            return "비활성화된 사용자입니다."
        case .accessDenied:
            return "접근 권한이 없습니다."
        case .rateLimitExceeded:
            return "요청 횟수가 너무 많습니다."
        case .invalidRequest:
            return "요청 값이 올바르지 않습니다."
        case .remoteFailure:
            return "인증 서버 요청에 실패했습니다."
        case .invalidResponse:
            return "인증 서버 응답이 올바르지 않습니다."
        case .decodingFailure:
            return "인증 서버 응답을 해석하지 못했습니다."
        case .keychainFailure:
            return "인증 토큰 저장소 처리에 실패했습니다."
        case .persistenceFailure:
            return "인증 세션 저장소 처리에 실패했습니다."
        }
    }
}
