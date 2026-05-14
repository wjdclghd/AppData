//
//  AuthEndpoint.swift
//  AppData
//
//  Created by jch on 5/10/26.
//

import Foundation
import Networking

/// Auth API endpoint를 구성합니다.
enum AuthEndpoint {
    static func signup(
        _ request: SignupRequestDTO,
        baseURL: URL
    ) -> Endpoint {
        jsonEndpoint(
            baseURL: baseURL,
            path: "/api/auth/signup",
            body: request
        )
    }

    static func login(
        _ request: LoginRequestDTO,
        baseURL: URL
    ) -> Endpoint {
        jsonEndpoint(
            baseURL: baseURL,
            path: "/api/auth/login",
            body: request
        )
    }

    static func refresh(
        _ request: RefreshAuthTokenRequestDTO,
        baseURL: URL
    ) -> Endpoint {
        jsonEndpoint(
            baseURL: baseURL,
            path: "/api/auth/refresh",
            body: request
        )
    }

    static func logout(
        _ request: LogoutRequestDTO,
        baseURL: URL
    ) -> Endpoint {
        jsonEndpoint(
            baseURL: baseURL,
            path: "/api/auth/logout",
            body: request,
            allowsEmptyResponse: true
        )
    }
}

private extension AuthEndpoint {
    static func jsonEndpoint<Body: Encodable & Sendable>(
        baseURL: URL,
        path: String,
        body: Body,
        allowsEmptyResponse: Bool = false
    ) -> Endpoint {
        Endpoint(
            baseURL: baseURL,
            path: path,
            method: .post,
            headers: ["Content-Type": "application/json"],
            task: .jsonEncodable(AnyEncodable(body)),
            requiresAuthorization: false,
            allowsEmptyResponse: allowsEmptyResponse
        )
    }
}
