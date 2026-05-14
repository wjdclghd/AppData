//
//  SearchAppStoreDataSource.swift
//  AppData
//
//  Created by jch on 4/15/26.
//

import Foundation
import Networking

/// Networking 클라이언트로 App Store 검색과 상세 응답을 조회합니다.
public struct SearchAppStoreDataSource<NetworkClient: NetworkClientProtocol>: SearchAppStoreDataSourceProtocol, Sendable {
    private let networkClient: NetworkClient
    private let baseURL: URL

    /// SearchAppStoreDataSource를 생성합니다.
    ///
    /// - Parameters:
    ///   - networkClient: 원격 요청을 수행할 Networking 모듈의 클라이언트입니다.
    ///   - baseURL: App Store API 서버 기준 URL입니다. App Target의 `AppEnvironment.searchAppStoreBaseURL`에서 주입합니다.
    public init(networkClient: NetworkClient, baseURL: URL) {
        self.networkClient = networkClient
        self.baseURL = baseURL
    }

    /// 검색 목록 응답을 조회합니다.
    ///
    /// - Parameter searchKeyword: 검색에 사용할 키워드입니다.
    /// - Returns: `SearchAppStoreResponseDTO`입니다.
    /// - Throws: `SearchAppStoreDataError`를 던집니다.
    public func fetchListResults(searchKeyword: String) async throws -> SearchAppStoreResponseDTO {
        let endpoint = SearchAppStoreEndpoint.list(searchKeyword: searchKeyword, baseURL: baseURL)
        return try await request(endpoint: endpoint)
    }

    /// 상세 응답을 조회합니다.
    ///
    /// - Parameter trackId: 조회할 앱 식별자입니다.
    /// - Returns: `SearchAppStoreResponseDTO`입니다.
    /// - Throws: `SearchAppStoreDataError`를 던집니다.
    public func fetchDetailResults(trackId: Int) async throws -> SearchAppStoreResponseDTO {
        let endpoint = SearchAppStoreEndpoint.detail(trackId: trackId, baseURL: baseURL)
        return try await request(endpoint: endpoint)
    }
}

private extension SearchAppStoreDataSource {
    func request(endpoint: Endpoint) async throws -> SearchAppStoreResponseDTO {
        do {
            return try await networkClient.request(endpoint, as: SearchAppStoreResponseDTO.self)
        } catch let error as SearchAppStoreDataError {
            throw error
        } catch let error as NetworkError {
            switch error {
            case .emptyResponse:
                throw SearchAppStoreDataError.invalidResponse
            case .decoding(_):
                throw SearchAppStoreDataError.decodingFailure
            case .invalidURL,
                 .invalidRequest,
                 .missingAuthorization,
                 .encoding(_),
                 .http(_),
                 .timeout,
                 .cancelled,
                 .transport(_),
                 .unknown:
                throw SearchAppStoreDataError.remoteFailure
            }
        } catch {
            throw SearchAppStoreDataError.remoteFailure
        }
    }
}
