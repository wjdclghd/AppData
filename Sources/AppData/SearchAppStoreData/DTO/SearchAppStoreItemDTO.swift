//
//  SearchAppStoreItemDTO.swift
//  CleanArchitectureiOSApp
//
//  Created by jch on 3/18/26.
//

import Foundation

/*
 App Store 검색 및 상세 응답의 개별 항목을 표현하는 DTO입니다.

 이 타입은 원격 응답의 JSON 구조를 디코딩하기 위한 모델이며,
 Domain 엔터티와 달리 응답 스펙에 맞춘 optional 값과 원본 필드 이름을 유지합니다.
 Mapper는 이 DTO를 기반으로 AppDomain 엔터티를 생성합니다.
 */
public struct SearchAppStoreItemDTO: Codable, Equatable, Sendable {
    public let trackId: Int
    public let trackName: String?
    public let artistName: String?
    public let artworkUrl100: String?
    public let description: String?
    public let averageUserRating: Double?
    public let userRatingCount: Int?
    public let screenshotUrls: [String]?
    public let genres: [String]?

    public init(
        trackId: Int,
        trackName: String?,
        artistName: String?,
        artworkUrl100: String?,
        description: String?,
        averageUserRating: Double?,
        userRatingCount: Int?,
        screenshotUrls: [String]?,
        genres: [String]?
    ) {
        self.trackId = trackId
        self.trackName = trackName
        self.artistName = artistName
        self.artworkUrl100 = artworkUrl100
        self.description = description
        self.averageUserRating = averageUserRating
        self.userRatingCount = userRatingCount
        self.screenshotUrls = screenshotUrls
        self.genres = genres
    }
}
