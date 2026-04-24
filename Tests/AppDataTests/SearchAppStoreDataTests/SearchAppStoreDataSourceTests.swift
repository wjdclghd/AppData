//
//  SearchAppStoreDataSourceTests.swift
//  AppDataTests
//
//  Created by jch on 4/15/26.
//

import Foundation
import XCTest
import Networking
@testable import AppData

/*
 SearchAppStoreDataSource의 endpoint 생성, 원격 조회, AppData 오류 매핑 동작을 검증하는 테스트입니다.

 이 테스트는 Mock network client를 사용하여 실제 네트워크 호출 없이,
 목록과 상세 조회가 올바른 endpoint로 요청되는지,
 Networking 오류가 SearchAppStoreDataError로 정리되는지를 확인합니다.
 */
final class SearchAppStoreDataSourceTests: XCTestCase {
    /*
     테스트에서 발생시키는 의도적인 디코딩 실패를 표현하는 에러 타입입니다.

     SearchAppStoreDataSource가 Networking의 디코딩 오류를
     SearchAppStoreDataError.decodingFailure로 변환하는지 검증하기 위해 사용합니다.
     */
    private enum TestFailure: Error {
        case expected
    }

    /*
     테스트에서 사용할 Mock NetworkClient 구현체입니다.

     마지막 endpoint와 stub 응답 데이터를 저장하여,
     SearchAppStoreDataSource가 올바른 endpoint를 생성하고 DTO 디코딩까지 수행하는지 확인합니다.
     */
    private final class MockNetworkClient: NetworkClientProtocol, @unchecked Sendable {
        var receivedEndpoint: Endpoint?
        var stubbedResponseData: Data = Data()
        var stubbedError: Error?

        func request<Response: Decodable & Sendable>(
            _ endpoint: Endpoint,
            as responseType: Response.Type
        ) async throws -> Response {
            receivedEndpoint = endpoint

            if let stubbedError {
                throw stubbedError
            }

            return try JSONDecoder().decode(Response.self, from: stubbedResponseData)
        }

        func request(_ endpoint: Endpoint) async throws -> Data {
            receivedEndpoint = endpoint

            if let stubbedError {
                throw stubbedError
            }

            return stubbedResponseData
        }
    }

    /*
     목록 조회가 search endpoint로 요청되고 DTO가 반환되는지 검증합니다.

     term, country, media, entity query item이 기대한 값으로 구성되어야 하며,
     resultCount와 results도 디코딩 결과 그대로 반환되어야 합니다.
     */
    func test_fetchListResults_requestsSearchEndpointAndReturnsDTO() async throws {
        let networkClient = MockNetworkClient()
        networkClient.stubbedResponseData = try makeResponseData(
            resultCount: 1,
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
                )
            ]
        )
        let dataSource = SearchAppStoreDataSource(networkClient: networkClient)

        let response = try await dataSource.fetchListResults(searchKeyword: "chatgpt")

        XCTAssertEqual(networkClient.receivedEndpoint?.path, "/search")
        XCTAssertEqual(networkClient.receivedEndpoint?.method, .get)
        XCTAssertEqual(queryValue(named: "term", in: networkClient.receivedEndpoint?.queryItems), "chatgpt")
        XCTAssertEqual(queryValue(named: "country", in: networkClient.receivedEndpoint?.queryItems), "KR")
        XCTAssertEqual(queryValue(named: "media", in: networkClient.receivedEndpoint?.queryItems), "software")
        XCTAssertEqual(queryValue(named: "entity", in: networkClient.receivedEndpoint?.queryItems), "software")
        XCTAssertEqual(response.resultCount, 1)
        XCTAssertEqual(response.results.first?.trackName, "ChatGPT")
    }

    /*
     상세 조회가 lookup endpoint로 요청되고 DTO가 반환되는지 검증합니다.

     id와 country query item이 기대한 값으로 구성되어야 하며,
     상세 조회 응답도 디코딩 결과 그대로 반환되어야 합니다.
     */
    func test_fetchDetailResults_requestsLookupEndpointAndReturnsDTO() async throws {
        let networkClient = MockNetworkClient()
        networkClient.stubbedResponseData = try makeResponseData(
            resultCount: 1,
            results: [
                SearchAppStoreItemDTO(
                    trackId: 100,
                    trackName: "YouTube",
                    artistName: "Google",
                    artworkUrl100: nil,
                    description: "Video",
                    averageUserRating: 4.5,
                    userRatingCount: 1000,
                    screenshotUrls: [],
                    genres: ["Entertainment"]
                )
            ]
        )
        let dataSource = SearchAppStoreDataSource(networkClient: networkClient)

        let response = try await dataSource.fetchDetailResults(trackId: 100)

        XCTAssertEqual(networkClient.receivedEndpoint?.path, "/lookup")
        XCTAssertEqual(networkClient.receivedEndpoint?.method, .get)
        XCTAssertEqual(queryValue(named: "id", in: networkClient.receivedEndpoint?.queryItems), "100")
        XCTAssertEqual(queryValue(named: "country", in: networkClient.receivedEndpoint?.queryItems), "KR")
        XCTAssertEqual(response.resultCount, 1)
        XCTAssertEqual(response.results.first?.trackId, 100)
    }

    /*
     Networking의 emptyResponse 오류가 SearchAppStoreDataError.invalidResponse로 변환되는지 검증합니다.

     Remote 계층은 네트워크 모듈의 구체 오류를 직접 노출하지 않고,
     AppData 기준 오류로 정리해 Repository 계층에 전달해야 합니다.
     */
    func test_fetchListResults_whenNetworkClientThrowsEmptyResponse_mapsToInvalidResponse() async {
        let networkClient = MockNetworkClient()
        networkClient.stubbedError = NetworkError.emptyResponse
        let dataSource = SearchAppStoreDataSource(networkClient: networkClient)

        do {
            _ = try await dataSource.fetchListResults(searchKeyword: "chatgpt")
            XCTFail("Expected invalidResponse error")
        } catch let error as SearchAppStoreDataError {
            guard case .invalidResponse = error else {
                return XCTFail("Expected invalidResponse, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    /*
     Networking의 decoding 오류가 SearchAppStoreDataError.decodingFailure로 변환되는지 검증합니다.

     DTO 해석 실패는 AppData 계층의 데이터 해석 실패로 정리되어야 하며,
     상위 계층은 Networking 오류 세부사항에 직접 의존하지 않아야 합니다.
     */
    func test_fetchDetailResults_whenNetworkClientThrowsDecoding_mapsToDecodingFailure() async {
        let networkClient = MockNetworkClient()
        networkClient.stubbedError = NetworkError.decoding(TestFailure.expected)
        let dataSource = SearchAppStoreDataSource(networkClient: networkClient)

        do {
            _ = try await dataSource.fetchDetailResults(trackId: 1)
            XCTFail("Expected decodingFailure error")
        } catch let error as SearchAppStoreDataError {
            guard case .decodingFailure = error else {
                return XCTFail("Expected decodingFailure, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

private extension SearchAppStoreDataSourceTests {
    /*
     SearchAppStoreResponseDTO를 JSON Data로 인코딩하는 테스트 헬퍼입니다.

     Parameters:
     - resultCount: 응답 결과 개수
     - results: 응답 항목 배열

     Returns:
     - JSONEncoder로 인코딩한 Data
     */
    func makeResponseData(
        resultCount: Int,
        results: [SearchAppStoreItemDTO]
    ) throws -> Data {
        try JSONEncoder().encode(
            SearchAppStoreResponseDTO(
                resultCount: resultCount,
                results: results
            )
        )
    }

    /*
     query item 배열에서 특정 이름의 값을 조회하는 테스트 헬퍼입니다.

     Parameters:
     - name: 찾을 query item 이름
     - queryItems: 조회할 query item 배열

     Returns:
     - 일치하는 값 또는 nil
     */
    func queryValue(named name: String, in queryItems: [URLQueryItem]?) -> String? {
        queryItems?.first { $0.name == name }?.value
    }
}
