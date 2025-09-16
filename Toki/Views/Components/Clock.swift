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
    var markers: [CGFloat] = []
    var size: CGFloat = 240

    private var ratio: CGFloat {
        guard total > 0 else { return 0 }
        return CGFloat(max(0, min(1, remaining / total)))
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(.plain.opacity(0.5), lineWidth: 8)

            ClockTrack(remaining: ratio)
                .stroke(
                    Color.accentColor,
                    style: StrokeStyle(
                        lineWidth: 8,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )

            ClockMarkers(
                remaining: ratio,
                markers: markers,
                dotSize: 15,
                inset: 0,
                upcoming: true
            )
        }
        .frame(width: 240, height: 240)
        .animation(.easeInOut(duration: 0.15), value: ratio)
    }

    private func mmss(from sec: TimeInterval) -> String {
        let t = max(0, Int(sec.rounded()))
        let m = t / 60
        let s = t % 60
        return String(format: "%02d:%02d", m, s)
    }
}
