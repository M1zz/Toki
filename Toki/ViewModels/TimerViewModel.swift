//
//  TimerViewModel.swift
//  Toki
//
//  Created by POS on 8/25/25.
//

import SwiftUI

@MainActor
final class TimerViewModel: ObservableObject {
    @Published private(set) var state: TimerRunState = .idle
    @Published private(set) var remaining: TimeInterval = 0

    let engine = TimerEngine()
    var showToast: ((String) -> Void)?

    init() {
        engine.onTick = { [weak self] r in self?.remaining = r }
        engine.onPreAlert = { [weak self] sec in
            let min = sec / 60
            self?.showToast?("\(min)분 남았습니다")
        }
        engine.onFinish = { [weak self] in
            self?.state = .finished
            self?.showToast?("타이머 종료되었습니다")
        }
    }

    func configure(from template: Timer) {
        engine.configure(
            mainSeconds: template.mainSeconds,
            prealertOffsetsSec: template.prealertOffsetsSec
        )
        state = .idle
        remaining = TimeInterval(template.mainSeconds)
    }

    func start() {
        engine.start()
        state = .running
    }
    func pause() {
        engine.pause()
        state = .paused
    }
    func resume() {
        engine.resume()
        state = .running
    }
    func stop() {
        engine.stop()
        state = .idle
    }
}
