//
//  Clock.swift
//  Toki
//
//  Created by xa on 8/27/25.
//

import Foundation
import SwiftUI

struct Clock: View {
    var remaining: TimeInterval
    var total: TimeInterval
    var size: CGFloat = 240

    private var ratio: CGFloat {
        guard total > 0 else { return 0 }
        return CGFloat(max(0, min(1, remaining / total)))
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.secondary.opacity(0.15))

            ClockTrack(remaining: ratio)
                .fill(Color.accentColor)
        }
        .frame(width: size, height: size)
        .animation(.easeInOut(duration: 0.15), value: ratio)
        .accessibilityLabel("남은 시간 \(mmss(from: remaining))")
    }

    private func mmss(from sec: TimeInterval) -> String {
        let t = max(0, Int(sec.rounded()))
        let m = t / 60
        let s = t % 60
        return String(format: "%02d:%02d", m, s)
    }
}
