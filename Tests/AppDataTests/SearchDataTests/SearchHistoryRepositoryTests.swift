//
//  SearchHistoryRepositoryTests.swift
//  AppData
//
//  Created by jch on 4/27/26.
//

import Foundation
import XCTest
import AppDomain
import Persistence
@testable import AppData

/// SearchHistoryRepository의 매핑과 도메인 오류 변환을 검증합니다.
final class SearchHistoryRepositoryTests: XCTestCase {

    // MARK: - Properties

    private var sut: SearchHistoryRepository<SpySearchHistoryDataSource>!
    private var dataSource: SpySearchHistoryDataSource!

    // MARK: - Setup

    override func setUpWithError() throws {
        try super.setUpWithError()
        dataSource = SpySearchHistoryDataSource()
        sut = SearchHistoryRepository(dataSource: dataSource)
    }

    override func tearDownWithError() throws {
        sut = nil
        dataSource = nil
        try super.tearDownWithError()
    }

    // MARK: - Tests

    func test_fetchRecentHistory_whenDataSourceSucceeds_returnsMappedEntities() async throws {
        // given
        let searchedAt = Date(timeIntervalSince1970: 100)
        dataSource.stubbedFetchResult = .success([
            SearchHistoryRecord(keyword: "치킨", lastSearchedAt: searchedAt)
        ])

        // when
        let entities = try await sut.fetchRecentHistory()

        // then
        XCTAssertEqual(dataSource.fetchRecentHistoryCallCount, 1)
        XCTAssertEqual(entities.count, 1)
        XCTAssertEqual(entities.first?.id, "치킨")
        XCTAssertEqual(entities.first?.keyword, "치킨")
        XCTAssertEqual(entities.first?.lastSearchedAt, searchedAt)
    }

    func test_fetchRecentHistory_whenDataSourceThrows_mapsToHistoryUnavailable() async {
        // given
        dataSource.stubbedFetchResult = .failure(SearchDataError.persistenceFailure)

        // when / then
        do {
            _ = try await sut.fetchRecentHistory()
            XCTFail("Expected historyUnavailable error")
        } catch let error as SearchDomainError {
            guard case .historyUnavailable = error else {
                return XCTFail("Expected historyUnavailable, got \(error)")
            }

            XCTAssertEqual(dataSource.fetchRecentHistoryCallCount, 1)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_saveHistory_whenCustomNow_callsDataSourceWithKeywordAndNow() async throws {
        // given
        let now = Date(timeIntervalSince1970: 200)
        let sut = SearchHistoryRepository(dataSource: dataSource, now: { now })

        // when
        try await sut.saveHistory(keyword: "피자")

        // then
        XCTAssertEqual(dataSource.saveHistoryCallCount, 1)
        XCTAssertEqual(dataSource.receivedKeyword, "피자")
        XCTAssertEqual(dataSource.receivedSearchedAt, now)
    }

    func test_saveHistory_whenDataSourceThrows_mapsToHistoryUnavailable() async {
        // given
        dataSource.stubbedSaveResult = .failure(SearchDataError.persistenceFailure)

        // when / then
        do {
            try await sut.saveHistory(keyword: "피자")
            XCTFail("Expected historyUnavailable error")
        } catch let error as SearchDomainError {
            guard case .historyUnavailable = error else {
                return XCTFail("Expected historyUnavailable, got \(error)")
            }

            XCTAssertEqual(dataSource.saveHistoryCallCount, 1)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_deleteHistory_whenDataSourceSucceeds_callsDataSourceWithIdentifier() async throws {
        // given / when
        try await sut.deleteHistory(id: "치킨")

        // then
        XCTAssertEqual(dataSource.deleteHistoryCallCount, 1)
        XCTAssertEqual(dataSource.receivedDeleteKeyword, "치킨")
    }

    func test_deleteHistory_whenDataSourceThrows_mapsToHistoryUnavailable() async {
        // given
        dataSource.stubbedDeleteResult = .failure(SearchDataError.persistenceFailure)

        // when / then
        do {
            try await sut.deleteHistory(id: "치킨")
            XCTFail("Expected historyUnavailable error")
        } catch let error as SearchDomainError {
            guard case .historyUnavailable = error else {
                return XCTFail("Expected historyUnavailable, got \(error)")
            }

            XCTAssertEqual(dataSource.deleteHistoryCallCount, 1)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_clearHistory_whenDataSourceSucceeds_callsDataSource() async throws {
        // given / when
        try await sut.clearHistory()

        // then
        XCTAssertEqual(dataSource.clearHistoryCallCount, 1)
    }

    func test_clearHistory_whenDataSourceThrows_mapsToHistoryUnavailable() async {
        // given
        dataSource.stubbedClearResult = .failure(SearchDataError.persistenceFailure)

        // when / then
        do {
            try await sut.clearHistory()
            XCTFail("Expected historyUnavailable error")
        } catch let error as SearchDomainError {
            guard case .historyUnavailable = error else {
                return XCTFail("Expected historyUnavailable, got \(error)")
            }

            XCTAssertEqual(dataSource.clearHistoryCallCount, 1)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
