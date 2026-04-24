//
//  SearchAppStoreListRepositoryTests.swift
//  AppDataTests
//
//  Created by jch on 4/15/26.
//

import XCTest
import AppDomain
@testable import AppData

/*
 SearchAppStoreListRepository의 목록 매핑과 도메인 오류 변환 동작을 검증하는 테스트입니다.

 이 테스트는 Mock data source를 사용하여 실제 원격 호출 없이,
 DTO 배열이 Domain 엔터티 배열로 올바르게 변환되는지,
 AppData 오류가 SearchAppStoreDomainError.temporarilyUnavailable로 정리되는지를 확인합니다.
 */
final class SearchAppStoreListRepositoryTests: XCTestCase {
    /*
     테스트에서 사용할 Mock data source 구현체입니다.

     호출 횟수, 마지막 검색어, stub 응답을 저장하여
     Repository가 data source를 통해 목록 조회를 올바르게 위임하는지 확인합니다.
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
     data source가 반환한 DTO 배열이 Domain 엔터티 배열로 변환되는지 검증합니다.

     Repository는 목록 DTO를 그대로 노출하지 않고,
     AppDomain의 SearchAppStoreListEntity 배열로 변환해 반환해야 합니다.
     */
    func test_fetchSearchAppStoreList_whenDataSourceSucceeds_returnsMappedEntities() async throws {
        let dataSource = MockSearchAppStoreDataSource()
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
        let repository = SearchAppStoreListRepository(dataSource: dataSource)

        let entities = try await repository.fetchSearchAppStoreList(searchKeyword: "chat")

        XCTAssertEqual(dataSource.fetchListCallCount, 1)
        XCTAssertEqual(dataSource.receivedSearchKeyword, "chat")
        XCTAssertEqual(entities.count, 2)
        XCTAssertEqual(entities[0].trackName, "ChatGPT")
        XCTAssertEqual(entities[1].trackName, "YouTube")
    }

    /*
     data source 오류가 temporarilyUnavailable로 변환되는지 검증합니다.

     호출부는 AppData 내부 오류를 직접 알 필요 없이,
     일시적인 목록 조회 실패라는 도메인 의미로 해석할 수 있어야 합니다.
     */
    func test_fetchSearchAppStoreList_whenDataSourceThrows_mapsToTemporarilyUnavailable() async {
        let dataSource = MockSearchAppStoreDataSource()
        dataSource.stubbedListResult = .failure(SearchAppStoreDataError.remoteFailure)
        let repository = SearchAppStoreListRepository(dataSource: dataSource)

        do {
            _ = try await repository.fetchSearchAppStoreList(searchKeyword: "chat")
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
