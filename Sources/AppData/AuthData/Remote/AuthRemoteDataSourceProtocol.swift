//
//  AuthRemoteDataSourceProtocol.swift
//  AppData
//
//  Created by jch on 5/10/26.
//

import Foundation

/// Auth 원격 데이터 소스 계약입니다.
public protocol AuthRemoteDataSourceProtocol: Sendable {
    /// 회원가입 응답을 조회합니다.
    ///
    /// - Parameters:
    ///   - email: 회원가입 이메일입니다.
    ///   - password: 회원가입 비밀번호입니다.
    ///   - nickname: 회원가입 닉네임입니다.
    /// - Returns: `SignupResponseDTO`입니다.
    /// - Throws: `AuthDataError`를 던집니다.
    func signup(
        email: String,
        password: String,
        nickname: String
    ) async throws -> SignupResponseDTO

    /// 로그인 응답을 조회합니다.
    ///
    /// - Parameters:
    ///   - email: 로그인 이메일입니다.
    ///   - password: 로그인 비밀번호입니다.
    /// - Returns: `AuthSessionResponseDTO`입니다.
    /// - Throws: `AuthDataError`를 던집니다.
    func login(
        email: String,
        password: String
    ) async throws -> AuthSessionResponseDTO

    /// 토큰 재발급 응답을 조회합니다.
    ///
    /// - Parameter refreshToken: 재발급에 사용할 refresh token입니다.
    /// - Returns: `AuthSessionResponseDTO`입니다.
    /// - Throws: `AuthDataError`를 던집니다.
    func refreshAuthToken(refreshToken: String) async throws -> AuthSessionResponseDTO

    /// 로그아웃 API를 호출합니다.
    ///
    /// - Parameter refreshToken: 폐기할 refresh token입니다.
    /// - Throws: `AuthDataError`를 던집니다.
    func logout(refreshToken: String) async throws
}
