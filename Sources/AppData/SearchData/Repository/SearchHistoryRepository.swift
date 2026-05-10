//
//  SearchHistoryRepository.swift
//  AppData
//
//  Created by jch on 4/27/26.
//

import Foundation
import AppDomain

/// 최근 검색어 Repository 구현체입니다.
public struct SearchHistoryRepository<DataSource: SearchHistoryDataSourceProtocol>: SearchHistoryRepositoryProtocol, Sendable {
    private let dataSource: DataSource
    private let now: @Sendable () -> Date

    /// SearchHistoryRepository를 생성합니다.
    ///
    /// - Parameters:
    ///   - dataSource: 최근 검색어 로컬 데이터를 조회하고 저장할 데이터 소스입니다.
    ///   - now: 최근 검색어 저장 시각을 제공하는 클로저입니다.
    public init(
        dataSource: DataSource,
        now: @escaping @Sendable () -> Date = { Date() }
    ) {
        self.dataSource = dataSource
        self.now = now
    }

    /// 최근 검색어 목록을 조회합니다.
    ///
    /// - Returns: 최근 검색어 UI 구성을 위한 `SearchHistoryEntity` 배열입니다.
    /// - Throws: `SearchDomainError.historyUnavailable`를 던집니다.
    public func fetchRecentHistory() async throws -> [SearchHistoryEntity] {
        do {
            let records = try await dataSource.fetchRecentHistory()
            return records.map(SearchHistoryRecordMapper.toEntity(from:))
        } catch let error as SearchDomainError {
            throw error
        } catch {
            throw SearchDomainError.historyUnavailable
        }
    }

    /// 최근 검색어를 저장합니다.
    ///
    /// - Parameter keyword: 저장할 검색어입니다.
    /// - Throws: `SearchDomainError.historyUnavailable`를 던집니다.
    public func saveHistory(keyword: String) async throws {
        do {
            try await dataSource.saveHistory(
                keyword: keyword,
                searchedAt: now()
            )
        } catch let error as SearchDomainError {
            throw error
        } catch {
            throw SearchDomainError.historyUnavailable
        }
    }

    /// 특정 검색 기록을 삭제합니다.
    ///
    /// - Parameter id: 삭제할 검색 기록 식별자입니다.
    /// - Throws: `SearchDomainError.historyUnavailable`를 던집니다.
    public func deleteHistory(id: String) async throws {
        do {
            try await dataSource.deleteHistory(keyword: id)
        } catch let error as SearchDomainError {
            throw error
        } catch {
            throw SearchDomainError.historyUnavailable
        }
    }

    /// 모든 최근 검색어를 삭제합니다.
    ///
    /// - Throws: `SearchDomainError.historyUnavailable`를 던집니다.
    public func clearHistory() async throws {
        do {
            try await dataSource.clearHistory()
        } catch let error as SearchDomainError {
            throw error
        } catch {
            throw SearchDomainError.historyUnavailable
        }
    }
}
