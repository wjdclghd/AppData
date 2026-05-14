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

/// SearchAppStoreDataSource의 endpoint 생성과 오류 매핑을 검증합니다.
final class SearchAppStoreDataSourceTests: XCTestCase {
    private enum TestFailure: Error {
        case expected
    }

    // MARK: - Properties

    private var sut: SearchAppStoreDataSource<SpyNetworkClient>!
    private var networkClient: SpyNetworkClient!

    // MARK: - Setup

    override func setUpWithError() throws {
        try super.setUpWithError()
        networkClient = SpyNetworkClient()
        sut = SearchAppStoreDataSource(
            networkClient: networkClient,
            baseURL: URL(string: "https://itunes.apple.com")!
        )
    }

    override func tearDownWithError() throws {
        sut = nil
        networkClient = nil
        try super.tearDownWithError()
    }

    // MARK: - Tests

    func test_fetchListResults_requestsSearchEndpointAndReturnsDTO() async throws {
        // given
        networkClient.stubbedResponseData = try makeResponseData(
            resultCount: 1,
            results: [
                makeItemJSON(
                    trackId: 1,
                    trackName: "ChatGPT",
                    artistName: "OpenAI",
                    averageUserRating: 4.8,
                    userRatingCount: 100
                )
            ]
        )

        // when
        let response = try await sut.fetchListResults(searchKeyword: "chatgpt")

        // then
        XCTAssertEqual(networkClient.receivedEndpoint?.path, "/search")
        XCTAssertEqual(networkClient.receivedEndpoint?.method, .get)
        XCTAssertEqual(queryValue(named: "term", in: networkClient.receivedEndpoint?.queryItems), "chatgpt")
        XCTAssertEqual(queryValue(named: "country", in: networkClient.receivedEndpoint?.queryItems), "KR")
        XCTAssertEqual(queryValue(named: "media", in: networkClient.receivedEndpoint?.queryItems), "software")
        XCTAssertEqual(queryValue(named: "entity", in: networkClient.receivedEndpoint?.queryItems), "software")
        XCTAssertEqual(response.resultCount, 1)
        XCTAssertEqual(response.results.first?.trackName, "ChatGPT")
    }

    func test_fetchDetailResults_requestsLookupEndpointAndReturnsDTO() async throws {
        // given
        networkClient.stubbedResponseData = try makeResponseData(
            resultCount: 1,
            results: [
                makeItemJSON(
                    trackId: 100,
                    trackName: "YouTube",
                    artistName: "Google",
                    description: "Video",
                    averageUserRating: 4.5,
                    userRatingCount: 1000,
                    screenshotUrls: [],
                    genres: ["Entertainment"]
                )
            ]
        )

        // when
        let response = try await sut.fetchDetailResults(trackId: 100)

        // then
        XCTAssertEqual(networkClient.receivedEndpoint?.path, "/lookup")
        XCTAssertEqual(networkClient.receivedEndpoint?.method, .get)
        XCTAssertEqual(queryValue(named: "id", in: networkClient.receivedEndpoint?.queryItems), "100")
        XCTAssertEqual(queryValue(named: "country", in: networkClient.receivedEndpoint?.queryItems), "KR")
        XCTAssertEqual(response.resultCount, 1)
        XCTAssertEqual(response.results.first?.trackId, 100)
    }

    func test_fetchListResults_whenNetworkClientThrowsEmptyResponse_mapsToInvalidResponse() async {
        // given
        networkClient.stubbedError = NetworkError.emptyResponse

        // when / then
        do {
            _ = try await sut.fetchListResults(searchKeyword: "chatgpt")
            XCTFail("Expected invalidResponse error")
        } catch let error as SearchAppStoreDataError {
            guard case .invalidResponse = error else {
                return XCTFail("Expected invalidResponse, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_fetchDetailResults_whenNetworkClientThrowsDecoding_mapsToDecodingFailure() async {
        // given
        networkClient.stubbedError = NetworkError.decoding(TestFailure.expected)

        // when / then
        do {
            _ = try await sut.fetchDetailResults(trackId: 1)
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

// MARK: - Helpers

private extension SearchAppStoreDataSourceTests {
    func makeResponseData(
        resultCount: Int,
        results: [[String: Any]]
    ) throws -> Data {
        let json: [String: Any] = ["resultCount": resultCount, "results": results]
        return try JSONSerialization.data(withJSONObject: json)
    }

    func makeItemJSON(
        trackId: Int,
        trackName: String? = nil,
        artistName: String? = nil,
        artworkUrl100: String? = nil,
        artworkUrl512: String? = nil,
        description: String? = nil,
        averageUserRating: Double? = nil,
        userRatingCount: Int? = nil,
        screenshotUrls: [String]? = nil,
        genres: [String]? = nil
    ) -> [String: Any] {
        var dict: [String: Any] = ["trackId": trackId]
        if let v = trackName { dict["trackName"] = v }
        if let v = artistName { dict["artistName"] = v }
        if let v = artworkUrl100 { dict["artworkUrl100"] = v }
        if let v = artworkUrl512 { dict["artworkUrl512"] = v }
        if let v = description { dict["description"] = v }
        if let v = averageUserRating { dict["averageUserRating"] = v }
        if let v = userRatingCount { dict["userRatingCount"] = v }
        if let v = screenshotUrls { dict["screenshotUrls"] = v }
        if let v = genres { dict["genres"] = v }
        return dict
    }

    func queryValue(named name: String, in queryItems: [URLQueryItem]?) -> String? {
        queryItems?.first { $0.name == name }?.value
    }
}
