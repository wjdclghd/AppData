//
//  AuthRemoteDataSourceTests.swift
//  AppDataTests
//
//  Created by jch on 5/10/26.
//

import Foundation
import XCTest
import Networking
@testable import AppData

/// AuthRemoteDataSource의 endpoint 생성과 오류 매핑을 검증합니다.
final class AuthRemoteDataSourceTests: XCTestCase {

    // MARK: - Properties

    private var sut: AuthRemoteDataSource<SpyNetworkClient>!
    private var networkClient: SpyNetworkClient!
    private var baseURL: URL!

    // MARK: - Setup

    override func setUpWithError() throws {
        try super.setUpWithError()
        networkClient = SpyNetworkClient()
        baseURL = try XCTUnwrap(URL(string: "http://localhost:8080"))
        sut = AuthRemoteDataSource(networkClient: networkClient, baseURL: baseURL)
    }

    override func tearDownWithError() throws {
        sut = nil
        networkClient = nil
        baseURL = nil
        try super.tearDownWithError()
    }

    // MARK: - Tests

    func test_signup_requestsSignupEndpointAndReturnsDTO() async throws {
        // given
        networkClient.stubbedResponseData = try jsonData([
            "userId": 1,
            "email": "test@example.com",
            "nickname": "jch",
            "role": "USER",
            "status": "ACTIVE",
            "createdAt": "2026-05-10T09:00:00Z"
        ])

        // when
        let response = try await sut.signup(
            email: "test@example.com",
            password: "password123",
            nickname: "jch"
        )

        // then
        XCTAssertEqual(networkClient.receivedEndpoint?.baseURL, baseURL)
        XCTAssertEqual(networkClient.receivedEndpoint?.path, "/api/auth/signup")
        XCTAssertEqual(networkClient.receivedEndpoint?.method, .post)
        XCTAssertEqual(networkClient.receivedEndpoint?.headers["Content-Type"], "application/json")
        XCTAssertEqual(networkClient.receivedEndpoint?.requiresAuthorization, false)
        XCTAssertEqual(response.userId, 1)
        XCTAssertEqual(try bodyValue("email"), "test@example.com")
        XCTAssertEqual(try bodyValue("password"), "password123")
        XCTAssertEqual(try bodyValue("nickname"), "jch")
    }

    func test_login_requestsLoginEndpointAndReturnsSessionDTO() async throws {
        // given
        networkClient.stubbedResponseData = try sessionResponseData()

        // when
        let response = try await sut.login(email: "test@example.com", password: "password123")

        // then
        XCTAssertEqual(networkClient.receivedEndpoint?.path, "/api/auth/login")
        XCTAssertEqual(networkClient.receivedEndpoint?.method, .post)
        XCTAssertEqual(response.token.refreshToken, "refresh-token")
        XCTAssertEqual(response.user.email, "test@example.com")
        XCTAssertEqual(try bodyValue("email"), "test@example.com")
        XCTAssertEqual(try bodyValue("password"), "password123")
    }

    func test_refreshAuthToken_requestsRefreshEndpointAndReturnsSessionDTO() async throws {
        // given
        networkClient.stubbedResponseData = try sessionResponseData(refreshToken: "new-refresh-token")

        // when
        let response = try await sut.refreshAuthToken(refreshToken: "refresh-token")

        // then
        XCTAssertEqual(networkClient.receivedEndpoint?.path, "/api/auth/refresh")
        XCTAssertEqual(response.token.refreshToken, "new-refresh-token")
        XCTAssertEqual(try bodyValue("refreshToken"), "refresh-token")
    }

    func test_logout_requestsLogoutEndpointAndAllowsEmptyResponse() async throws {
        // given / when
        try await sut.logout(refreshToken: "refresh-token")

        // then
        XCTAssertEqual(networkClient.receivedEndpoint?.path, "/api/auth/logout")
        XCTAssertEqual(networkClient.receivedEndpoint?.method, .post)
        XCTAssertEqual(networkClient.receivedEndpoint?.allowsEmptyResponse, true)
        XCTAssertEqual(networkClient.receivedEndpoint?.requiresAuthorization, false)
        XCTAssertEqual(try bodyValue("refreshToken"), "refresh-token")
    }

    func test_login_whenUnauthorized_mapsToInvalidCredentials() async {
        // given
        networkClient.stubbedError = NetworkError.http(
            NetworkHTTPError(
                statusCode: 401,
                payload: NetworkErrorPayload(
                    code: "AUTH_INVALID_CREDENTIALS",
                    message: "invalid credentials"
                )
            )
        )

        // when / then
        await assertThrowsAuthDataError(.invalidCredentials) {
            _ = try await sut.login(email: "test@example.com", password: "wrong-password")
        }
    }

    func test_refreshAuthToken_whenUnauthorized_mapsToInvalidRefreshToken() async {
        // given
        networkClient.stubbedError = NetworkError.http(
            NetworkHTTPError(
                statusCode: 401,
                payload: NetworkErrorPayload(
                    code: "AUTH_INVALID_REFRESH_TOKEN",
                    message: "invalid refresh token"
                )
            )
        )

        // when / then
        await assertThrowsAuthDataError(.invalidRefreshToken) {
            _ = try await sut.refreshAuthToken(refreshToken: "expired-refresh-token")
        }
    }

    func test_signup_whenServerReturnsDuplicateEmail_mapsToDuplicateEmail() async throws {
        // given
        networkClient.stubbedError = NetworkError.http(
            NetworkHTTPError(
                statusCode: 409,
                payload: NetworkErrorPayload(
                    code: "AUTH_DUPLICATE_EMAIL",
                    message: "duplicate email"
                ),
                data: try errorResponseData(code: "AUTH_DUPLICATE_EMAIL")
            )
        )

        // when / then
        await assertThrowsAuthDataError(.duplicateEmail) {
            _ = try await sut.signup(
                email: "test@example.com",
                password: "password123",
                nickname: "jch"
            )
        }
    }

    func test_refreshAuthToken_whenUnauthorizedWithoutPayload_usesEndpointFallback() async {
        // given
        networkClient.stubbedError = NetworkError.http(NetworkHTTPError(statusCode: 401))

        // when / then
        await assertThrowsAuthDataError(.invalidRefreshToken) {
            _ = try await sut.refreshAuthToken(refreshToken: "expired-refresh-token")
        }
    }
}

// MARK: - Helpers

private extension AuthRemoteDataSourceTests {
    func bodyValue(_ key: String) throws -> String? {
        guard let task = networkClient.receivedEndpoint?.task else {
            XCTFail("Expected endpoint task")
            return nil
        }

        guard case .jsonEncodable(let body) = task else {
            XCTFail("Expected JSON body")
            return nil
        }

        let data = try JSONEncoder().encode(body)
        let object = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        return object?[key] as? String
    }

    func sessionResponseData(refreshToken: String = "refresh-token") throws -> Data {
        try jsonData([
            "token": [
                "accessToken": "access-token",
                "refreshToken": refreshToken,
                "accessTokenExpiresAt": "2026-05-10T09:15:00Z",
                "refreshTokenExpiresAt": "2026-05-24T09:00:00Z"
            ],
            "user": [
                "userId": 1,
                "email": "test@example.com",
                "nickname": "jch",
                "role": "USER",
                "status": "ACTIVE"
            ]
        ])
    }

    func errorResponseData(code: String) throws -> Data {
        try jsonData([
            "code": code,
            "message": "error",
            "details": [],
            "timestamp": "2026-05-10T09:00:00Z"
        ])
    }

    func jsonData(_ object: Any) throws -> Data {
        try JSONSerialization.data(withJSONObject: object)
    }

    func assertThrowsAuthDataError(
        _ expectedError: AuthDataError,
        operation: () async throws -> Void
    ) async {
        do {
            try await operation()
            XCTFail("Expected \(expectedError)")
        } catch let error as AuthDataError {
            XCTAssertEqual(error, expectedError)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
