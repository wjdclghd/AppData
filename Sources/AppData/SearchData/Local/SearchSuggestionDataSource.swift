//
//  SearchSuggestionDataSource.swift
//  AppData
//
//  Created by jch on 4/27/26.
//

import Foundation
import SearchEngine

/// SearchEngine과 local seed를 사용해 검색바 자동완성 제안을 조회합니다.
public struct SearchSuggestionDataSource<Engine: SearchEngineProtocol & Sendable>: SearchSuggestionDataSourceProtocol, Sendable {
    private let searchEngine: Engine
    private let scope: SearchScope?
    private let defaultSeeds: [SearchSuggestionSeed]

    /// SearchSuggestionDataSource를 생성합니다.
    ///
    /// - Parameters:
    ///   - searchEngine: 자동완성 제안을 조회할 SearchEngine 구현체입니다.
    ///   - scope: 자동완성 조회에 사용할 SearchEngine scope입니다.
    ///   - defaultSeeds: 서버가 없는 단계에서 기본 후보로 사용할 local seed입니다.
    public init(
        searchEngine: Engine,
        scope: SearchScope? = SearchSuggestionScope.appStoreSearchBarAutocomplete,
        defaultSeeds: [SearchSuggestionSeed] = SearchSuggestionSeedDataSource.defaultSeeds
    ) {
        self.searchEngine = searchEngine
        self.scope = scope
        self.defaultSeeds = defaultSeeds
    }

    /// 기본 추천 검색어 목록을 조회합니다.
    ///
    /// - Parameter limit: 최대 반환 개수입니다.
    /// - Returns: SearchEngine 기준 `SearchSuggestion` 배열입니다.
    public func fetchDefaultSuggestions(limit: Int) async throws -> [SearchSuggestion] {
        let limitedSeeds = Array(defaultSeeds.prefix(max(limit, 0)))

        return limitedSeeds.enumerated().map { index, seed in
            SearchSuggestion(
                text: seed.title,
                scope: scope,
                score: limitedSeeds.count - index,
                source: .title,
                kind: .query,
                documentID: seed.id,
                matchedText: nil
            )
        }
    }

    /// 검색어에 해당하는 자동완성 제안 목록을 조회합니다.
    ///
    /// - Parameters:
    ///   - keyword: 자동완성 조회에 사용할 검색어입니다.
    ///   - limit: 최대 반환 개수입니다.
    /// - Returns: SearchEngine 기준 `SearchSuggestion` 배열입니다.
    /// - Throws: `SearchDataError.searchEngineFailure`를 던집니다.
    public func fetchSuggestions(
        keyword: String,
        limit: Int
    ) async throws -> [SearchSuggestion] {
        do {
            let suggestions = try await searchEngine.suggest(
                SearchSuggestionQuery(
                    text: keyword,
                    scope: scope,
                    limit: limit
                )
            )

            // 완성 음절 한 글자 입력 시 keyword 매칭 범위를 제한합니다.
            // FTS5는 keyword 컬럼까지 검색하므로, 한 글자 음절 쿼리에서는
            // title이 해당 음절을 포함하는 결과만 유지합니다.
            // 초성(ㄱ~ㅎ, Jamo) 쿼리는 keyword 기반 초성 검색이 동작해야 하므로 제외합니다.
            if isSingleKoreanSyllable(keyword) {
                return suggestions.filter { $0.text.localizedCaseInsensitiveContains(keyword) }
            }

            return suggestions
        } catch {
            throw SearchDataError.searchEngineFailure
        }
    }
}

// MARK: - Private

private extension SearchSuggestionDataSource {
    /// 입력 텍스트가 완성된 한글 음절 한 글자인지 확인합니다.
    ///
    /// 완성 음절(U+AC00–U+D7A3)만 판별합니다.
    /// 초성 자모(ㄱ~ㅎ)는 false를 반환합니다.
    func isSingleKoreanSyllable(_ text: String) -> Bool {
        guard text.count == 1, let scalar = text.unicodeScalars.first else { return false }
        return scalar.value >= 0xAC00 && scalar.value <= 0xD7A3
    }
}
