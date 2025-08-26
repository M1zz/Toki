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

    @StateObject private var screenVM = TimerScreenViewModel()
    @StateObject private var toast = ToastManager()

    @State private var showHistory = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // remaining time
                ZStack {
                    Clock(
                        remaining: screenVM.remaining,
                        total: TimeInterval(screenVM.configuredMainSeconds),
                    )

                    VStack(spacing: 8) {
                        Text(
                            screenVM.timeString(
                                from: screenVM.timerVM.remaining
                            )
                        )
                        .font(
                            .system(size: 44, weight: .bold, design: .rounded)
                        )
                        .monospacedDigit()
                    }
                }

                TimerButton(
                    state: screenVM.timerVM.state,
                    onStart: { screenVM.start() },
                    onPause: { screenVM.pause() },
                    onResume: { screenVM.resume() },
                    onCancel: { screenVM.cancel() }
                )

                Divider()

                // timer setting area
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Stepper(
                            "메인 알림 \(screenVM.mainMinutes)분",
                            value: $screenVM.mainMinutes,
                            in: 1...120,
                            step: 1
                        )
                        Spacer()
                        Button("적용") { screenVM.applyCurrentSettings() }
                            .buttonStyle(.bordered)

                    }

                    // prealert setting area
                    let mainSeconds = screenVM.mainMinutes * 60
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
                                            screenVM.selectedOffsets.contains(
                                                sec
                                            )
                                        },
                                        set: { on in
                                            if on {
                                                screenVM.selectedOffsets.insert(
                                                    sec
                                                )
                                            } else {
                                                screenVM.selectedOffsets.remove(
                                                    sec
                                                )
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
                }
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showHistory = true
                    } label: {
                        Image(systemName: "list.bullet")
                    }
                }
            }
        }
        .sheet(isPresented: $showHistory) {
            TimerTemplateView { selected in
                screenVM.apply(template: selected)
            }
            .presentationDetents(Set<PresentationDetent>([.medium, .large]))
            .presentationDragIndicator(Visibility.visible)
        }
        .toast(toast)
        .onAppear {
            screenVM.attachContext(context)
            screenVM.timerVM.showToast = { toast.show(Toast($0)) }
            screenVM.initialConfiguration()
        }
    }
}
