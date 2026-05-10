//
//  SearchAppStoreDetailRepository.swift
//  AppData
//
//  Created by jch on 4/15/26.
//

import Foundation
import AppDomain

/// SearchAppStore 상세 조회 Repository 구현체입니다.
public struct SearchAppStoreDetailRepository<DataSource: SearchAppStoreDataSourceProtocol>: SearchAppStoreDetailRepositoryProtocol, Sendable {
    private let dataSource: DataSource

    /// SearchAppStoreDetailRepository를 생성합니다.
    ///
    /// - Parameter dataSource: 상세 원격 조회를 수행할 데이터 소스입니다.
    public init(dataSource: DataSource) {
        self.dataSource = dataSource
    }

    /// trackId에 해당하는 앱 상세 정보를 조회합니다.
    ///
    /// - Parameter trackId: 조회할 앱 식별자입니다.
    /// - Returns: `SearchAppStoreDetailEntity`입니다.
    /// - Throws: `SearchAppStoreDomainError`를 던집니다.
    public func fetchSearchAppStoreDetail(trackId: Int) async throws -> SearchAppStoreDetailEntity {
        do {
            let response = try await dataSource.fetchDetailResults(trackId: trackId)

            guard let item = response.results.first else {
                throw SearchAppStoreDataError.emptyDetailResponse
            }

            return SearchAppStoreDTOMapper.toDetailEntity(from: item)
        } catch let error as SearchAppStoreDomainError {
            throw error
        } catch let error as SearchAppStoreDataError {
            switch error {
            case .emptyDetailResponse:
                throw SearchAppStoreDomainError.appNotFound
            case .remoteFailure, .invalidResponse, .decodingFailure:
                throw SearchAppStoreDomainError.temporarilyUnavailable
            }
        } catch {
            throw SearchAppStoreDomainError.temporarilyUnavailable
        }
    }
}
