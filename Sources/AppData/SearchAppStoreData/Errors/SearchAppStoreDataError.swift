//
//  SearchAppStoreDataError.swift
//  AppData
//
//  Created by jch on 4/15/26.
//

import Foundation

/*
 SearchAppStore data 계층 전용 오류 타입입니다.

 이 오류는 원격 데이터 소스 호출, 응답 해석, DTO 디코딩 과정에서
 AppData 모듈이 내부적으로 다루는 실패 상태를 표현합니다.
 Repository 구현체는 이 오류를 그대로 상위 계층에 노출하지 않고,
 AppDomain이 이해할 수 있는 도메인 오류로 변환해 전달합니다.

 담당 역할
 - 원격 호출 실패 표현
 - 응답 형식 이상 표현
 - 비어 있는 상세 응답 표현
 - 디코딩 실패 표현

 담당하지 않는 역할
 - Feature 계층 사용자 메시지 결정
 - 도메인 입력 검증
 - 화면 상태 관리
 */
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
