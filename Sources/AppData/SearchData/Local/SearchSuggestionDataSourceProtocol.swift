//
//  SearchSuggestionDataSourceProtocol.swift
//  AppData
//
//  Created by jch on 4/27/26.
//

import Foundation
import SearchEngine

/// 검색바 자동완성 제안 조회 계약입니다.
public protocol SearchSuggestionDataSourceProtocol: Sendable {
    /// 기본 추천 검색어 목록을 조회합니다.
    ///
    /// - Parameter limit: 최대 반환 개수입니다.
    /// - Returns: SearchEngine 기준 `SearchSuggestion` 배열입니다.
    /// - Throws: `SearchDataError.searchEngineFailure`를 던집니다.
    func fetchDefaultSuggestions(limit: Int) async throws -> [SearchSuggestion]

    /// 검색어에 해당하는 자동완성 제안 목록을 조회합니다.
    ///
    /// - Parameters:
    ///   - keyword: 자동완성 조회에 사용할 검색어입니다.
    ///   - limit: 최대 반환 개수입니다.
    /// - Returns: SearchEngine 기준 `SearchSuggestion` 배열입니다.
    /// - Throws: `SearchDataError.searchEngineFailure`를 던집니다.
    func fetchSuggestions(
        keyword: String,
        limit: Int
    ) async throws -> [SearchSuggestion]
}
