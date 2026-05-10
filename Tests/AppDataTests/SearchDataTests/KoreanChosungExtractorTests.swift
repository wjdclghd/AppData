//
//  KoreanChosungExtractorTests.swift
//  AppData
//
//  Created by jch on 5/8/26.
//

import Foundation
import XCTest
@testable import AppData

/// KoreanChosungExtractor의 초성 추출 동작을 검증합니다.
final class KoreanChosungExtractorTests: XCTestCase {
    func test_extract_withSingleSyllable_returnsChosung() {
        // given / when
        let result = KoreanChosungExtractor.extract(from: "당")

        // then
        XCTAssertEqual(result, "ㄷ")
    }

    func test_extract_withMultipleSyllables_returnsChosungSequence() {
        // given / when
        let result = KoreanChosungExtractor.extract(from: "당근")

        // then
        XCTAssertEqual(result, "ㄷㄱ")
    }

    func test_extract_withKoreanWord_returnsCorrectChosung() {
        // given / when
        let result = KoreanChosungExtractor.extract(from: "음악")

        // then
        XCTAssertEqual(result, "ㅇㅇ")
    }

    func test_extract_withFourSyllables_returnsAllChosung() {
        // given / when
        let result = KoreanChosungExtractor.extract(from: "음력달력")

        // then
        XCTAssertEqual(result, "ㅇㄹㄷㄹ")
    }

    func test_extract_withNonKorean_returnsEmpty() {
        // given / when
        let result = KoreanChosungExtractor.extract(from: "YouTube")

        // then
        XCTAssertEqual(result, "")
    }

    func test_extract_withMixedText_returnsOnlyKoreanChosung() {
        // given / when
        let result = KoreanChosungExtractor.extract(from: "음악app")

        // then — 한글 음절만 추출하고 비한글 문자는 무시합니다
        XCTAssertEqual(result, "ㅇㅇ")
    }

    func test_extract_withEmptyString_returnsEmpty() {
        // given / when
        let result = KoreanChosungExtractor.extract(from: "")

        // then
        XCTAssertEqual(result, "")
    }

    func test_extract_withKoreanJamo_returnsEmpty() {
        // given / when — 자모(ㄷ)는 음절이 아니므로 추출 대상이 아닙니다
        let result = KoreanChosungExtractor.extract(from: "ㄷ")

        // then
        XCTAssertEqual(result, "")
    }
}
