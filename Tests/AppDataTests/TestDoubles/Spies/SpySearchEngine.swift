//
//  SpySearchEngine.swift
//  AppDataTests
//

import Foundation
import SearchEngine
@testable import AppData

/// SearchEngine 호출 횟수와 전달 인자를 기록하는 Spy입니다.
final class SpySearchEngine: SearchEngineProtocol, @unchecked Sendable {
    var indexDocumentCallCount = 0
    var indexDocumentsCallCount = 0
    var deleteDocumentCallCount = 0
    var searchCallCount = 0
    var suggestCallCount = 0
    var rebuildCallCount = 0
    var receivedDocuments: [SearchDocument] = []
    var receivedSuggestionQuery: SearchSuggestionQuery?
    var stubbedSuggestionResult: Result<[SearchSuggestion], Error> = .success([])
    var stubbedIndexDocumentsResult: Result<Void, Error> = .success(())

    func index(_ document: SearchDocument) async throws {
        indexDocumentCallCount += 1
        receivedDocuments = [document]
    }

    func index(_ documents: [SearchDocument]) async throws {
        indexDocumentsCallCount += 1
        receivedDocuments = documents
        try stubbedIndexDocumentsResult.get()
    }

    func deleteDocument(id: String) async throws {
        deleteDocumentCallCount += 1
    }

    func search(_ query: SearchQuery) async throws -> [SearchHit] {
        searchCallCount += 1
        return []
    }

    func suggest(_ query: SearchSuggestionQuery) async throws -> [SearchSuggestion] {
        suggestCallCount += 1
        receivedSuggestionQuery = query
        return try stubbedSuggestionResult.get()
    }

    func rebuild() async throws {
        rebuildCallCount += 1
    }
}
