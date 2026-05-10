//
//  SearchAppStoreDataSourceProtocol.swift
//  AppData
//
//  Created by jch on 4/15/26.
//

import Foundation

/// App Store 원격 데이터 소스 계약입니다.
public protocol SearchAppStoreDataSourceProtocol: Sendable {
    /// 검색어에 해당하는 앱 목록 응답을 조회합니다.
    ///
    /// - Parameter searchKeyword: 검색에 사용할 키워드입니다.
    /// - Returns: `SearchAppStoreResponseDTO`입니다.
    /// - Throws: `SearchAppStoreDataError`를 던집니다.
    func fetchListResults(searchKeyword: String) async throws -> SearchAppStoreResponseDTO

    /// trackId에 해당하는 앱 상세 응답을 조회합니다.
    ///
    /// - Parameter trackId: 조회할 앱 식별자입니다.
    /// - Returns: `SearchAppStoreResponseDTO`입니다.
    /// - Throws: `SearchAppStoreDataError`를 던집니다.
    func fetchDetailResults(trackId: Int) async throws -> SearchAppStoreResponseDTO
}
