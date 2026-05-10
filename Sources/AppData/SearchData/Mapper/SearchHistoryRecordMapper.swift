//
//  SearchHistoryRecordMapper.swift
//  AppData
//
//  Created by jch on 4/27/26.
//

import Foundation
import AppDomain
import Persistence

/// SearchHistoryRecord를 AppDomain 엔터티로 변환합니다.
enum SearchHistoryRecordMapper {
    /// Persistence 검색 기록 모델을 Domain 엔터티로 변환합니다.
    ///
    /// - Parameter record: Persistence 모듈에서 조회한 검색 기록 값입니다.
    /// - Returns: `SearchHistoryEntity`입니다.
    static func toEntity(from record: SearchHistoryRecord) -> SearchHistoryEntity {
        SearchHistoryEntity(
            id: record.keyword,
            keyword: record.keyword,
            lastSearchedAt: record.lastSearchedAt
        )
    }
}
