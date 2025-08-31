//
//  TimerScreenViewModel.swift
//  Toki
//
//  Created by xa on 8/27/25.
//

import Combine
import Foundation
import SwiftData
import SwiftUI

@MainActor
final class TimerScreenViewModel: ObservableObject {
    @Published var mainMinutes: Int = 10
    @Published var mainSeconds: Int = 0
    @Published var selectedOffsets: Set<Int> = [60, 180, 300]  // prealert settings
    @Published private(set) var configuredMainSeconds: Int = 600

    let timerVM: TimerViewModel

    private var context: ModelContext?
    private var bag = Set<AnyCancellable>()

    // broadcast 'timerVM' to 'ContentView'
    init(timerVM: TimerViewModel? = nil) {
        let vm = timerVM ?? TimerViewModel()
        self.timerVM = vm

        vm.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &bag)
    }

    func attachContext(_ ctx: ModelContext) {
        self.context = ctx
    }

    var state: TimerState { timerVM.state }
    var remaining: TimeInterval { timerVM.remaining }

    /// 앱 진입시 표시될 타이머 세팅
    func initialConfiguration() {
        justConfigure(save: false, toast: false)
    }

    /// 타이머의 설정을 '적용' 하는 경우
    func applyCurrentSettings() {
        justConfigure(save: true, toast: true)
    }

    /// 타이머를 '취소' 하는 경우
    func cancel() {
        timerVM.stop()
        justConfigure(save: false, toast: false)
    }

    /// 내역에서 타이머를 선택하여 '적용'하는 경우
    func apply(template t: Timer) {
        timerVM.configure(from: t)
        configuredMainSeconds = t.mainSeconds
        mainMinutes = max(0, t.mainSeconds) / 60
        mainSeconds = max(0, t.mainSeconds) % 60
        timerVM.start()
    }

    func start() { timerVM.start() }
    func pause() { timerVM.pause() }
    func resume() { timerVM.resume() }

    func timeString(from interval: TimeInterval) -> String {
        let total = max(0, Int(interval.rounded()))
        let m = total / 60
        let s = total % 60
        return String(format: "%02d:%02d", m, s)
    }

    func justConfigure(save: Bool, toast: Bool) {
        // ★ 총초 = 분*60 + 초(0~59 보정)
        let secPart = max(0, min(59, mainSeconds))
        let mainSec = max(0, mainMinutes) * 60 + secPart

        let normalizedOffsets: [Int] = Array(
            selectedOffsets
                .filter { $0 > 0 && $0 < mainSec }
        ).sorted()

        let temp = Timer(
            name: "dummy time setting",
            mainSeconds: mainSec,
            prealertOffsetsSec: normalizedOffsets
        )
        timerVM.configure(from: temp)
        configuredMainSeconds = mainSec

        if save, let ctx = context {
            let name = makeTemplateName(
                mainSec: mainSec,
                offsets: normalizedOffsets
            )
            let entry = Timer(
                name: name,
                mainSeconds: mainSec,
                prealertOffsetsSec: normalizedOffsets
            )
            ctx.insert(entry)
            try? ctx.save()
        }

        if toast {
            let mainLabel = secPart > 0 ? "\(mainMinutes)분 \(secPart)초" : "\(mainMinutes)분"
            let preText = normalizedOffsets
                .map { "\($0/60)분" }
                .sorted()
                .joined(separator: ", ")
            timerVM.showToast?(
                "타이머 적용: \(mainLabel)" + (preText.isEmpty ? "" : " / 예비 \(preText)")
            )
        }
    }

    private func makeTemplateName(mainSec: Int, offsets: [Int]) -> String {
        let m = max(0, mainSec) / 60
        let s = max(0, mainSec) % 60
        let base = s > 0 ? "메인 \(m)분 \(s)초" : "메인 \(m)분"
        if offsets.isEmpty { return base }
        let pre = offsets.map { "\($0/60)" }.joined(separator: "·")
        return "\(base) / 예비 \(pre)분"
    }
}
