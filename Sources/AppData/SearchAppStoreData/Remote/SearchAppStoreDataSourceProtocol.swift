//
//  SearchAppStoreDataSourceProtocol.swift
//  AppData
//
//  Created by jch on 4/15/26.
//

import Foundation

/*
 App Store 원격 데이터 소스의 public 계약입니다.

 Repository 구현체는 이 프로토콜을 통해 목록 및 상세 원격 응답을 조회하며,
 구체적인 네트워크 클라이언트 구현 대신 원격 조회 계약에만 의존합니다.
 */
public protocol SearchAppStoreDataSourceProtocol: Sendable {
    /*
     검색어에 해당하는 앱 목록 응답을 조회합니다.

     Parameters:
     - searchKeyword: 검색에 사용할 키워드

     Returns:
     - SearchAppStoreResponseDTO

     Throws:
     - SearchAppStoreDataError.remoteFailure
     - SearchAppStoreDataError.invalidResponse
     - SearchAppStoreDataError.decodingFailure
     */
    func fetchListResults(searchKeyword: String) async throws -> SearchAppStoreResponseDTO

    /*
     trackId에 해당하는 앱 상세 응답을 조회합니다.

     Parameters:
     - trackId: 조회할 앱 식별자

     Returns:
     - SearchAppStoreResponseDTO

     Throws:
     - SearchAppStoreDataError.remoteFailure
     - SearchAppStoreDataError.invalidResponse
     - SearchAppStoreDataError.decodingFailure
     */
    func fetchDetailResults(trackId: Int) async throws -> SearchAppStoreResponseDTO
}
