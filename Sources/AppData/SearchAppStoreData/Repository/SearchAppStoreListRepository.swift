//
//  SearchAppStoreListRepository.swift
//  AppData
//
//  Created by jch on 4/15/26.
//

import Foundation
import AppDomain

/// SearchAppStore 목록 조회 Repository 구현체입니다.
public struct SearchAppStoreListRepository<DataSource: SearchAppStoreDataSourceProtocol>: SearchAppStoreListRepositoryProtocol, Sendable {
    private let dataSource: DataSource

    /// SearchAppStoreListRepository를 생성합니다.
    ///
    /// - Parameter dataSource: 목록 원격 조회를 수행할 데이터 소스입니다.
    public init(dataSource: DataSource) {
        self.dataSource = dataSource
    }

    /// 검색어에 해당하는 앱 목록을 조회합니다.
    ///
    /// - Parameter searchKeyword: 검색에 사용할 키워드입니다.
    /// - Returns: 목록 화면 구성을 위한 `SearchAppStoreListEntity` 배열입니다.
    /// - Throws: `SearchAppStoreDomainError.temporarilyUnavailable`를 던집니다.
    public func fetchSearchAppStoreList(searchKeyword: String) async throws -> [SearchAppStoreListEntity] {
        do {
            let response = try await dataSource.fetchListResults(searchKeyword: searchKeyword)
            return response.results.map(SearchAppStoreDTOMapper.toListEntity(from:))
        } catch let error as SearchAppStoreDomainError {
            throw error
        } catch let error as SearchAppStoreDataError {
            switch error {
            case .remoteFailure, .invalidResponse, .decodingFailure, .emptyDetailResponse:
                throw SearchAppStoreDomainError.temporarilyUnavailable
            }
        } catch {
            throw SearchAppStoreDomainError.temporarilyUnavailable
        }
    }
}
