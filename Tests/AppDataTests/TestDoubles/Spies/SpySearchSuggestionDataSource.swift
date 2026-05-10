//
//  SpySearchSuggestionDataSource.swift
//  AppDataTests
//

import Foundation
import SearchEngine
@testable import AppData

/// SearchSuggestionDataSource 호출 횟수와 전달 인자를 기록하는 Spy입니다.
final class SpySearchSuggestionDataSource: SearchSuggestionDataSourceProtocol, @unchecked Sendable {
    var fetchDefaultSuggestionsCallCount = 0
    var fetchSuggestionsCallCount = 0
    var receivedKeyword: String?
    var receivedLimit: Int?
    var stubbedDefaultResult: Result<[SearchSuggestion], Error> = .success([])
    var stubbedResult: Result<[SearchSuggestion], Error> = .success([])

    func fetchDefaultSuggestions(limit: Int) async throws -> [SearchSuggestion] {
        fetchDefaultSuggestionsCallCount += 1
        receivedLimit = limit
        return try stubbedDefaultResult.get()
    }

    func fetchSuggestions(
        keyword: String,
        limit: Int
    ) async throws -> [SearchSuggestion] {
        fetchSuggestionsCallCount += 1
        receivedKeyword = keyword
        receivedLimit = limit
        return try stubbedResult.get()
    }
}
