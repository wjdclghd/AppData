//
//  SearchAppStoreDTOMapper.swift
//  AppData
//
//  Created by jch on 4/15/26.
//

import Foundation
import AppDomain

/*
 SearchAppStore DTO를 AppDomain 엔터티로 변환하는 Mapper입니다.

 Mapper는 원격 응답 전용 모델과 Domain 엔터티를 분리하여,
 Domain 계층이 응답 스펙 변화에 직접 노출되지 않도록 돕습니다.
 optional 값은 Domain에서 사용하기 쉬운 기본값으로 정규화합니다.
 */
enum SearchAppStoreDTOMapper {
    /*
     목록 응답 DTO를 목록 엔터티로 변환합니다.

     Parameters:
     - dto: 목록 항목으로 사용할 SearchAppStoreItemDTO

     Returns:
     - SearchAppStoreListEntity
     */
    static func toListEntity(from dto: SearchAppStoreItemDTO) -> SearchAppStoreListEntity {
        SearchAppStoreListEntity(
            trackId: dto.trackId,
            trackName: dto.trackName ?? "",
            artistName: dto.artistName ?? "",
            artworkUrl100: dto.artworkUrl100,
            averageUserRating: dto.averageUserRating,
            userRatingCount: dto.userRatingCount
        )
    }

    /*
     상세 응답 DTO를 상세 엔터티로 변환합니다.

     Parameters:
     - dto: 상세 항목으로 사용할 SearchAppStoreItemDTO

     Returns:
     - SearchAppStoreDetailEntity
     */
    static func toDetailEntity(from dto: SearchAppStoreItemDTO) -> SearchAppStoreDetailEntity {
        SearchAppStoreDetailEntity(
            trackId: dto.trackId,
            trackName: dto.trackName ?? "",
            artistName: dto.artistName ?? "",
            artworkUrl100: dto.artworkUrl100,
            description: dto.description,
            averageUserRating: dto.averageUserRating,
            userRatingCount: dto.userRatingCount,
            screenshotUrls: dto.screenshotUrls ?? [],
            genres: dto.genres ?? []
        )
    }
}
