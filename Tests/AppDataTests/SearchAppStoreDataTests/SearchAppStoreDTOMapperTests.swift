//
//  SearchAppStoreDTOMapperTests.swift
//  AppDataTests
//
//  Created by jch on 4/15/26.
//

import XCTest
@testable import AppData
import AppDomain

/*
 SearchAppStoreDTOMapper의 DTO -> Entity 변환 동작을 검증하는 테스트입니다.

 이 테스트는 원격 응답 DTO가 Domain 엔터티로 변환될 때,
 nil 값을 안정적인 기본값으로 정규화하는지,
 목록과 상세 화면에 필요한 필드가 올바르게 전달되는지를 확인합니다.
 */
final class SearchAppStoreDTOMapperTests: XCTestCase {
    /*
     목록 DTO의 optional 문자열과 숫자 값이 Entity로 올바르게 매핑되는지 검증합니다.

     trackName과 artistName이 nil이면 빈 문자열로 정규화되어야 하며,
     목록 화면에 필요한 식별자와 평점 정보는 그대로 전달되어야 합니다.
     */
    func test_toListEntity_mapsDTOToEntity() {
        let dto = SearchAppStoreItemDTO(
            trackId: 1,
            trackName: nil,
            artistName: nil,
            artworkUrl100: "https://example.com/icon.png",
            description: nil,
            averageUserRating: 4.8,
            userRatingCount: 100,
            screenshotUrls: nil,
            genres: nil
        )

        let entity = SearchAppStoreDTOMapper.toListEntity(from: dto)

        XCTAssertEqual(entity.trackId, 1)
        XCTAssertEqual(entity.trackName, "")
        XCTAssertEqual(entity.artistName, "")
        XCTAssertEqual(entity.artworkUrl100, "https://example.com/icon.png")
        XCTAssertEqual(entity.averageUserRating, 4.8)
        XCTAssertEqual(entity.userRatingCount, 100)
    }

    /*
     상세 DTO의 optional 배열과 문자열이 Entity로 올바르게 매핑되는지 검증합니다.

     screenshotUrls와 genres가 nil이면 빈 배열로 정규화되어야 하며,
     상세 화면에 필요한 설명과 평점 정보가 손실 없이 전달되어야 합니다.
     */
    func test_toDetailEntity_mapsDTOToEntity() {
        let dto = SearchAppStoreItemDTO(
            trackId: 10,
            trackName: "ChatGPT",
            artistName: "OpenAI",
            artworkUrl100: nil,
            description: "AI assistant",
            averageUserRating: 4.9,
            userRatingCount: 1000,
            screenshotUrls: nil,
            genres: nil
        )

        let entity = SearchAppStoreDTOMapper.toDetailEntity(from: dto)

        XCTAssertEqual(entity.trackId, 10)
        XCTAssertEqual(entity.trackName, "ChatGPT")
        XCTAssertEqual(entity.artistName, "OpenAI")
        XCTAssertEqual(entity.description, "AI assistant")
        XCTAssertEqual(entity.averageUserRating, 4.9)
        XCTAssertEqual(entity.userRatingCount, 1000)
        XCTAssertEqual(entity.screenshotUrls, [])
        XCTAssertEqual(entity.genres, [])
    }
}
