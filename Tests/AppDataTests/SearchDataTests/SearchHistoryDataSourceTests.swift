//
//  SearchHistoryDataSourceTests.swift
//  AppData
//
//  Created by jch on 4/27/26.
//

import Foundation
import XCTest
import Persistence
@testable import AppData

/// SearchHistoryDataSource의 Persistence 위임과 오류 변환을 검증합니다.
final class SearchHistoryDataSourceTests: XCTestCase {
    private enum TestFailure: LocalizedError {
        case expected

        var errorDescription: String? {
            switch self {
            case .expected:
                return "Expected search history store failure"
            }
        }
    }

    // MARK: - Properties

    private var sut: SearchHistoryDataSource<SpySearchHistoryStore>!
    private var store: SpySearchHistoryStore!

    // MARK: - Setup

    override func setUpWithError() throws {
        try super.setUpWithError()
        store = SpySearchHistoryStore()
        sut = SearchHistoryDataSource(store: store)
    }

    override func tearDownWithError() throws {
        sut = nil
        store = nil
        try super.tearDownWithError()
    }

    // MARK: - Tests

    func test_fetchRecentHistory_whenStoreSucceeds_returnsRecords() async throws {
        // given
        let searchedAt = Date(timeIntervalSince1970: 100)
        store.stubbedFetchAllResult = .success([
            SearchHistoryRecord(keyword: "치킨", lastSearchedAt: searchedAt)
        ])

        // when
        let records = try await sut.fetchRecentHistory()

        // then
        XCTAssertEqual(store.fetchAllCallCount, 1)
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records.first?.keyword, "치킨")
        XCTAssertEqual(records.first?.lastSearchedAt, searchedAt)
    }

    func test_fetchRecentHistory_whenStoreThrows_mapsToPersistenceFailure() async {
        // given
        store.stubbedFetchAllResult = .failure(TestFailure.expected)

        // when / then
        do {
            _ = try await sut.fetchRecentHistory()
            XCTFail("Expected persistenceFailure error")
        } catch let error as SearchDataError {
            guard case .persistenceFailure = error else {
                return XCTFail("Expected persistenceFailure, got \(error)")
            }

            XCTAssertEqual(store.fetchAllCallCount, 1)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_saveHistory_whenStoreSucceeds_callsStoreWithRecord() async throws {
        // given
        let searchedAt = Date(timeIntervalSince1970: 200)

        // when
        try await sut.saveHistory(keyword: "피자", searchedAt: searchedAt)

        // then
        XCTAssertEqual(store.saveCallCount, 1)
        XCTAssertEqual(store.receivedRecord?.keyword, "피자")
        XCTAssertEqual(store.receivedRecord?.lastSearchedAt, searchedAt)
    }

    func test_saveHistory_whenStoreThrows_mapsToPersistenceFailure() async {
        // given
        store.stubbedSaveResult = .failure(TestFailure.expected)

        // when / then
        do {
            try await sut.saveHistory(
                keyword: "피자",
                searchedAt: Date(timeIntervalSince1970: 200)
            )
            XCTFail("Expected persistenceFailure error")
        } catch let error as SearchDataError {
            guard case .persistenceFailure = error else {
                return XCTFail("Expected persistenceFailure, got \(error)")
            }

            XCTAssertEqual(store.saveCallCount, 1)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_deleteHistory_whenStoreSucceeds_callsStoreWithKeyword() async throws {
        // given / when
        try await sut.deleteHistory(keyword: "치킨")

        // then
        XCTAssertEqual(store.deleteCallCount, 1)
        XCTAssertEqual(store.receivedDeleteKeyword, "치킨")
    }

    func test_deleteHistory_whenStoreThrows_mapsToPersistenceFailure() async {
        // given
        store.stubbedDeleteResult = .failure(TestFailure.expected)

        // when / then
        do {
            try await sut.deleteHistory(keyword: "치킨")
            XCTFail("Expected persistenceFailure error")
        } catch let error as SearchDataError {
            guard case .persistenceFailure = error else {
                return XCTFail("Expected persistenceFailure, got \(error)")
            }

            XCTAssertEqual(store.deleteCallCount, 1)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_clearHistory_whenStoreSucceeds_callsStoreDeleteAll() async throws {
        // given / when
        try await sut.clearHistory()

        // then
        XCTAssertEqual(store.deleteAllCallCount, 1)
    }

    func test_clearHistory_whenStoreThrows_mapsToPersistenceFailure() async {
        // given
        store.stubbedDeleteAllResult = .failure(TestFailure.expected)

        // when / then
        do {
            try await sut.clearHistory()
            XCTFail("Expected persistenceFailure error")
        } catch let error as SearchDataError {
            guard case .persistenceFailure = error else {
                return XCTFail("Expected persistenceFailure, got \(error)")
            }

            XCTAssertEqual(store.deleteAllCallCount, 1)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
