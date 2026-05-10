//
//  SearchSuggestionSeedDataSource.swift
//  AppData
//
//  Created by jch on 4/30/26.
//

import Foundation

/// AppStore 검색바 자동완성 local seed를 제공하는 DataSource입니다.
public struct SearchSuggestionSeedDataSource: SearchSuggestionSeedDataSourceProtocol, Sendable {
    /// 기본 AppStore 검색바 자동완성 seed입니다.
    ///
    /// Bundle 내 `SearchSuggestionSeeds.json`에서 로드합니다.
    public static let defaultSeeds: [SearchSuggestionSeed] = {
        guard let url = Bundle.module.url(forResource: "SearchSuggestionSeeds", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let seeds = try? JSONDecoder().decode([SearchSuggestionSeed].self, from: data)
        else { return [] }
        return seeds
    }()

    private let seeds: [SearchSuggestionSeed]

    /// SearchSuggestionSeedDataSource를 생성합니다.
    ///
    /// - Parameter seeds: 검색바 자동완성에 사용할 local seed 배열입니다.
    public init(seeds: [SearchSuggestionSeed] = Self.defaultSeeds) {
        self.seeds = seeds
    }

    /// 검색바 자동완성에 사용할 local seed 목록을 조회합니다.
    ///
    /// - Returns: SearchData 내부에서 관리하는 local seed 배열입니다.
    public func fetchSeeds() -> [SearchSuggestionSeed] {
        seeds
    }
}

