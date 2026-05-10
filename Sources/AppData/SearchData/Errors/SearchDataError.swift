//
//  SearchDataError.swift
//  AppData
//
//  Created by jch on 4/27/26.
//

import Foundation

/// Search data 계층 내부에서 사용하는 오류 타입입니다.
public enum SearchDataError: Error, Equatable, LocalizedError, Sendable {
    case persistenceFailure
    case searchEngineFailure

    public var errorDescription: String? {
        switch self {
        case .persistenceFailure:
            return "검색 기록 저장소를 사용할 수 없습니다."
        case .searchEngineFailure:
            return "검색 제안 데이터를 불러오지 못했습니다."
        }
    }
}
