//
//  AuthSessionLocalDataSource.swift
//  AppData
//
//  Created by jch on 5/10/26.
//

import Foundation
import Persistence

/// Persistence 저장소를 사용해 인증 session을 읽고 씁니다.
public struct AuthSessionLocalDataSource: AuthSessionLocalDataSourceProtocol, @unchecked Sendable {
    private let store: any AuthSessionStoreProtocol

    /// AuthSessionLocalDataSource를 생성합니다.
    ///
    /// - Parameter store: 인증 session 조회, 저장, 삭제를 수행할 Persistence 저장소입니다.
    public init(store: any AuthSessionStoreProtocol) {
        self.store = store
    }

    /// 지정한 환경의 session을 조회합니다.
    public func fetchSession(environment: String) async throws -> AuthSessionRecord? {
        do {
            return try await store.fetchSession(for: environment)
        } catch {
            throw AuthDataError.persistenceFailure
        }
    }

    /// session을 저장합니다.
    public func saveSession(_ session: AuthSessionRecord) async throws {
        do {
            try await store.save(session)
        } catch {
            throw AuthDataError.persistenceFailure
        }
    }

    /// 지정한 환경의 session을 삭제합니다.
    public func deleteSession(environment: String) async throws {
        do {
            try await store.delete(environment: environment)
        } catch {
            throw AuthDataError.persistenceFailure
        }
    }

    /// 모든 auth session을 삭제합니다.
    public func deleteAllSessions() async throws {
        do {
            try await store.deleteAll()
        } catch {
            throw AuthDataError.persistenceFailure
        }
    }
}
