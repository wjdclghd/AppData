//
//  StubSeedDataSource.swift
//  AppDataTests
//

import Foundation
@testable import AppData

/// 주입한 seed를 그대로 반환하는 Stub입니다.
struct StubSeedDataSource: SearchSuggestionSeedDataSourceProtocol {
    let seeds: [SearchSuggestionSeed]

    func fetchSeeds() -> [SearchSuggestionSeed] {
        seeds
    }
}
