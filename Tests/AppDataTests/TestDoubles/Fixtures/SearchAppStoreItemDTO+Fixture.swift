//
//  SearchAppStoreItemDTO+Fixture.swift
//  AppDataTests
//

@testable import AppData

extension SearchAppStoreItemDTO {
    static func fixture(
        trackId: Int = 1,
        trackName: String? = "ChatGPT",
        artistName: String? = "OpenAI",
        artworkUrl100: String? = nil,
        artworkUrl512: String? = nil,
        description: String? = nil,
        averageUserRating: Double? = 4.8,
        userRatingCount: Int? = 100,
        screenshotUrls: [String]? = nil,
        genres: [String]? = nil
    ) -> SearchAppStoreItemDTO {
        SearchAppStoreItemDTO(
            trackId: trackId,
            trackName: trackName,
            artistName: artistName,
            artworkUrl100: artworkUrl100,
            artworkUrl512: artworkUrl512,
            description: description,
            averageUserRating: averageUserRating,
            userRatingCount: userRatingCount,
            screenshotUrls: screenshotUrls,
            genres: genres
        )
    }
}
