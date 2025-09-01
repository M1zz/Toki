//
//  TimerRunningView.swift
//  Toki
//
//  Created by xa on 8/31/25.
//

import Foundation
import SwiftUI

struct TimerRunningView: View {
    @EnvironmentObject var screenVM: TimerScreenViewModel

    private var totalSec: Int { screenVM.configuredMainSeconds }
    private var remaining: TimeInterval { screenVM.remaining }
    private var ratio: CGFloat {
        guard totalSec > 0 else { return 0 }
        return CGFloat(max(0, min(1, remaining / TimeInterval(totalSec))))
    }
    private var markers: [CGFloat] {
        guard totalSec > 0 else { return [] }
        return screenVM.selectedOffsets
            .filter { 0 < $0 && $0 < totalSec }
            .sorted()
            .map { CGFloat($0) / CGFloat(totalSec) }
    }

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(.secondary.opacity(0.25), lineWidth: 12)

                ClockTrack(remaining: ratio)
                    .stroke(
                        Color.accentColor,
                        style: StrokeStyle(
                            lineWidth: 12,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )

                ClockMarkers(
                    remaining: ratio,
                    markers: markers,
                    dotSize: 12,
                    inset: 0,
                    upcoming: true
                )

                Text(screenVM.timeString(from: screenVM.timerVM.remaining))
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .monospacedDigit()
            }
            .frame(width: 260, height: 260)
            .animation(.easeInOut(duration: 0.15), value: ratio)

            TimerButton(
                state: screenVM.timerVM.state,
                onStart: { screenVM.start() },
                onPause: { screenVM.pause() },
                onResume: { screenVM.resume() },
                onCancel: {
                    screenVM.cancel()
                }
            )
        }
    }
}
