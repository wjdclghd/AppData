//
//  AuthDataErrorMapper.swift
//  AppData
//
//  Created by jch on 5/10/26.
//

import Foundation
import AppDomain
import Networking

/// Auth data 오류를 호출 맥락에 맞는 오류로 변환합니다.
enum AuthDataErrorMapper {
    static func toDataError(
        from error: NetworkError,
        operation: AuthRemoteOperation
    ) -> AuthDataError {
        switch error {
        case .http(let httpError):
            return httpError.payload.flatMap { serverError(code: $0.code) }
                ?? httpError.data.flatMap(serverError(from:))
                ?? statusCodeFallback(httpError.statusCode, operation: operation)
        case .emptyResponse:
            return .invalidResponse
        case .decoding:
            return .decodingFailure
        case .invalidURL,
             .invalidRequest,
             .missingAuthorization,
             .encoding,
             .timeout,
             .cancelled,
             .transport,
             .unknown:
            return .remoteFailure
        }
    }

    static func toDomainError(from error: AuthDataError) -> AuthDomainError {
        switch error {
        case .duplicateEmail:
            return .duplicateEmail
        case .invalidCredentials:
            return .invalidCredentials
        case .invalidRefreshToken:
            return .invalidRefreshToken
        case .invalidAccessToken:
            return .invalidAccessToken
        case .inactiveUser:
            return .inactiveUser
        case .accessDenied:
            return .accessDenied
        case .rateLimitExceeded:
            return .rateLimitExceeded
        case .invalidRequest,
             .remoteFailure,
             .invalidResponse,
             .decodingFailure,
             .keychainFailure,
             .persistenceFailure:
            return .temporarilyUnavailable
        }
    }
}

private extension AuthDataErrorMapper {
    static func serverError(from data: Data) -> AuthDataError? {
        guard let response = try? JSONDecoder().decode(AuthErrorResponseDTO.self, from: data) else {
            return nil
        }

        return serverError(code: response.code)
    }

    static func serverError(code: String) -> AuthDataError? {
        switch code {
        case "AUTH_DUPLICATE_EMAIL":
            return .duplicateEmail
        case "AUTH_INVALID_CREDENTIALS":
            return .invalidCredentials
        case "AUTH_INVALID_REFRESH_TOKEN":
            return .invalidRefreshToken
        case "AUTH_INVALID_ACCESS_TOKEN":
            return .invalidAccessToken
        case "AUTH_INACTIVE_USER":
            return .inactiveUser
        case "ACCESS_DENIED":
            return .accessDenied
        case "RATE_LIMIT_EXCEEDED":
            return .rateLimitExceeded
        case "INVALID_REQUEST":
            return .invalidRequest
        default:
            return .remoteFailure
        }
    }

    static func statusCodeFallback(
        _ statusCode: Int,
        operation: AuthRemoteOperation
    ) -> AuthDataError {
        switch statusCode {
        case 401:
            return unauthorizedFallback(for: operation)
        case 403:
            return forbiddenFallback(for: operation)
        case 429:
            return .rateLimitExceeded
        default:
            return .remoteFailure
        }
    }

    static func forbiddenFallback(for operation: AuthRemoteOperation) -> AuthDataError {
        switch operation {
        case .login,
             .refresh:
            return .inactiveUser
        case .signup,
             .logout:
            return .accessDenied
        }
    }

    static func unauthorizedFallback(for operation: AuthRemoteOperation) -> AuthDataError {
        switch operation {
        case .login:
            return .invalidCredentials
        case .refresh:
            return .invalidRefreshToken
        case .signup,
             .logout:
            return .invalidAccessToken
        }
    }
}
