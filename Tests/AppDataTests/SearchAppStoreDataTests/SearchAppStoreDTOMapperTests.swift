//
//  SearchAppStoreDTOMapperTests.swift
//  AppDataTests
//
//  Created by jch on 4/15/26.
//

import XCTest
@testable import AppData
import AppDomain

/// SearchAppStoreDTOMapper의 DTO 변환을 검증합니다.
final class SearchAppStoreDTOMapperTests: XCTestCase {
    func test_toListEntity_withValidDTO_returnsMappedEntity() {
        // given
        let dto = SearchAppStoreItemDTO(
            trackId: 1,
            trackName: nil,
            artistName: nil,
            artworkUrl100: "https://example.com/icon.png",
            artworkUrl512: "https://example.com/icon-512.png",
            description: nil,
            averageUserRating: 4.8,
            userRatingCount: 100,
            screenshotUrls: nil,
            genres: nil
        )

        // when
        let entity = SearchAppStoreDTOMapper.toListEntity(from: dto)

        // then
        XCTAssertEqual(entity.trackId, 1)
        XCTAssertEqual(entity.trackName, "")
        XCTAssertEqual(entity.artistName, "")
        XCTAssertEqual(entity.artworkUrl100, "https://example.com/icon.png")
        XCTAssertEqual(entity.artworkUrl512, "https://example.com/icon-512.png")
        XCTAssertEqual(entity.averageUserRating, 4.8)
        XCTAssertEqual(entity.userRatingCount, 100)
    }

    func test_toDetailEntity_withValidDTO_returnsMappedEntity() {
        // given
        let dto = SearchAppStoreItemDTO(
            trackId: 10,
            trackName: "ChatGPT",
            artistName: "OpenAI",
            artworkUrl100: nil,
            artworkUrl512: "https://example.com/detail-512.png",
            description: "AI assistant",
            averageUserRating: 4.9,
            userRatingCount: 1000,
            screenshotUrls: nil,
            genres: nil
        )

        // when
        let entity = SearchAppStoreDTOMapper.toDetailEntity(from: dto)

        // then
        XCTAssertEqual(entity.trackId, 10)
        XCTAssertEqual(entity.trackName, "ChatGPT")
        XCTAssertEqual(entity.artistName, "OpenAI")
        XCTAssertEqual(entity.artworkUrl512, "https://example.com/detail-512.png")
        XCTAssertEqual(entity.description, "AI assistant")
        XCTAssertEqual(entity.averageUserRating, 4.9)
        XCTAssertEqual(entity.userRatingCount, 1000)
        XCTAssertEqual(entity.screenshotUrls, [])
        XCTAssertEqual(entity.genres, [])
    }
}
