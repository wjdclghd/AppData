//
//  AuthTokenLocalDataSourceProtocol.swift
//  AppData
//
//  Created by jch on 5/10/26.
//

import Foundation
import Keychain

/// Auth token 로컬 저장소 접근 계약입니다.
public protocol AuthTokenLocalDataSourceProtocol: Sendable {
    /// 지정한 환경의 token을 조회합니다.
    ///
    /// - Parameter environment: token 저장 환경 식별자입니다.
    /// - Returns: 저장된 token record입니다.
    /// - Throws: `AuthDataError.keychainFailure`를 던집니다.
    func fetchToken(environment: String) async throws -> AuthTokenRecord?

    /// token을 저장합니다.
    ///
    /// - Parameter token: 저장할 token record입니다.
    /// - Throws: `AuthDataError.keychainFailure`를 던집니다.
    func saveToken(_ token: AuthTokenRecord) async throws

    /// 지정한 환경의 token을 삭제합니다.
    ///
    /// - Parameter environment: token 저장 환경 식별자입니다.
    /// - Throws: `AuthDataError.keychainFailure`를 던집니다.
    func deleteToken(environment: String) async throws

    /// 모든 auth token을 삭제합니다.
    ///
    /// - Throws: `AuthDataError.keychainFailure`를 던집니다.
    func deleteAllTokens() async throws
}
