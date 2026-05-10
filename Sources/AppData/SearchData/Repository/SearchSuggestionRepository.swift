//
//  SearchSuggestionRepository.swift
//  AppData
//
//  Created by jch on 4/27/26.
//

import Foundation
import AppDomain

/// 검색바 자동완성 Repository 구현체입니다.
public struct SearchSuggestionRepository<DataSource: SearchSuggestionDataSourceProtocol>: SearchSuggestionRepositoryProtocol, Sendable {
    private let dataSource: DataSource

    /// SearchSuggestionRepository를 생성합니다.
    ///
    /// - Parameter dataSource: 자동완성 제안을 조회할 데이터 소스입니다.
    public init(dataSource: DataSource) {
        self.dataSource = dataSource
    }

    /// 기본 추천 검색어 목록을 조회합니다.
    ///
    /// - Parameter limit: 최대 반환 개수입니다.
    /// - Returns: 기본 추천 검색어 UI 구성을 위한 `SearchSuggestionEntity` 배열입니다.
    /// - Throws: `SearchDomainError.suggestionUnavailable`를 던집니다.
    public func fetchDefaultSuggestions(limit: Int) async throws -> [SearchSuggestionEntity] {
        do {
            let suggestions = try await dataSource.fetchDefaultSuggestions(limit: limit)
            return suggestions.map(SearchSuggestionMapper.toEntity(from:))
        } catch let error as SearchDomainError {
            throw error
        } catch {
            throw SearchDomainError.suggestionUnavailable
        }
    }

    /// 검색어에 해당하는 자동완성 제안 목록을 조회합니다.
    ///
    /// - Parameters:
    ///   - keyword: 자동완성 제안 조회에 사용할 검색어입니다.
    ///   - limit: 최대 반환 개수입니다.
    /// - Returns: 자동완성 UI 구성을 위한 `SearchSuggestionEntity` 배열입니다.
    /// - Throws: `SearchDomainError.suggestionUnavailable`를 던집니다.
    public func fetchSuggestions(
        keyword: String,
        limit: Int
    ) async throws -> [SearchSuggestionEntity] {
        do {
            let suggestions = try await dataSource.fetchSuggestions(
                keyword: keyword,
                limit: limit
            )
            return suggestions.map(SearchSuggestionMapper.toEntity(from:))
        } catch let error as SearchDomainError {
            throw error
        } catch {
            throw SearchDomainError.suggestionUnavailable
        }
    }
}
