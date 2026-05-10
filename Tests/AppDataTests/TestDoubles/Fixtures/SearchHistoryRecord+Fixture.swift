//
//  SearchHistoryRecord+Fixture.swift
//  AppDataTests
//

import Foundation
import Persistence

extension SearchHistoryRecord {
    static func fixture(
        keyword: String = "치킨",
        lastSearchedAt: Date = Date(timeIntervalSince1970: 100)
    ) -> SearchHistoryRecord {
        SearchHistoryRecord(keyword: keyword, lastSearchedAt: lastSearchedAt)
    }
}
