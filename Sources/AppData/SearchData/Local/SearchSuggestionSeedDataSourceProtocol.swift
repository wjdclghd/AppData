//
//  SearchSuggestionSeedDataSourceProtocol.swift
//  AppData
//
//  Created by jch on 4/30/26.
//

import Foundation

/// 검색바 자동완성 local seed 원천의 public 계약입니다.
public protocol SearchSuggestionSeedDataSourceProtocol: Sendable {
    /// 검색바 자동완성에 사용할 local seed 목록을 조회합니다.
    ///
    /// - Returns: SearchData 내부에서 관리하는 local seed 배열입니다.
    func fetchSeeds() -> [SearchSuggestionSeed]
}
