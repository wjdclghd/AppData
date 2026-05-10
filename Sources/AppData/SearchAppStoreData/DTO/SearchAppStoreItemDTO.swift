//
//  SearchAppStoreItemDTO.swift
//  AppData
//
//  Created by jch on 3/18/26.
//

import Foundation

/// App Store 검색 및 상세 응답의 개별 항목 DTO입니다.
public struct SearchAppStoreItemDTO: Decodable, Sendable {
    public let trackId: Int
    public let trackName: String?
    public let artistName: String?
    public let artworkUrl100: String?
    public let artworkUrl512: String?
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
        artworkUrl512: String? = nil,
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
        self.artworkUrl512 = artworkUrl512
        self.description = description
        self.averageUserRating = averageUserRating
        self.userRatingCount = userRatingCount
        self.screenshotUrls = screenshotUrls
        self.genres = genres
    }
}
