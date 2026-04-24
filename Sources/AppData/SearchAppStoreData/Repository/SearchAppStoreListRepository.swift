//
//  SearchAppStoreListRepository.swift
//  AppData
//
//  Created by jch on 4/15/26.
//

import Foundation
import AppDomain

/*
 SearchAppStore 목록 조회 Repository 구현체입니다.

 이 타입은 SearchAppStoreDataSource로부터 원격 응답 DTO를 받아
 AppDomain의 목록 엔터티로 매핑한 뒤 반환합니다.
 AppData 내부 오류는 상위 계층이 해석할 수 있는 도메인 오류로 변환합니다.

 담당 역할
 - 목록 원격 조회 위임
 - DTO 배열을 목록 엔터티 배열로 매핑
 - AppData 오류를 도메인 오류로 변환

 담당하지 않는 역할
 - 검색어 trim 및 입력 검증
 - 화면 상태 관리
 - endpoint 조립 세부 구현
 */
public struct SearchAppStoreListRepository<DataSource: SearchAppStoreDataSourceProtocol>: SearchAppStoreListRepositoryProtocol, Sendable {
    private let dataSource: DataSource

    /*
     SearchAppStoreListRepository를 생성합니다.

     Parameters:
     - dataSource: 목록 원격 조회를 수행할 데이터 소스
     */
    public init(dataSource: DataSource) {
        self.dataSource = dataSource
    }

    /*
     검색어에 해당하는 앱 목록을 조회합니다.

     Parameters:
     - searchKeyword: 검색에 사용할 키워드

     Returns:
     - 목록 화면 구성을 위한 SearchAppStoreListEntity 배열

     Throws:
     - SearchAppStoreDomainError.temporarilyUnavailable
     */
    public func fetchSearchAppStoreList(searchKeyword: String) async throws -> [SearchAppStoreListEntity] {
        do {
            let response = try await dataSource.fetchListResults(searchKeyword: searchKeyword)
            return response.results.map(SearchAppStoreDTOMapper.toListEntity(from:))
        } catch let error as SearchAppStoreDomainError {
            throw error
        } catch let error as SearchAppStoreDataError {
            switch error {
            case .remoteFailure, .invalidResponse, .decodingFailure, .emptyDetailResponse:
                throw SearchAppStoreDomainError.temporarilyUnavailable
            }
        } catch {
            throw SearchAppStoreDomainError.temporarilyUnavailable
        }
    }
}
