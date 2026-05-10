//
//  SearchSuggestionSeedDocumentMapper.swift
//  AppData
//
//  Created by jch on 4/30/26.
//

import Foundation
import SearchEngine

/// SearchData local seed를 SearchEngine 색인 문서로 변환합니다.
enum SearchSuggestionSeedDocumentMapper {
    /// local seed를 SearchDocument로 변환합니다.
    ///
    /// - Parameters:
    ///   - seed: 변환할 local seed입니다.
    ///   - scope: SearchEngine에 저장할 검색 범위입니다.
    ///   - lastUpdatedAt: 문서 갱신 시각입니다.
    ///
    /// - Returns: SearchEngine 색인에 사용할 SearchDocument입니다.
    static func toDocument(
        from seed: SearchSuggestionSeed,
        scope: SearchScope = SearchSuggestionScope.appStoreSearchBarAutocomplete,
        lastUpdatedAt: Date
    ) -> SearchDocument {
        let chosung = KoreanChosungExtractor.extract(from: seed.title)
        let augmentedKeywords = chosung.isEmpty
            ? seed.keywords
            : seed.keywords + [chosung]

        return SearchDocument(
            id: seed.id,
            scope: scope,
            title: seed.title,
            body: seed.body,
            keywords: augmentedKeywords,
            lastUpdatedAt: lastUpdatedAt
        )
    }
}
