//
//  ContentView.swift
//  toki
//
//  Created by POS on 7/7/25.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\Timer.createdAt, order: .reverse)])
    private var templates: [Timer]

    @StateObject private var vm = TimerViewModel()
    @StateObject private var toast = ToastManager()

    @State private var mainMinutes: Int = 10
    @State private var selectedOffsets: Set<Int> = [60, 180, 300]  // prealert settings
    @State private var configuredMainSeconds: Int = 600
    @State private var showTemplateSheet = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // remaining time
                VStack(spacing: 8) {
                    Text(timeString(from: vm.remaining))
                        .font(
                            .system(size: 44, weight: .bold, design: .rounded)
                        )
                        .monospacedDigit()
                }

                TimerButton(
                    state: vm.state,
                    onStart: { start() },
                    onPause: { vm.pause() },
                    onResume: { vm.resume() },
                    onCancel: {
                        vm.stop()
                        justConfigure()
                    }
                )

                Divider()

                // timer setting area
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Stepper(
                            "메인 알림 \(mainMinutes)분",
                            value: $mainMinutes,
                            in: 1...120,
                            step: 1
                        )
                        Spacer()
                        Button("적용") { justConfigure() }
                            .buttonStyle(.bordered)
                    }

                    // prealert setting area
                    let mainSeconds = mainMinutes * 60
                    let presets = Timer.presetOffsetsSec
                    VStack(alignment: .leading, spacing: 8) {
                        Text("예비 알림").font(.subheadline).foregroundStyle(
                            .secondary
                        )
                        HStack {
                            ForEach(presets, id: \.self) { sec in
                                let isDisabled = sec >= mainSeconds
                                Toggle(
                                    "\(sec/60)분",
                                    isOn: Binding(
                                        get: {
                                            selectedOffsets.contains(sec)
                                        },
                                        set: { on in
                                            if on {
                                                selectedOffsets.insert(sec)
                                            } else {
                                                selectedOffsets.remove(sec)
                                            }
                                        }
                                    )
                                )
                                .toggleStyle(.button)
                                .buttonStyle(.bordered)
                                .disabled(isDisabled)
                            }
                        }
                    }
                    Button("설정값 저장하기") { saveTemplate() }
                        .buttonStyle(.bordered)
                }
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showTemplateSheet = true
                    } label: {
                        Image(systemName: "list.bullet")
                    }
                }
            }
        }
        .sheet(isPresented: $showTemplateSheet) {
            TimerTemplateView { selected in
                apply(template: selected)
            }
            .presentationDetents(Set<PresentationDetent>([.medium, .large]))
            .presentationDragIndicator(Visibility.visible)
        }
        .toast(toast)
        .onAppear {
            vm.showToast = { toast.show(Toast($0)) }
            justConfigure()
        }

    }

    private func justConfigure() {
        let mainSec = mainMinutes * 60
        let offsets = selectedOffsets.filter { $0 > 0 && $0 < mainSec }
        let temp = Timer(
            name: "dummy time setting",
            mainSeconds: mainSec,
            prealertOffsetsSec: Array(offsets)
        )
        vm.configure(from: temp)
        configuredMainSeconds = mainSec
        toast.show(
            Toast(
                "타이머 적용: \(mainMinutes)분 / 예비 \(offsets.map { "\($0/60)분" }.sorted().joined(separator: ", "))"
            )
        )
    }

    private func start() {
        vm.start()
    }

    private func saveTemplate() {
        let mainSec = mainMinutes * 60
        let offsets = selectedOffsets.filter { $0 > 0 && $0 < mainSec }
        let t = Timer(
            name: "메인 \(mainMinutes)분",
            mainSeconds: mainSec,
            prealertOffsetsSec: Array(offsets)
        )
        context.insert(t)
        try? context.save()
        toast.show(Toast("템플릿 저장됨", type: .success))
    }

    private func apply(template t: Timer) {
        vm.configure(from: t)
        configuredMainSeconds = t.mainSeconds
        vm.start()
    }

    private func timeString(from interval: TimeInterval) -> String {
        let total = max(0, Int(interval.rounded()))
        let m = total / 60
        let s = total % 60
        return String(format: "%02d:%02d", m, s)
    }
}
