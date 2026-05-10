//
//  SearchHistoryDataSource.swift
//  AppData
//
//  Created by jch on 4/27/26.
//

import Foundation
import Persistence

/// Persistence 저장소를 사용해 최근 검색어를 읽고 씁니다.
public struct SearchHistoryDataSource<Store: SearchHistoryStoreProtocol & Sendable>: SearchHistoryDataSourceProtocol, Sendable {
    private let store: Store

    /// SearchHistoryDataSource를 생성합니다.
    ///
    /// - Parameter store: 최근 검색어 저장과 조회를 수행할 Persistence 저장소입니다.
    public init(store: Store) {
        self.store = store
    }

    /// 최근 검색어 목록을 조회합니다.
    ///
    /// - Returns: Persistence 기준 `SearchHistoryRecord` 배열입니다.
    /// - Throws: `SearchDataError.persistenceFailure`를 던집니다.
    public func fetchRecentHistory() async throws -> [SearchHistoryRecord] {
        do {
            return try await store.fetchAll()
        } catch {
            throw SearchDataError.persistenceFailure
        }
    }

    /// 최근 검색어를 저장합니다.
    ///
    /// - Parameters:
    ///   - keyword: 저장할 검색어입니다.
    ///   - searchedAt: 검색이 발생한 시각입니다.
    /// - Throws: `SearchDataError.persistenceFailure`를 던집니다.
    public func saveHistory(
        keyword: String,
        searchedAt: Date
    ) async throws {
        do {
            try await store.save(
                SearchHistoryRecord(
                    keyword: keyword,
                    lastSearchedAt: searchedAt
                )
            )
        } catch {
            throw SearchDataError.persistenceFailure
        }
    }

    /// 특정 검색어의 최근 검색 기록을 삭제합니다.
    ///
    /// - Parameter keyword: 삭제할 검색어입니다.
    /// - Throws: `SearchDataError.persistenceFailure`를 던집니다.
    public func deleteHistory(keyword: String) async throws {
        do {
            try await store.delete(keyword: keyword)
        } catch {
            throw SearchDataError.persistenceFailure
        }
    }

    /// 모든 최근 검색어를 삭제합니다.
    ///
    /// - Throws: `SearchDataError.persistenceFailure`를 던집니다.
    public func clearHistory() async throws {
        do {
            try await store.deleteAll()
        } catch {
            throw SearchDataError.persistenceFailure
        }
    }
}
