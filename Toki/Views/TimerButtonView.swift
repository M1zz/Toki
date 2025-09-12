//
//  TimerButton.swift
//  Toki
//
//  Created by POS on 8/26/25.
//

import Foundation
import SwiftUI

struct TimerButton: View {
    let state: TimerState
    let onStart: () -> Void
    let onPause: () -> Void
    let onResume: () -> Void
    let onCancel: () -> Void

    var body: some View {
        switch state {
        case .idle:
            HStack(spacing: 100) {
                Button("취소", action: onCancel)
                    .buttonStyle(TimerButtonStyle(tint: Color.plain))
                    .disabled(true)
                Button("시작", action: onStart)
                    .buttonStyle(TimerButtonStyle(tint: Color.positive))
            }
            
        case .finished:
            HStack(spacing: 100) {
                Button("취소", action: onCancel)
                    .buttonStyle(TimerButtonStyle(tint: Color.plain))
                Button("시작", action: onStart)
                    .buttonStyle(TimerButtonStyle(tint: Color.positive))
            }

        case .running:
            HStack(spacing: 100) {
                Button("취소", action: onCancel)
                    .buttonStyle(TimerButtonStyle(tint: Color.plain))
                Button("일시정지", action: onPause)
                    .buttonStyle(TimerButtonStyle(tint: Color.bitNegative))
            }

        case .paused:
            HStack(spacing: 100) {
                Button("취소", action: onCancel)
                    .buttonStyle(TimerButtonStyle(tint: Color.plain))
                Button("재개", action: onResume)
                    .buttonStyle(TimerButtonStyle(tint: Color.positive))
            }
        }
    }
}

// TODO: button design
struct TimerButtonStyle: ButtonStyle {
    var tint: Color
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        return configuration.label
            .font(.system(size: 20, weight: .semibold, design: .rounded))
            .frame(maxWidth: 47, minHeight: 47)
            .foregroundStyle(.white)
            .background(
                Capsule()
                    .fill(
                        (isEnabled ? tint : .gray)
                            .opacity(pressed ? 0.7 : 1.0)
                    )
            )
            .scaleEffect(pressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.12), value: pressed)
            .opacity(isEnabled ? 1 : 0.6)
    }
}
