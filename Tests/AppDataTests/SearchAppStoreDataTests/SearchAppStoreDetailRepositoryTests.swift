//
//  SearchAppStoreDetailRepositoryTests.swift
//  AppDataTests
//
//  Created by jch on 4/15/26.
//

import XCTest
import AppDomain
@testable import AppData

/// SearchAppStoreDetailRepository의 매핑과 도메인 오류 변환을 검증합니다.
final class SearchAppStoreDetailRepositoryTests: XCTestCase {

    // MARK: - Properties

    private var sut: SearchAppStoreDetailRepository<SpySearchAppStoreDataSource>!
    private var dataSource: SpySearchAppStoreDataSource!

    // MARK: - Setup

    override func setUpWithError() throws {
        try super.setUpWithError()
        dataSource = SpySearchAppStoreDataSource()
        sut = SearchAppStoreDetailRepository(dataSource: dataSource)
    }

    override func tearDownWithError() throws {
        sut = nil
        dataSource = nil
        try super.tearDownWithError()
    }

    // MARK: - Tests

    func test_fetchSearchAppStoreDetail_whenDataSourceSucceeds_returnsMappedEntity() async throws {
        // given
        dataSource.stubbedDetailResult = .success(
            SearchAppStoreResponseDTO(
                resultCount: 1,
                results: [
                    SearchAppStoreItemDTO(
                        trackId: 100,
                        trackName: "YouTube",
                        artistName: "Google",
                        artworkUrl100: "https://example.com/youtube.png",
                        description: "Video platform",
                        averageUserRating: 4.5,
                        userRatingCount: 300,
                        screenshotUrls: ["https://example.com/1.png"],
                        genres: ["Entertainment"]
                    )
                ]
            )
        )

        // when
        let entity = try await sut.fetchSearchAppStoreDetail(trackId: 100)

        // then
        XCTAssertEqual(dataSource.fetchDetailCallCount, 1)
        XCTAssertEqual(dataSource.receivedTrackId, 100)
        XCTAssertEqual(entity.trackId, 100)
        XCTAssertEqual(entity.trackName, "YouTube")
        XCTAssertEqual(entity.screenshotUrls, ["https://example.com/1.png"])
    }

    func test_fetchSearchAppStoreDetail_whenResponseIsEmpty_throwsAppNotFound() async {
        // given
        dataSource.stubbedDetailResult = .success(
            SearchAppStoreResponseDTO(resultCount: 0, results: [])
        )

        // when / then
        do {
            _ = try await sut.fetchSearchAppStoreDetail(trackId: 100)
            XCTFail("Expected appNotFound error")
        } catch let error as SearchAppStoreDomainError {
            guard case .appNotFound = error else {
                return XCTFail("Expected appNotFound, got \(error)")
            }

            XCTAssertEqual(dataSource.fetchDetailCallCount, 1)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_fetchSearchAppStoreDetail_whenDataSourceThrows_mapsToTemporarilyUnavailable() async {
        // given
        dataSource.stubbedDetailResult = .failure(SearchAppStoreDataError.remoteFailure)

        // when / then
        do {
            _ = try await sut.fetchSearchAppStoreDetail(trackId: 100)
            XCTFail("Expected temporarilyUnavailable error")
        } catch let error as SearchAppStoreDomainError {
            guard case .temporarilyUnavailable = error else {
                return XCTFail("Expected temporarilyUnavailable, got \(error)")
            }

            XCTAssertEqual(dataSource.fetchDetailCallCount, 1)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
