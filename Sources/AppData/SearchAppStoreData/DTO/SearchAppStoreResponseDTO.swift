//
//  SearchAppStoreResponseDTO.swift
//  AppData
//
//  Created by jch on 4/15/26.
//

import Foundation

/// App Store 검색 및 상세 API의 최상위 응답 DTO입니다.
public struct SearchAppStoreResponseDTO: Decodable, Sendable {
    public let resultCount: Int
    public let results: [SearchAppStoreItemDTO]

    public init(resultCount: Int, results: [SearchAppStoreItemDTO]) {
        self.resultCount = resultCount
        self.results = results
    }
}
