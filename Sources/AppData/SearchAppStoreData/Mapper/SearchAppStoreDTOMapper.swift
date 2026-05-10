//
//  SearchAppStoreDTOMapper.swift
//  AppData
//
//  Created by jch on 4/15/26.
//

import Foundation
import AppDomain

/// SearchAppStore DTO를 AppDomain 엔터티로 변환합니다.
enum SearchAppStoreDTOMapper {
    /// 목록 응답 DTO를 목록 엔터티로 변환합니다.
    ///
    /// - Parameter dto: 목록 항목으로 사용할 `SearchAppStoreItemDTO`입니다.
    /// - Returns: `SearchAppStoreListEntity`입니다.
    static func toListEntity(from dto: SearchAppStoreItemDTO) -> SearchAppStoreListEntity {
        SearchAppStoreListEntity(
            trackId: dto.trackId,
            trackName: dto.trackName ?? "",
            artistName: dto.artistName ?? "",
            artworkUrl100: dto.artworkUrl100,
            artworkUrl512: dto.artworkUrl512,
            averageUserRating: dto.averageUserRating,
            userRatingCount: dto.userRatingCount
        )
    }

    /// 상세 응답 DTO를 상세 엔터티로 변환합니다.
    ///
    /// - Parameter dto: 상세 항목으로 사용할 `SearchAppStoreItemDTO`입니다.
    /// - Returns: `SearchAppStoreDetailEntity`입니다.
    static func toDetailEntity(from dto: SearchAppStoreItemDTO) -> SearchAppStoreDetailEntity {
        SearchAppStoreDetailEntity(
            trackId: dto.trackId,
            trackName: dto.trackName ?? "",
            artistName: dto.artistName ?? "",
            artworkUrl100: dto.artworkUrl100,
            artworkUrl512: dto.artworkUrl512,
            description: dto.description,
            averageUserRating: dto.averageUserRating,
            userRatingCount: dto.userRatingCount,
            screenshotUrls: dto.screenshotUrls ?? [],
            genres: dto.genres ?? []
        )
    }
}
