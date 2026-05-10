//
//  SpySearchAppStoreDataSource.swift
//  AppDataTests
//

import Foundation
@testable import AppData

/// App Store DataSource 호출 횟수와 전달 인자를 기록하는 Spy입니다.
final class SpySearchAppStoreDataSource: SearchAppStoreDataSourceProtocol, @unchecked Sendable {
    var fetchListCallCount = 0
    var fetchDetailCallCount = 0
    var receivedSearchKeyword: String?
    var receivedTrackId: Int?
    var stubbedListResult: Result<SearchAppStoreResponseDTO, Error> = .success(
        SearchAppStoreResponseDTO(resultCount: 0, results: [])
    )
    var stubbedDetailResult: Result<SearchAppStoreResponseDTO, Error> = .success(
        SearchAppStoreResponseDTO(resultCount: 0, results: [])
    )

    func fetchListResults(searchKeyword: String) async throws -> SearchAppStoreResponseDTO {
        fetchListCallCount += 1
        receivedSearchKeyword = searchKeyword
        return try stubbedListResult.get()
    }

    func fetchDetailResults(trackId: Int) async throws -> SearchAppStoreResponseDTO {
        fetchDetailCallCount += 1
        receivedTrackId = trackId
        return try stubbedDetailResult.get()
    }
}
