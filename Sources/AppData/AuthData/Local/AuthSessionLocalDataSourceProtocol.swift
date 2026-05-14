//
//  AuthSessionLocalDataSourceProtocol.swift
//  AppData
//
//  Created by jch on 5/10/26.
//

import Foundation
import Persistence

/// Auth session 로컬 저장소 접근 계약입니다.
public protocol AuthSessionLocalDataSourceProtocol: Sendable {
    /// 지정한 환경의 session을 조회합니다.
    ///
    /// - Parameter environment: session 저장 환경 식별자입니다.
    /// - Returns: 저장된 session record입니다.
    /// - Throws: `AuthDataError.persistenceFailure`를 던집니다.
    func fetchSession(environment: String) async throws -> AuthSessionRecord?

    /// session을 저장합니다.
    ///
    /// - Parameter session: 저장할 session record입니다.
    /// - Throws: `AuthDataError.persistenceFailure`를 던집니다.
    func saveSession(_ session: AuthSessionRecord) async throws

    /// 지정한 환경의 session을 삭제합니다.
    ///
    /// - Parameter environment: session 저장 환경 식별자입니다.
    /// - Throws: `AuthDataError.persistenceFailure`를 던집니다.
    func deleteSession(environment: String) async throws

    /// 모든 auth session을 삭제합니다.
    ///
    /// - Throws: `AuthDataError.persistenceFailure`를 던집니다.
    func deleteAllSessions() async throws
}
