//
//  SearchAppStoreDetailRepository.swift
//  AppData
//
//  Created by jch on 4/15/26.
//

import Foundation
import AppDomain

/*
 SearchAppStore 상세 조회 Repository 구현체입니다.

 이 타입은 SearchAppStoreDataSource로부터 상세 응답 DTO를 받아
 첫 번째 결과를 AppDomain의 상세 엔터티로 변환합니다.
 결과가 비어 있는 경우와 원격 실패는 각각 도메인 의미에 맞는 오류로 변환합니다.

 담당 역할
 - 상세 원격 조회 위임
 - 첫 번째 상세 결과를 상세 엔터티로 매핑
 - 비어 있는 상세 응답을 도메인 오류로 변환
 - AppData 오류를 도메인 오류로 변환

 담당하지 않는 역할
 - trackId 입력 검증
 - 화면 상태 관리
 - endpoint 조립 세부 구현
 */
public struct SearchAppStoreDetailRepository<DataSource: SearchAppStoreDataSourceProtocol>: SearchAppStoreDetailRepositoryProtocol, Sendable {
    private let dataSource: DataSource

    /*
     SearchAppStoreDetailRepository를 생성합니다.

     Parameters:
     - dataSource: 상세 원격 조회를 수행할 데이터 소스
     */
    public init(dataSource: DataSource) {
        self.dataSource = dataSource
    }

    /*
     trackId에 해당하는 앱 상세 정보를 조회합니다.

     Parameters:
     - trackId: 조회할 앱 식별자

     Returns:
     - SearchAppStoreDetailEntity

     Throws:
     - SearchAppStoreDomainError.appNotFound
     - SearchAppStoreDomainError.temporarilyUnavailable
     */
    public func fetchSearchAppStoreDetail(trackId: Int) async throws -> SearchAppStoreDetailEntity {
        do {
            let response = try await dataSource.fetchDetailResults(trackId: trackId)

            guard let item = response.results.first else {
                throw SearchAppStoreDataError.emptyDetailResponse
            }

            return SearchAppStoreDTOMapper.toDetailEntity(from: item)
        } catch let error as SearchAppStoreDomainError {
            throw error
        } catch let error as SearchAppStoreDataError {
            switch error {
            case .emptyDetailResponse:
                throw SearchAppStoreDomainError.appNotFound
            case .remoteFailure, .invalidResponse, .decodingFailure:
                throw SearchAppStoreDomainError.temporarilyUnavailable
            }
        } catch {
            throw SearchAppStoreDomainError.temporarilyUnavailable
        }
    }
}
