//
//  SpyNetworkClient.swift
//  AppDataTests
//

import Foundation
import Networking
@testable import AppData

/// 네트워크 endpoint 수신과 응답을 제어하는 Spy입니다.
final class SpyNetworkClient: NetworkClientProtocol, @unchecked Sendable {
    var receivedEndpoint: Endpoint?
    var stubbedResponseData: Data = Data()
    var stubbedError: Error?

    func request<Response: Decodable & Sendable>(
        _ endpoint: Endpoint,
        as responseType: Response.Type
    ) async throws -> Response {
        receivedEndpoint = endpoint

        if let stubbedError {
            throw stubbedError
        }

        return try JSONDecoder().decode(Response.self, from: stubbedResponseData)
    }

    func request(_ endpoint: Endpoint) async throws -> Data {
        receivedEndpoint = endpoint

        if let stubbedError {
            throw stubbedError
        }

        return stubbedResponseData
    }
}
