//
//  SearchSuggestionSeed.swift
//  AppData
//
//  Created by jch on 4/30/26.
//

import Foundation

/// 서버가 없는 단계에서 검색바 자동완성의 원천으로 사용하는 local seed입니다.
public struct SearchSuggestionSeed: Equatable, Decodable, Sendable {
    /// seed를 안정적으로 식별하는 값입니다.
    public let id: String

    /// 자동완성 후보로 표시할 검색어입니다.
    public let title: String

    /// 검색 보조용 설명입니다.
    public let body: String

    /// 검색 보조 키워드입니다.
    public let keywords: [String]

    /// SearchSuggestionSeed를 생성합니다.
    ///
    /// - Parameters:
    ///   - id: seed를 안정적으로 식별하는 값입니다.
    ///   - title: 자동완성 후보로 표시할 검색어입니다.
    ///   - body: 검색 보조용 설명입니다.
    ///   - keywords: 검색 보조 키워드입니다.
    public init(
        id: String,
        title: String,
        body: String,
        keywords: [String]
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.keywords = keywords
    }
}
