//
//  SearchAppStoreEndpoint.swift
//  AppData
//
//  Created by jch on 4/15/26.
//

import Foundation
import Networking

/*
 App Store API endpoint 구성을 담당하는 헬퍼입니다.

 이 타입은 SearchAppStore 기능에서 사용하는 path, method, query item을
 한곳에서 조합하여 Remote 계층이 일관된 요청을 생성하도록 돕습니다.
 */
enum SearchAppStoreEndpoint {
    private static let baseURL = URL(string: "https://itunes.apple.com")!

    /*
     검색 목록 조회 endpoint를 생성합니다.

     Parameters:
     - searchKeyword: 검색에 사용할 키워드

     Returns:
     - App Store search endpoint
     */
    static func list(searchKeyword: String) -> Endpoint {
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

    /*
     상세 조회 endpoint를 생성합니다.

     Parameters:
     - trackId: 조회할 앱 식별자

     Returns:
     - App Store lookup endpoint
     */
    static func detail(trackId: Int) -> Endpoint {
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
