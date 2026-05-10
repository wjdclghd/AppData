//
//  SearchSuggestionSeedDocumentMapperTests.swift
//  AppData
//
//  Created by jch on 4/30/26.
//

import Foundation
import XCTest
import SearchEngine
@testable import AppData

/// SearchSuggestionSeedDocumentMapper의 SearchDocument 변환 규칙을 검증합니다.
final class SearchSuggestionSeedDocumentMapperTests: XCTestCase {
    func test_toDocument_withValidSeed_returnsMappedDocument() throws {
        // given
        let now = Date(timeIntervalSince1970: 400)
        let seed = SearchSuggestionSeed(
            id: "seed.music",
            title: "음악",
            body: "음악 AppStore 검색어",
            keywords: ["음악", "music"]
        )

        // when
        let document = SearchSuggestionSeedDocumentMapper.toDocument(
            from: seed,
            lastUpdatedAt: now
        )

        // then
        XCTAssertEqual(document.id, "seed.music")
        XCTAssertEqual(document.scope.rawValue, SearchSuggestionScope.appStoreSearchBarAutocomplete.rawValue)
        XCTAssertEqual(document.title, "음악")
        XCTAssertEqual(document.body, "음악 AppStore 검색어")
        XCTAssertEqual(document.lastUpdatedAt, now)
        try document.validate()
    }

    func test_toDocument_withKoreanTitle_includesChosungKeyword() throws {
        // given
        let seed = SearchSuggestionSeed(
            id: "seed.daangn",
            title: "당근",
            body: "당근마켓 검색어",
            keywords: ["당근", "당근마켓"]
        )

        // when
        let document = SearchSuggestionSeedDocumentMapper.toDocument(
            from: seed,
            lastUpdatedAt: Date()
        )

        // then — 초성 "ㄷㄱ"이 keywords에 포함되어야 합니다
        XCTAssertTrue(document.keywords.contains("ㄷㄱ"))
    }

    func test_toDocument_withMultiSyllableKoreanTitle_includesCorrectChosung() throws {
        // given
        let seed = SearchSuggestionSeed(
            id: "seed.calendar",
            title: "음력달력",
            body: "음력달력 검색어",
            keywords: ["음력달력"]
        )

        // when
        let document = SearchSuggestionSeedDocumentMapper.toDocument(
            from: seed,
            lastUpdatedAt: Date()
        )

        // then — 음력달력의 초성은 "ㅇㄹㄷㄹ"입니다
        XCTAssertTrue(document.keywords.contains("ㅇㄹㄷㄹ"))
    }

    func test_toDocument_withNonKoreanTitle_doesNotAddChosungKeyword() {
        // given
        let seed = SearchSuggestionSeed(
            id: "seed.youtube",
            title: "YouTube",
            body: "YouTube 검색어",
            keywords: ["youtube", "유튜브"]
        )

        // when
        let document = SearchSuggestionSeedDocumentMapper.toDocument(
            from: seed,
            lastUpdatedAt: Date()
        )

        // then — 한글 음절이 없으면 초성 keyword가 추가되지 않습니다
        XCTAssertEqual(document.keywords, ["youtube", "유튜브"])
    }
}
