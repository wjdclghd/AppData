//
//  SearchSuggestionSeedIndexer.swift
//  AppData
//
//  Created by jch on 4/30/26.
//

import Foundation
import SearchEngine

/// SearchData local seed를 SearchEngine에 색인합니다.
public struct SearchSuggestionSeedIndexer<
    SeedDataSource: SearchSuggestionSeedDataSourceProtocol,
    Engine: SearchEngineProtocol & Sendable
>: Sendable {
    private let seedDataSource: SeedDataSource
    private let searchEngine: Engine
    private let scope: SearchScope
    private let now: @Sendable () -> Date

    /// SearchSuggestionSeedIndexer를 생성합니다.
    ///
    /// - Parameters:
    ///   - seedDataSource: 검색바 자동완성 local seed 원천입니다.
    ///   - searchEngine: seed 문서를 색인할 SearchEngine 구현체입니다.
    ///   - scope: SearchEngine에 저장할 검색 범위입니다.
    ///   - now: 문서 갱신 시각을 제공하는 클로저입니다.
    public init(
        seedDataSource: SeedDataSource,
        searchEngine: Engine,
        scope: SearchScope = SearchSuggestionScope.appStoreSearchBarAutocomplete,
        now: @escaping @Sendable () -> Date = { Date() }
    ) {
        self.seedDataSource = seedDataSource
        self.searchEngine = searchEngine
        self.scope = scope
        self.now = now
    }

    /// local seed를 SearchEngine에 색인합니다.
    ///
    /// - Throws: SearchEngine 색인 실패 시 SearchDataError.searchEngineFailure를 던집니다.
    public func indexSeeds() async throws {
        let lastUpdatedAt = now()
        let documents = seedDataSource.fetchSeeds().map {
            SearchSuggestionSeedDocumentMapper.toDocument(
                from: $0,
                scope: scope,
                lastUpdatedAt: lastUpdatedAt
            )
        }

        do {
            try await searchEngine.index(documents)
        } catch {
            throw SearchDataError.searchEngineFailure
        }
    }
}
