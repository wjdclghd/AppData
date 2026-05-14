//
//  SearchAppStoreEndpoint.swift
//  AppData
//
//  Created by jch on 4/15/26.
//

import Foundation
import Networking

/// App Store API endpoint를 구성합니다.
enum SearchAppStoreEndpoint {

    /// 검색 목록 조회 endpoint를 생성합니다.
    ///
    /// - Parameters:
    ///   - searchKeyword: 검색에 사용할 키워드입니다.
    ///   - baseURL: App Store API 서버 기준 URL입니다.
    /// - Returns: App Store search endpoint입니다.
    static func list(searchKeyword: String, baseURL: URL) -> Endpoint {
        Endpoint(
            baseURL: baseURL,
            path: "/search",
            method: .get,
            queryItems: [
                URLQueryItem(name: "term", value: searchKeyword),
                URLQueryItem(name: "country", value: "KR"),
                URLQueryItem(name: "media", value: "software"),
                URLQueryItem(name: "entity", value: "software")
            ]
        )
    }

    /// 상세 조회 endpoint를 생성합니다.
    ///
    /// - Parameters:
    ///   - trackId: 조회할 앱 식별자입니다.
    ///   - baseURL: App Store API 서버 기준 URL입니다.
    /// - Returns: App Store lookup endpoint입니다.
    static func detail(trackId: Int, baseURL: URL) -> Endpoint {
        Endpoint(
            baseURL: baseURL,
            path: "/lookup",
            method: .get,
            queryItems: [
                URLQueryItem(name: "id", value: String(trackId)),
                URLQueryItem(name: "country", value: "KR")
            ]
        )
    }
}
