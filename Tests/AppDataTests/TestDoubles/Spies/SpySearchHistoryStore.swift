//
//  SpySearchHistoryStore.swift
//  AppDataTests
//

import Foundation
import Persistence
@testable import AppData

/// SearchHistoryStore 호출 횟수와 전달 인자를 기록하는 Spy입니다.
final class SpySearchHistoryStore: SearchHistoryStoreProtocol, @unchecked Sendable {
    var fetchAllCallCount = 0
    var fetchMatchingCallCount = 0
    var saveCallCount = 0
    var deleteCallCount = 0
    var deleteAllCallCount = 0
    var receivedRecord: SearchHistoryRecord?
    var receivedDeleteKeyword: String?
    var stubbedFetchAllResult: Result<[SearchHistoryRecord], Error> = .success([])
    var stubbedFetchMatchingResult: Result<[SearchHistoryRecord], Error> = .success([])
    var stubbedSaveResult: Result<Void, Error> = .success(())
    var stubbedDeleteResult: Result<Void, Error> = .success(())
    var stubbedDeleteAllResult: Result<Void, Error> = .success(())

    func fetchAll() async throws -> [SearchHistoryRecord] {
        fetchAllCallCount += 1
        return try stubbedFetchAllResult.get()
    }

    func fetchRecords(matching keyword: String) async throws -> [SearchHistoryRecord] {
        fetchMatchingCallCount += 1
        return try stubbedFetchMatchingResult.get()
    }

    func save(_ record: SearchHistoryRecord) async throws {
        saveCallCount += 1
        receivedRecord = record
        try stubbedSaveResult.get()
    }

    func delete(keyword: String) async throws {
        deleteCallCount += 1
        receivedDeleteKeyword = keyword
        try stubbedDeleteResult.get()
    }

    func deleteAll() async throws {
        deleteAllCallCount += 1
        try stubbedDeleteAllResult.get()
    }
}
