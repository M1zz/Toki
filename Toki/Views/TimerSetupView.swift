//
//  TimerSetupView.swift
//  Toki
//
//  Created by xa on 8/31/25.
//

import Foundation
import SwiftUI

struct TimerSetupView: View {
    @EnvironmentObject var screenVM: TimerScreenViewModel

    var body: some View {
        VStack(spacing: 20) {
            let mainSeconds = screenVM.mainMinutes * 60 + screenVM.mainSeconds

            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    Picker(
                        "분",
                        selection: Binding<Int>(
                            get: { screenVM.mainMinutes },
                            set: { screenVM.mainMinutes = $0 }
                        )
                    ) {
                        ForEach(0...60, id: \.self) { m in
                            Text("\(m)").font(.title3)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)
                    
                    Text(":")
                        .font(.title3)

                    Picker(
                        "초",
                        selection: Binding<Int>(
                            get: { screenVM.mainSeconds },
                            set: { screenVM.mainSeconds = $0 }
                        )
                    ) {
                        ForEach(0..<60, id: \.self) { s in
                            Text("\(s)").font(.title3)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)
                }
                .frame(height: 180)
            }

            TimerButton(
                state: screenVM.timerVM.state,
                onStart: {
                    screenVM.applyCurrentSettings()
                    screenVM.start()
                },
                onPause: { screenVM.pause() },
                onResume: { screenVM.resume() },
                onCancel: { screenVM.cancel() }
            )

            Divider()

            VStack(alignment: .leading, spacing: 12) {
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
    }
}
