//
//  SearchSuggestionScope.swift
//  AppData
//
//  Created by jch on 4/30/26.
//

import Foundation
import SearchEngine

/// SearchData가 사용하는 SearchEngine scope 값을 정의합니다.
public enum SearchSuggestionScope {
    /// AppStore 검색바 자동완성 후보 전용 scope입니다.
    public static let appStoreSearchBarAutocomplete = SearchScope(
        rawValue: "appstore.searchbar.autocomplete"
    )
}
