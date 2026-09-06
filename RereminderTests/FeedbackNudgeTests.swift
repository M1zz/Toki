//
//  FeedbackNudgeTests.swift
//  RereminderTests
//
//  의견 요청 노출 정책 검증 — 너무 자주 물으면 짜증나고, 안 물으면 아무 말도 못 듣는다.
//  타이밍이 조용히 틀어지는 걸 막는 게 이 테스트의 목적이다.
//

import XCTest
@testable import Rereminder

final class FeedbackNudgeTests: XCTestCase {

    private let now = Date(timeIntervalSince1970: 1_800_000_000)

    // MARK: - 첫 노출

    /// ⚠️ 숫자를 박아 두지 말고 **상수를 참조한다.** 예전에는 10·40·50 이 그대로 적혀 있어,
    ///    정책을 바꾸는 순간 "정책이 틀렸다"가 아니라 "테스트가 깨졌다"가 됐다.
    ///    여기서 지키려는 건 특정 숫자가 아니라 **경계에서 정확히 한 칸 차이로 갈린다**는 규칙이다.
    func test_firstShow_waitsUntilThreshold() {
        let n = FeedbackNudge.firstLaunchThreshold
        XCTAssertFalse(FeedbackNudge.shouldShow(launchCount: n - 1, lastShownLaunch: 0, snoozedAt: nil, now: now))
        XCTAssertTrue(FeedbackNudge.shouldShow(launchCount: n, lastShownLaunch: 0, snoozedAt: nil, now: now))
    }

    /// 첫 질문이 너무 늦으면 아무 말도 못 듣는다 — 대부분의 사용자가 그전에 앱을 지운다.
    /// `launchCount` 는 프로세스 실행당 1 이라, 하루 한 번 여는 사용자에게 이 값은 곧 날수다.
    func test_firstShow_isNotTooLateToBeHeard() {
        XCTAssertLessThanOrEqual(FeedbackNudge.firstLaunchThreshold, 7,
                                 "하루 한 번 여는 사용자가 일주일 안에는 한 번 질문을 받아야 한다")
    }

    // MARK: - 반복 간격

    func test_repeatShow_needsAnotherInterval() {
        let gap = FeedbackNudge.launchInterval
        let last = FeedbackNudge.firstLaunchThreshold
        XCTAssertFalse(FeedbackNudge.shouldShow(launchCount: last + gap - 1,
                                                lastShownLaunch: last, snoozedAt: nil, now: now))
        XCTAssertTrue(FeedbackNudge.shouldShow(launchCount: last + gap,
                                               lastShownLaunch: last, snoozedAt: nil, now: now))
    }

    /// 반대쪽 벽 — 잔소리가 되면 이 기능은 실패다. 이 앱에는 양보 순서를 지키는 안내가
    /// 이미 여럿이라(기기 질문·반복 감지·창단 후원자·다음 자리 예약) 간격을 더 줄이면
    /// 앱을 열 때마다 무언가 뜨는 앱이 된다.
    func test_repeatInterval_staysPolite() {
        XCTAssertGreaterThanOrEqual(FeedbackNudge.launchInterval, 15,
                                    "너무 자주 물으면 물어본 것 자체가 불만이 된다")
    }

    // MARK: - 다시 보지 않기 = 6개월 유예

    func test_snooze_silencesForSixMonthsThenComesBack() {
        let justSnoozed = now.addingTimeInterval(-60 * 60 * 24 * 30)     // 한 달 전
        XCTAssertFalse(FeedbackNudge.shouldShow(launchCount: 999, lastShownLaunch: 0,
                                                snoozedAt: justSnoozed, now: now))

        let longAgo = now.addingTimeInterval(-FeedbackNudge.snoozeDuration - 1)
        XCTAssertTrue(FeedbackNudge.shouldShow(launchCount: 999, lastShownLaunch: 0,
                                               snoozedAt: longAgo, now: now),
                      "'다시 보지 않기'는 영구 중단이 아니라 유예다 — 6개월 뒤에는 다시 물어봐야 한다")
    }

    func test_snooze_doesNotOverrideIntervalRule() {
        // 유예가 풀렸어도 간격 조건은 여전히 지켜야 한다
        let longAgo = now.addingTimeInterval(-FeedbackNudge.snoozeDuration - 1)
        XCTAssertFalse(FeedbackNudge.shouldShow(launchCount: 10 + FeedbackNudge.launchInterval - 1,
                                                lastShownLaunch: 10,
                                                snoozedAt: longAgo, now: now))
    }
}
