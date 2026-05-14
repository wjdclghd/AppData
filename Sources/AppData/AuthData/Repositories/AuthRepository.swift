//
//  AuthRepository.swift
//  AppData
//
//  Created by jch on 5/10/26.
//

import Foundation
import AppDomain

/// AuthRepositoryProtocol 구현체입니다.
public struct AuthRepository<
    RemoteDataSource: AuthRemoteDataSourceProtocol,
    TokenLocalDataSource: AuthTokenLocalDataSourceProtocol,
    SessionLocalDataSource: AuthSessionLocalDataSourceProtocol
>: AuthRepositoryProtocol, Sendable {
    private let remoteDataSource: RemoteDataSource
    private let tokenLocalDataSource: TokenLocalDataSource
    private let sessionLocalDataSource: SessionLocalDataSource
    private let environment: String
    private let now: @Sendable () -> Date

    /// AuthRepository를 생성합니다.
    ///
    /// - Parameters:
    ///   - remoteDataSource: Auth API 요청을 수행할 원격 데이터 소스입니다.
    ///   - tokenLocalDataSource: token 저장을 수행할 Keychain 데이터 소스입니다.
    ///   - sessionLocalDataSource: session 저장을 수행할 Persistence 데이터 소스입니다.
    ///   - environment: local 저장소에서 사용할 환경 식별자입니다.
    ///   - now: 저장 시각을 제공하는 클로저입니다.
    public init(
        remoteDataSource: RemoteDataSource,
        tokenLocalDataSource: TokenLocalDataSource,
        sessionLocalDataSource: SessionLocalDataSource,
        environment: String = "local",
        now: @escaping @Sendable () -> Date = { Date() }
    ) {
        self.remoteDataSource = remoteDataSource
        self.tokenLocalDataSource = tokenLocalDataSource
        self.sessionLocalDataSource = sessionLocalDataSource
        self.environment = environment
        self.now = now
    }

    /// 신규 사용자를 생성합니다.
    public func signup(
        email: String,
        password: String,
        nickname: String
    ) async throws -> SignupUserEntity {
        do {
            let response = try await remoteDataSource.signup(
                email: email,
                password: password,
                nickname: nickname
            )
            return try AuthDTOMapper.toSignupUserEntity(from: response)
        } catch let error as AuthDomainError {
            throw error
        } catch let error as AuthDataError {
            throw AuthDataErrorMapper.toDomainError(from: error)
        } catch {
            throw AuthDomainError.temporarilyUnavailable
        }
    }

    /// 이메일과 비밀번호로 인증 세션을 생성합니다.
    public func login(
        email: String,
        password: String
    ) async throws -> AuthSessionEntity {
        do {
            let response = try await remoteDataSource.login(
                email: email,
                password: password
            )
            let session = try AuthDTOMapper.toAuthSessionEntity(from: response)
            try await saveLocalSession(session)
            return session
        } catch let error as AuthDomainError {
            throw error
        } catch let error as AuthDataError {
            throw AuthDataErrorMapper.toDomainError(from: error)
        } catch {
            throw AuthDomainError.temporarilyUnavailable
        }
    }

    /// Refresh token으로 인증 세션을 갱신합니다.
    public func refreshAuthToken(refreshToken: String) async throws -> AuthSessionEntity {
        do {
            let response = try await remoteDataSource.refreshAuthToken(refreshToken: refreshToken)
            let session = try AuthDTOMapper.toAuthSessionEntity(from: response)
            try await saveLocalSession(session)
            return session
        } catch let error as AuthDomainError {
            throw error
        } catch let error as AuthDataError {
            if error == .invalidRefreshToken {
                await clearLocalDataIgnoringErrors()
            }
            throw AuthDataErrorMapper.toDomainError(from: error)
        } catch {
            throw AuthDomainError.temporarilyUnavailable
        }
    }

    /// 저장소에서 인증 토큰을 조회합니다.
    public func fetchStoredToken() async throws -> AuthStoredTokenEntity? {
        guard let record = try await tokenLocalDataSource.fetchToken(environment: environment) else {
            return nil
        }
        return AuthStoredTokenEntity(
            refreshToken: record.refreshToken,
            accessToken: record.accessToken,
            accessTokenExpiresAt: record.accessTokenExpiresAt,
            refreshTokenExpiresAt: record.refreshTokenExpiresAt
        )
    }

    /// 저장소에서 인증된 사용자 정보를 조회합니다.
    public func fetchStoredSession() async throws -> AuthenticatedUserEntity? {
        guard let record = try await sessionLocalDataSource.fetchSession(environment: environment),
              record.isLoggedIn else {
            return nil
        }
        return AuthenticatedUserEntity(
            userId: Int(record.userID),
            email: record.email,
            nickname: record.nickname,
            role: record.role,
            status: record.status
        )
    }

    /// 로컬 저장소의 인증 토큰과 세션을 모두 삭제합니다.
    public func clearLocalSession() async throws {
        if let error = await clearLocalData() {
            throw error
        }
    }

    /// 서버에 로그아웃을 요청합니다. 로컬 저장소 정리는 수행하지 않습니다.
    public func requestLogout(refreshToken: String) async throws {
        do {
            try await remoteDataSource.logout(refreshToken: refreshToken)
        } catch let error as AuthDomainError {
            throw error
        } catch let error as AuthDataError {
            throw AuthDataErrorMapper.toDomainError(from: error)
        } catch {
            throw AuthDomainError.temporarilyUnavailable
        }
    }

}

private extension AuthRepository {
    func saveLocalSession(_ session: AuthSessionEntity) async throws {
        let updatedAt = now()
        let tokenRecord = AuthDTOMapper.toAuthTokenRecord(
            from: session.token,
            environment: environment,
            updatedAt: updatedAt
        )
        let sessionRecord = AuthDTOMapper.toAuthSessionRecord(
            from: session.user,
            environment: environment,
            lastRefreshedAt: updatedAt
        )

        do {
            try await tokenLocalDataSource.saveToken(tokenRecord)
        } catch {
            throw AuthDomainError.temporarilyUnavailable
        }

        do {
            try await sessionLocalDataSource.saveSession(sessionRecord)
        } catch {
            try? await tokenLocalDataSource.deleteToken(environment: environment)
            throw AuthDomainError.temporarilyUnavailable
        }
    }

    func clearLocalData() async -> AuthDomainError? {
        var hasFailure = false

        do {
            try await tokenLocalDataSource.deleteToken(environment: environment)
        } catch {
            hasFailure = true
        }

        do {
            try await sessionLocalDataSource.deleteSession(environment: environment)
        } catch {
            hasFailure = true
        }

        return hasFailure ? .temporarilyUnavailable : nil
    }

    func clearLocalDataIgnoringErrors() async {
        _ = await clearLocalData()
    }
}
