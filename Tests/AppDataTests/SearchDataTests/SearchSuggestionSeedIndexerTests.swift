//
//  SearchSuggestionSeedIndexerTests.swift
//  AppData
//
//  Created by jch on 4/30/26.
//

import Foundation
import XCTest
import SearchEngine
@testable import AppData

/// SearchSuggestionSeedIndexer의 SearchEngine 색인 위임 동작을 검증합니다.
final class SearchSuggestionSeedIndexerTests: XCTestCase {
    private enum TestFailure: Error {
        case expected
    }

    // MARK: - Properties

    private var searchEngine: SpySearchEngine!

    // MARK: - Setup

    override func setUpWithError() throws {
        try super.setUpWithError()
        searchEngine = SpySearchEngine()
    }

    override func tearDownWithError() throws {
        searchEngine = nil
        try super.tearDownWithError()
    }

    // MARK: - Tests

    func test_indexSeeds_withSeedDataSource_indexesMappedDocuments() async throws {
        // given
        let now = Date(timeIntervalSince1970: 500)
        let indexer = SearchSuggestionSeedIndexer(
            seedDataSource: StubSeedDataSource(
                seeds: [
                    SearchSuggestionSeed(
                        id: "seed.music",
                        title: "음악",
                        body: "음악 AppStore 검색어",
                        keywords: ["음악", "music"]
                    )
                ]
            ),
            searchEngine: searchEngine,
            now: { now }
        )

        // when
        try await indexer.indexSeeds()

        // then
        XCTAssertEqual(searchEngine.indexDocumentsCallCount, 1)
        XCTAssertEqual(searchEngine.receivedDocuments.map(\.id), ["seed.music"])
        XCTAssertEqual(searchEngine.receivedDocuments.map(\.title), ["음악"])
        XCTAssertEqual(
            searchEngine.receivedDocuments.map(\.scope.rawValue),
            [SearchSuggestionScope.appStoreSearchBarAutocomplete.rawValue]
        )
        XCTAssertEqual(searchEngine.receivedDocuments.map(\.lastUpdatedAt), [now])
    }

    func test_indexSeeds_whenSearchEngineThrows_mapsToSearchEngineFailure() async {
        // given
        searchEngine.stubbedIndexDocumentsResult = .failure(TestFailure.expected)
        let indexer = SearchSuggestionSeedIndexer(
            seedDataSource: StubSeedDataSource(
                seeds: [
                    SearchSuggestionSeed(
                        id: "seed.music",
                        title: "음악",
                        body: "음악 AppStore 검색어",
                        keywords: ["음악", "music"]
                    )
                ]
            ),
            searchEngine: searchEngine
        )

        // when / then
        do {
            try await indexer.indexSeeds()
            XCTFail("Expected searchEngineFailure error")
        } catch let error as SearchDataError {
            guard case .searchEngineFailure = error else {
                return XCTFail("Expected searchEngineFailure, got \(error)")
            }

            XCTAssertEqual(searchEngine.indexDocumentsCallCount, 1)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
