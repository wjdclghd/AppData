//
//  SearchSuggestionDataSourceTests.swift
//  AppData
//
//  Created by jch on 4/27/26.
//

import Foundation
import XCTest
import SearchEngine
@testable import AppData

/// SearchSuggestionDataSource의 SearchEngine 위임과 오류 변환을 검증합니다.
final class SearchSuggestionDataSourceTests: XCTestCase {
    private enum TestFailure: LocalizedError {
        case expected

        var errorDescription: String? {
            switch self {
            case .expected:
                return "Expected search engine failure"
            }
        }
    }

    // MARK: - Properties

    private var sut: SearchSuggestionDataSource<SpySearchEngine>!
    private var searchEngine: SpySearchEngine!

    // MARK: - Setup

    override func setUpWithError() throws {
        try super.setUpWithError()
        searchEngine = SpySearchEngine()
        sut = SearchSuggestionDataSource(searchEngine: searchEngine)
    }

    override func tearDownWithError() throws {
        sut = nil
        searchEngine = nil
        try super.tearDownWithError()
    }

    // MARK: - Tests

    func test_fetchDefaultSuggestions_withCustomSeeds_returnsSuggestionsWithoutSearchEngineCall() async throws {
        // given
        let sut = SearchSuggestionDataSource(
            searchEngine: searchEngine,
            defaultSeeds: [
                SearchSuggestionSeed(
                    id: "seed.music",
                    title: "음악",
                    body: "음악 AppStore 검색어",
                    keywords: ["음악", "music"]
                ),
                SearchSuggestionSeed(
                    id: "seed.recorder",
                    title: "음성녹음",
                    body: "음성녹음 AppStore 검색어",
                    keywords: ["음성녹음", "recorder"]
                )
            ]
        )

        // when
        let suggestions = try await sut.fetchDefaultSuggestions(limit: 3)

        // then
        XCTAssertEqual(searchEngine.suggestCallCount, 0)
        XCTAssertEqual(suggestions.map(\.text), ["음악", "음성녹음"])
        XCTAssertEqual(
            suggestions.map { $0.scope?.rawValue },
            [
                SearchSuggestionScope.appStoreSearchBarAutocomplete.rawValue,
                SearchSuggestionScope.appStoreSearchBarAutocomplete.rawValue
            ]
        )
        XCTAssertEqual(suggestions.map(\.documentID), ["seed.music", "seed.recorder"])
    }

    func test_fetchSuggestions_whenSearchEngineSucceeds_callsSearchEngineWithQuery() async throws {
        // given
        searchEngine.stubbedSuggestionResult = .success([
            SearchSuggestion(text: "치킨", scope: nil, score: 100)
        ])

        // when
        let suggestions = try await sut.fetchSuggestions(keyword: "치킨", limit: 5)

        // then
        XCTAssertEqual(searchEngine.suggestCallCount, 1)
        XCTAssertEqual(searchEngine.receivedSuggestionQuery?.text, "치킨")
        XCTAssertEqual(
            searchEngine.receivedSuggestionQuery?.scope?.rawValue,
            SearchSuggestionScope.appStoreSearchBarAutocomplete.rawValue
        )
        XCTAssertEqual(searchEngine.receivedSuggestionQuery?.limit, 5)
        XCTAssertEqual(suggestions.map(\.text), ["치킨"])
    }

    func test_fetchSuggestions_withSingleKoreanSyllable_filtersResultsToTitleContaining() async throws {
        // given — "가" 한 글자 쿼리. title에 "가"가 없는 결과(트로트)는 제거돼야 합니다.
        searchEngine.stubbedSuggestionResult = .success([
            SearchSuggestion(text: "가계부", scope: nil, score: 300),
            SearchSuggestion(text: "가사", scope: nil, score: 300),
            SearchSuggestion(text: "히라가나", scope: nil, score: 200),
            SearchSuggestion(text: "트로트", scope: nil, score: 180)
        ])

        // when
        let suggestions = try await sut.fetchSuggestions(keyword: "가", limit: 10)

        // then — title에 "가"가 포함된 항목만 유지합니다
        XCTAssertEqual(suggestions.map(\.text), ["가계부", "가사", "히라가나"])
    }

    func test_fetchSuggestions_withKoreanJamo_doesNotFilterResults() async throws {
        // given — 초성 "ㄷ" 쿼리. 초성 검색 결과는 필터링하지 않아야 합니다.
        searchEngine.stubbedSuggestionResult = .success([
            SearchSuggestion(text: "당근", scope: nil, score: 200),
            SearchSuggestion(text: "동영상", scope: nil, score: 200)
        ])

        // when
        let suggestions = try await sut.fetchSuggestions(keyword: "ㄷ", limit: 10)

        // then — 초성 쿼리는 그대로 반환합니다
        XCTAssertEqual(suggestions.map(\.text), ["당근", "동영상"])
    }

    func test_fetchSuggestions_withMultiSyllableKeyword_doesNotFilterResults() async throws {
        // given — "가수" 두 글자 쿼리. keyword 매칭 결과도 그대로 반환합니다.
        searchEngine.stubbedSuggestionResult = .success([
            SearchSuggestion(text: "가수 앱", scope: nil, score: 300),
            SearchSuggestion(text: "트로트", scope: nil, score: 180)
        ])

        // when
        let suggestions = try await sut.fetchSuggestions(keyword: "가수", limit: 10)

        // then — 두 글자 이상이면 필터링하지 않습니다
        XCTAssertEqual(suggestions.map(\.text), ["가수 앱", "트로트"])
    }

    func test_fetchSuggestions_whenSearchEngineThrows_mapsToSearchEngineFailure() async {
        // given
        searchEngine.stubbedSuggestionResult = .failure(TestFailure.expected)

        // when / then
        do {
            _ = try await sut.fetchSuggestions(keyword: "치킨", limit: 5)
            XCTFail("Expected searchEngineFailure error")
        } catch let error as SearchDataError {
            guard case .searchEngineFailure = error else {
                return XCTFail("Expected searchEngineFailure, got \(error)")
            }

            XCTAssertEqual(searchEngine.suggestCallCount, 1)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
