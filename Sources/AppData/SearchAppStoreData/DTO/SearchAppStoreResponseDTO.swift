//
//  SearchAppStoreResponseDTO.swift
//  AppData
//
//  Created by jch on 4/15/26.
//

import Foundation

/*
 App Store 검색 및 상세 API의 최상위 응답 DTO입니다.

 이 타입은 결과 개수와 개별 앱 항목 배열을 보관하며,
 Remote 계층이 원격 응답을 AppData 내부 모델로 전달할 때 사용합니다.
 */
public struct SearchAppStoreResponseDTO: Codable, Equatable, Sendable {
    public let resultCount: Int
    public let results: [SearchAppStoreItemDTO]

    public init(resultCount: Int, results: [SearchAppStoreItemDTO]) {
        self.resultCount = resultCount
        self.results = results
    }
}
