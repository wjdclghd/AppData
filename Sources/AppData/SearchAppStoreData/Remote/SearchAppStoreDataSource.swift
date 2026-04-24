//
//  SearchAppStoreDataSource.swift
//  AppData
//
//  Created by jch on 4/15/26.
//

import Foundation
import Networking

/*
 App Store 원격 데이터 소스 구현체입니다.

 이 타입은 Networking 모듈의 NetworkClient를 사용하여
 SearchAppStore 기능에 필요한 목록 및 상세 응답을 조회합니다.
 원격 호출 과정에서 발생한 구체 오류는 AppData 내부 오류로 정리해 전달합니다.

 담당 역할
 - App Store endpoint 생성 위임
 - NetworkClient를 통한 원격 요청 수행
 - 원격 오류를 AppData 기준 오류로 변환

 담당하지 않는 역할
 - DTO를 Domain 엔터티로 매핑
 - 비즈니스 입력 검증
 - Feature 계층 사용자 메시지 결정
 */
public struct SearchAppStoreDataSource<NetworkClient: NetworkClientProtocol>: SearchAppStoreDataSourceProtocol, Sendable {
    private let networkClient: NetworkClient

    /*
     SearchAppStoreDataSource를 생성합니다.

     Parameters:
     - networkClient: 원격 요청을 수행할 Networking 모듈의 클라이언트
     */
    public init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    /*
     검색 목록 응답을 조회합니다.

     Parameters:
     - searchKeyword: 검색에 사용할 키워드

     Returns:
     - SearchAppStoreResponseDTO

     Throws:
     - SearchAppStoreDataError.remoteFailure
     - SearchAppStoreDataError.invalidResponse
     - SearchAppStoreDataError.decodingFailure
     */
    public func fetchListResults(searchKeyword: String) async throws -> SearchAppStoreResponseDTO {
        let endpoint = SearchAppStoreEndpoint.list(searchKeyword: searchKeyword)
        return try await request(endpoint: endpoint)
    }

    /*
     상세 응답을 조회합니다.

     Parameters:
     - trackId: 조회할 앱 식별자

     Returns:
     - SearchAppStoreResponseDTO

     Throws:
     - SearchAppStoreDataError.remoteFailure
     - SearchAppStoreDataError.invalidResponse
     - SearchAppStoreDataError.decodingFailure
     */
    public func fetchDetailResults(trackId: Int) async throws -> SearchAppStoreResponseDTO {
        let endpoint = SearchAppStoreEndpoint.detail(trackId: trackId)
        return try await request(endpoint: endpoint)
    }
}

private extension SearchAppStoreDataSource {
    /*
     공통 원격 요청을 수행하고 Networking 오류를 AppData 오류로 변환합니다.

     Parameters:
     - endpoint: 요청할 endpoint

     Returns:
     - SearchAppStoreResponseDTO

     Throws:
     - SearchAppStoreDataError.remoteFailure
     - SearchAppStoreDataError.invalidResponse
     - SearchAppStoreDataError.decodingFailure
     */
    func request(endpoint: Endpoint) async throws -> SearchAppStoreResponseDTO {
        do {
            return try await networkClient.request(endpoint, as: SearchAppStoreResponseDTO.self)
        } catch let error as SearchAppStoreDataError {
            throw error
        } catch let error as NetworkError {
            switch error {
            case .emptyResponse:
                throw SearchAppStoreDataError.invalidResponse
            case .decoding:
                throw SearchAppStoreDataError.decodingFailure
            default:
                throw SearchAppStoreDataError.remoteFailure
            }
        } catch {
            throw SearchAppStoreDataError.remoteFailure
        }
    }
}
