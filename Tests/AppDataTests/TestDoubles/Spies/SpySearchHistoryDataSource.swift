//
//  SpySearchHistoryDataSource.swift
//  AppDataTests
//

import Foundation
import Persistence
@testable import AppData

/// SearchHistoryDataSource 호출 횟수와 전달 인자를 기록하는 Spy입니다.
final class SpySearchHistoryDataSource: SearchHistoryDataSourceProtocol, @unchecked Sendable {
    var fetchRecentHistoryCallCount = 0
    var saveHistoryCallCount = 0
    var deleteHistoryCallCount = 0
    var clearHistoryCallCount = 0
    var receivedKeyword: String?
    var receivedSearchedAt: Date?
    var receivedDeleteKeyword: String?
    var stubbedFetchResult: Result<[SearchHistoryRecord], Error> = .success([])
    var stubbedSaveResult: Result<Void, Error> = .success(())
    var stubbedDeleteResult: Result<Void, Error> = .success(())
    var stubbedClearResult: Result<Void, Error> = .success(())

    func fetchRecentHistory() async throws -> [SearchHistoryRecord] {
        fetchRecentHistoryCallCount += 1
        return try stubbedFetchResult.get()
    }

    func saveHistory(
        keyword: String,
        searchedAt: Date
    ) async throws {
        saveHistoryCallCount += 1
        receivedKeyword = keyword
        receivedSearchedAt = searchedAt
        try stubbedSaveResult.get()
    }

    func deleteHistory(keyword: String) async throws {
        deleteHistoryCallCount += 1
        receivedDeleteKeyword = keyword
        try stubbedDeleteResult.get()
    }

    func clearHistory() async throws {
        clearHistoryCallCount += 1
        try stubbedClearResult.get()
    }
}
