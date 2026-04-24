//
//  SearchAppStoreDetailRepositoryTests.swift
//  AppDataTests
//
//  Created by jch on 4/15/26.
//

import XCTest
import AppDomain
@testable import AppData

/*
 SearchAppStoreDetailRepository의 상세 매핑과 도메인 오류 변환 동작을 검증하는 테스트입니다.

 이 테스트는 Mock data source를 사용하여 실제 원격 호출 없이,
 첫 번째 상세 DTO가 Domain 엔터티로 올바르게 변환되는지,
 비어 있는 응답이 SearchAppStoreDomainError.appNotFound로 정리되는지,
 AppData 오류가 SearchAppStoreDomainError.temporarilyUnavailable로 변환되는지를 확인합니다.
 */
final class SearchAppStoreDetailRepositoryTests: XCTestCase {
    /*
     테스트에서 사용할 Mock data source 구현체입니다.

     상세 조회 결과와 오류를 stub 형태로 저장하여,
     Repository가 원격 조회 결과를 도메인 의미에 맞게 변환하는지 확인합니다.
     */
    private final class MockSearchAppStoreDataSource: SearchAppStoreDataSourceProtocol, @unchecked Sendable {
        var fetchListCallCount = 0
        var fetchDetailCallCount = 0
        var receivedSearchKeyword: String?
        var receivedTrackId: Int?
        var stubbedListResult: Result<SearchAppStoreResponseDTO, Error> = .success(
            SearchAppStoreResponseDTO(resultCount: 0, results: [])
        )
        var stubbedDetailResult: Result<SearchAppStoreResponseDTO, Error> = .success(
            SearchAppStoreResponseDTO(resultCount: 0, results: [])
        )

        func fetchListResults(searchKeyword: String) async throws -> SearchAppStoreResponseDTO {
            fetchListCallCount += 1
            receivedSearchKeyword = searchKeyword
            return try stubbedListResult.get()
        }

        func fetchDetailResults(trackId: Int) async throws -> SearchAppStoreResponseDTO {
            fetchDetailCallCount += 1
            receivedTrackId = trackId
            return try stubbedDetailResult.get()
        }
    }

    /*
     상세 DTO 첫 번째 항목이 Domain 엔터티로 변환되는지 검증합니다.

     Repository는 상세 응답의 첫 번째 결과를 선택하여,
     상세 화면에서 사용할 SearchAppStoreDetailEntity로 반환해야 합니다.
     */
    func test_fetchSearchAppStoreDetail_whenDataSourceSucceeds_returnsMappedEntity() async throws {
        let dataSource = MockSearchAppStoreDataSource()
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
        let repository = SearchAppStoreDetailRepository(dataSource: dataSource)

        let entity = try await repository.fetchSearchAppStoreDetail(trackId: 100)

        XCTAssertEqual(dataSource.fetchDetailCallCount, 1)
        XCTAssertEqual(dataSource.receivedTrackId, 100)
        XCTAssertEqual(entity.trackId, 100)
        XCTAssertEqual(entity.trackName, "YouTube")
        XCTAssertEqual(entity.screenshotUrls, ["https://example.com/1.png"])
    }

    /*
     상세 응답 결과가 비어 있으면 appNotFound로 변환되는지 검증합니다.

     상세 화면은 최소한 하나의 앱 정보가 필요하므로,
     비어 있는 원격 응답은 도메인 의미상 앱 미존재로 해석되어야 합니다.
     */
    func test_fetchSearchAppStoreDetail_whenResponseIsEmpty_throwsAppNotFound() async {
        let dataSource = MockSearchAppStoreDataSource()
        dataSource.stubbedDetailResult = .success(
            SearchAppStoreResponseDTO(resultCount: 0, results: [])
        )
        let repository = SearchAppStoreDetailRepository(dataSource: dataSource)

        do {
            _ = try await repository.fetchSearchAppStoreDetail(trackId: 100)
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

    /*
     data source 오류가 temporarilyUnavailable로 변환되는지 검증합니다.

     호출부는 AppData 내부 오류를 직접 알 필요 없이,
     일시적인 상세 조회 실패라는 도메인 의미로 해석할 수 있어야 합니다.
     */
    func test_fetchSearchAppStoreDetail_whenDataSourceThrows_mapsToTemporarilyUnavailable() async {
        let dataSource = MockSearchAppStoreDataSource()
        dataSource.stubbedDetailResult = .failure(SearchAppStoreDataError.remoteFailure)
        let repository = SearchAppStoreDetailRepository(dataSource: dataSource)

        do {
            _ = try await repository.fetchSearchAppStoreDetail(trackId: 100)
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
