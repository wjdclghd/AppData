//
//  SearchAppStoreListRepositoryTests.swift
//  AppDataTests
//
//  Created by jch on 4/15/26.
//

import XCTest
import AppDomain
@testable import AppData

/// SearchAppStoreListRepository의 매핑과 도메인 오류 변환을 검증합니다.
final class SearchAppStoreListRepositoryTests: XCTestCase {

    // MARK: - Properties

    private var sut: SearchAppStoreListRepository<SpySearchAppStoreDataSource>!
    private var dataSource: SpySearchAppStoreDataSource!

    // MARK: - Setup

    override func setUpWithError() throws {
        try super.setUpWithError()
        dataSource = SpySearchAppStoreDataSource()
        sut = SearchAppStoreListRepository(dataSource: dataSource)
    }

    override func tearDownWithError() throws {
        sut = nil
        dataSource = nil
        try super.tearDownWithError()
    }

    // MARK: - Tests

    func test_fetchSearchAppStoreList_whenDataSourceSucceeds_returnsMappedEntities() async throws {
        // given
        dataSource.stubbedListResult = .success(
            SearchAppStoreResponseDTO(
                resultCount: 2,
                results: [
                    SearchAppStoreItemDTO(
                        trackId: 1,
                        trackName: "ChatGPT",
                        artistName: "OpenAI",
                        artworkUrl100: nil,
                        description: nil,
                        averageUserRating: 4.8,
                        userRatingCount: 100,
                        screenshotUrls: nil,
                        genres: nil
                    ),
                    SearchAppStoreItemDTO(
                        trackId: 2,
                        trackName: "YouTube",
                        artistName: "Google",
                        artworkUrl100: nil,
                        description: nil,
                        averageUserRating: 4.5,
                        userRatingCount: 200,
                        screenshotUrls: nil,
                        genres: nil
                    )
                ]
            )
        )

        // when
        let entities = try await sut.fetchSearchAppStoreList(searchKeyword: "chat")

        // then
        XCTAssertEqual(dataSource.fetchListCallCount, 1)
        XCTAssertEqual(dataSource.receivedSearchKeyword, "chat")
        XCTAssertEqual(entities.count, 2)
        XCTAssertEqual(entities[0].trackName, "ChatGPT")
        XCTAssertEqual(entities[1].trackName, "YouTube")
    }

    func test_fetchSearchAppStoreList_whenDataSourceThrows_mapsToTemporarilyUnavailable() async {
        // given
        dataSource.stubbedListResult = .failure(SearchAppStoreDataError.remoteFailure)

        // when / then
        do {
            _ = try await sut.fetchSearchAppStoreList(searchKeyword: "chat")
            XCTFail("Expected temporarilyUnavailable error")
        } catch let error as SearchAppStoreDomainError {
            guard case .temporarilyUnavailable = error else {
                return XCTFail("Expected temporarilyUnavailable, got \(error)")
            }

            XCTAssertEqual(dataSource.fetchListCallCount, 1)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
