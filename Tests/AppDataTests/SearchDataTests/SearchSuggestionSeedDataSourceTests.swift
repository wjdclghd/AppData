//
//  SearchSuggestionSeedDataSourceTests.swift
//  AppData
//
//  Created by jch on 4/30/26.
//

import Foundation
import XCTest
@testable import AppData

/// SearchSuggestionSeedDataSource의 local seed 제공 동작을 검증합니다.
final class SearchSuggestionSeedDataSourceTests: XCTestCase {
    func test_fetchSeeds_withDefaultSeeds_returnsAppStoreSeeds() {
        // given
        let dataSource = SearchSuggestionSeedDataSource()

        // when
        let seeds = dataSource.fetchSeeds()

        // then
        XCTAssertFalse(seeds.isEmpty)
        XCTAssertTrue(seeds.contains { $0.title == "음악" })
        XCTAssertTrue(seeds.contains { $0.title == "음성녹음" })
        XCTAssertTrue(seeds.contains { $0.title == "음력달력" })
        XCTAssertTrue(seeds.allSatisfy { $0.id.isEmpty == false })
        XCTAssertTrue(seeds.allSatisfy { $0.title.isEmpty == false })
        XCTAssertTrue(seeds.allSatisfy { $0.keywords.isEmpty == false })
    }

    func test_fetchSeeds_whenCustomSeedsInjected_returnsCustomSeeds() {
        // given
        let customSeeds = [
            SearchSuggestionSeed(
                id: "seed.custom",
                title: "커스텀",
                body: "커스텀 검색어",
                keywords: ["custom"]
            )
        ]
        let dataSource = SearchSuggestionSeedDataSource(seeds: customSeeds)

        // when
        let seeds = dataSource.fetchSeeds()

        // then
        XCTAssertEqual(seeds, customSeeds)
    }
}
