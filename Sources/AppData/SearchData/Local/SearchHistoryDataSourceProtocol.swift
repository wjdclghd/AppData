//
//  SearchHistoryDataSourceProtocol.swift
//  AppData
//
//  Created by jch on 4/27/26.
//

import Foundation
import Persistence

/// 최근 검색어 로컬 저장소 접근 계약입니다.
public protocol SearchHistoryDataSourceProtocol: Sendable {
    /// 최근 검색어 목록을 조회합니다.
    ///
    /// - Returns: Persistence 기준 `SearchHistoryRecord` 배열입니다.
    /// - Throws: `SearchDataError.persistenceFailure`를 던집니다.
    func fetchRecentHistory() async throws -> [SearchHistoryRecord]

    /// 최근 검색어를 저장합니다.
    ///
    /// - Parameters:
    ///   - keyword: 저장할 검색어입니다.
    ///   - searchedAt: 검색이 발생한 시각입니다.
    /// - Throws: `SearchDataError.persistenceFailure`를 던집니다.
    func saveHistory(
        keyword: String,
        searchedAt: Date
    ) async throws

    /// 특정 검색어의 최근 검색 기록을 삭제합니다.
    ///
    /// - Parameter keyword: 삭제할 검색어입니다.
    /// - Throws: `SearchDataError.persistenceFailure`를 던집니다.
    func deleteHistory(keyword: String) async throws

    /// 모든 최근 검색어를 삭제합니다.
    ///
    /// - Throws: `SearchDataError.persistenceFailure`를 던집니다.
    func clearHistory() async throws
}
