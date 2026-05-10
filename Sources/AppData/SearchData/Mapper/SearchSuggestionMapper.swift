//
//  SearchSuggestionMapper.swift
//  AppData
//
//  Created by jch on 4/27/26.
//

import Foundation
import AppDomain
import SearchEngine

/// SearchEngine 자동완성 모델을 AppDomain 엔터티로 변환합니다.
enum SearchSuggestionMapper {
    /// SearchEngine 제안 모델을 Domain 자동완성 엔터티로 변환합니다.
    ///
    /// - Parameter suggestion: SearchEngine 모듈에서 조회한 자동완성 제안 값입니다.
    /// - Returns: `SearchSuggestionEntity`입니다.
    static func toEntity(from suggestion: SearchSuggestion) -> SearchSuggestionEntity {
        SearchSuggestionEntity(
            id: suggestion.text,
            keyword: suggestion.text
        )
    }
}
