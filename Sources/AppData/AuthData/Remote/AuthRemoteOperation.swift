//
//  AuthRemoteOperation.swift
//  AppData
//
//  Created by jch on 5/10/26.
//

import Foundation

/// Auth 원격 요청 종류입니다.
enum AuthRemoteOperation: Sendable {
    case signup
    case login
    case refresh
    case logout
}
