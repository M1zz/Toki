//
//  TimerViewModel.swift
//  Toki
//
//  Created by POS on 8/25/25.
//

import SwiftUI

@MainActor
final class TimerViewModel: ObservableObject {
    @Published private(set) var state: TimerState = .idle
    @Published private(set) var remaining: TimeInterval = 0

    let engine = TimerEngine()
    var showToast: ((String) -> Void)?
    var appStateManager: AppStateManager?

    init() {
        engine.onTick = { [weak self] r in self?.remaining = r }
        engine.onPreAlert = { [weak self] sec in
            let min = sec / 60
            ring()
            let message = "\(min)분 남았습니다"
            self?.showToast?(message)
            self?.appStateManager?.sendNotificationIfNeeded(message)
        }
        engine.onFinish = { [weak self] in
            self?.state = .finished
            ring()
            let message = "타이머 종료되었습니다"
            self?.showToast?(message)
            self?.appStateManager?.sendNotificationIfNeeded(message)
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
