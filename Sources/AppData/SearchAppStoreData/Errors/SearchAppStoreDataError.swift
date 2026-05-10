//
//  SearchAppStoreDataError.swift
//  AppData
//
//  Created by jch on 4/15/26.
//

import Foundation

/// SearchAppStore data 계층 내부에서 사용하는 오류 타입입니다.
public enum SearchAppStoreDataError: Error, Equatable, LocalizedError, Sendable {
    case remoteFailure
    case invalidResponse
    case decodingFailure
    case emptyDetailResponse

    public var errorDescription: String? {
        switch self {
        case .remoteFailure:
            return "원격 데이터를 불러오지 못했습니다."
        case .invalidResponse:
            return "응답 형식이 올바르지 않습니다."
        case .decodingFailure:
            return "응답 데이터를 해석하지 못했습니다."
        case .emptyDetailResponse:
            return "상세 조회 결과가 비어 있습니다."
        }
    }
}
