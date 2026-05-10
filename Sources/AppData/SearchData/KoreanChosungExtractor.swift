//
//  KoreanChosungExtractor.swift
//  AppData
//
//  Created by jch on 5/8/26.
//

import Foundation

/// 한국어 텍스트에서 초성 시퀀스를 추출합니다.
enum KoreanChosungExtractor {

    // MARK: - Private

    private static let chosungList: [Character] = [
        "ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ",
        "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"
    ]

    // MARK: - Internal

    /// 한국어 텍스트에서 초성 시퀀스를 추출합니다.
    ///
    /// 한글 음절(U+AC00–U+D7A3) 각 글자의 초성을 추출해 이어 붙인 문자열을 반환합니다.
    /// 한글 음절이 아닌 문자는 무시합니다.
    ///
    /// - Parameter text: 초성을 추출할 한국어 텍스트입니다.
    /// - Returns: 초성 시퀀스 문자열입니다. 한글 음절이 없으면 빈 문자열을 반환합니다.
    static func extract(from text: String) -> String {
        text.unicodeScalars.compactMap { scalar -> Character? in
            let value = scalar.value
            guard value >= 0xAC00, value <= 0xD7A3 else { return nil }
            let index = Int((value - 0xAC00) / (21 * 28))
            return chosungList[index]
        }
        .map(String.init)
        .joined()
    }
}
