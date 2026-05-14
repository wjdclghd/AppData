//
//  AuthTokenLocalDataSource.swift
//  AppData
//
//  Created by jch on 5/10/26.
//

import Foundation
import Keychain

/// Keychain 저장소를 사용해 인증 token을 읽고 씁니다.
public struct AuthTokenLocalDataSource: AuthTokenLocalDataSourceProtocol, @unchecked Sendable {
    private let store: any AuthTokenStoreProtocol

    /// AuthTokenLocalDataSource를 생성합니다.
    ///
    /// - Parameter store: 인증 token 조회, 저장, 삭제를 수행할 Keychain 저장소입니다.
    public init(store: any AuthTokenStoreProtocol) {
        self.store = store
    }

    /// 지정한 환경의 token을 조회합니다.
    public func fetchToken(environment: String) async throws -> AuthTokenRecord? {
        do {
            return try await store.fetchToken(for: environment)
        } catch {
            throw AuthDataError.keychainFailure
        }
    }

    /// token을 저장합니다.
    public func saveToken(_ token: AuthTokenRecord) async throws {
        do {
            try await store.save(token)
        } catch {
            throw AuthDataError.keychainFailure
        }
    }

    /// 지정한 환경의 token을 삭제합니다.
    public func deleteToken(environment: String) async throws {
        do {
            try await store.delete(environment: environment)
        } catch {
            throw AuthDataError.keychainFailure
        }
    }

    /// 모든 auth token을 삭제합니다.
    public func deleteAllTokens() async throws {
        do {
            try await store.deleteAll()
        } catch {
            throw AuthDataError.keychainFailure
        }
    }
}
