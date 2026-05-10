//
//  SearchSuggestionRepositoryTests.swift
//  AppData
//
//  Created by jch on 4/27/26.
//

import Foundation
import XCTest
import AppDomain
import SearchEngine
@testable import AppData

/// SearchSuggestionRepository의 매핑과 도메인 오류 변환을 검증합니다.
final class SearchSuggestionRepositoryTests: XCTestCase {

    // MARK: - Properties

    private var sut: SearchSuggestionRepository<SpySearchSuggestionDataSource>!
    private var dataSource: SpySearchSuggestionDataSource!

    // MARK: - Setup

    override func setUpWithError() throws {
        try super.setUpWithError()
        dataSource = SpySearchSuggestionDataSource()
        sut = SearchSuggestionRepository(dataSource: dataSource)
    }

    override func tearDownWithError() throws {
        sut = nil
        dataSource = nil
        try super.tearDownWithError()
    }

    // MARK: - Tests

    func test_fetchDefaultSuggestions_whenDataSourceSucceeds_returnsMappedEntities() async throws {
        // given
        dataSource.stubbedDefaultResult = .success([
            SearchSuggestion(text: "카카오톡", scope: nil, score: 100),
            SearchSuggestion(text: "메모", scope: nil, score: 90)
        ])

        // when
        let entities = try await sut.fetchDefaultSuggestions(limit: 2)

        // then
        XCTAssertEqual(dataSource.fetchDefaultSuggestionsCallCount, 1)
        XCTAssertEqual(dataSource.receivedLimit, 2)
        XCTAssertEqual(entities.map(\.id), ["카카오톡", "메모"])
        XCTAssertEqual(entities.map(\.keyword), ["카카오톡", "메모"])
    }

    func test_fetchSuggestions_whenDataSourceSucceeds_returnsMappedEntities() async throws {
        // given
        dataSource.stubbedResult = .success([
            SearchSuggestion(text: "치킨", scope: nil, score: 100),
            SearchSuggestion(text: "치킨 도시락", scope: nil, score: 80)
        ])

        // when
        let entities = try await sut.fetchSuggestions(keyword: "치킨", limit: 10)

        // then
        XCTAssertEqual(dataSource.fetchSuggestionsCallCount, 1)
        XCTAssertEqual(dataSource.receivedKeyword, "치킨")
        XCTAssertEqual(dataSource.receivedLimit, 10)
        XCTAssertEqual(entities.map(\.id), ["치킨", "치킨 도시락"])
        XCTAssertEqual(entities.map(\.keyword), ["치킨", "치킨 도시락"])
    }

    func test_fetchSuggestions_whenDataSourceThrows_mapsToSuggestionUnavailable() async {
        // given
        dataSource.stubbedResult = .failure(SearchDataError.searchEngineFailure)

        // when / then
        do {
            _ = try await sut.fetchSuggestions(keyword: "치킨", limit: 10)
            XCTFail("Expected suggestionUnavailable error")
        } catch let error as SearchDomainError {
            guard case .suggestionUnavailable = error else {
                return XCTFail("Expected suggestionUnavailable, got \(error)")
            }

            XCTAssertEqual(dataSource.fetchSuggestionsCallCount, 1)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
