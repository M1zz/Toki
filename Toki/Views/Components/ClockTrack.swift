//
//  ClockTrack.swift
//  Toki
//
//  Created by xa on 8/27/25.
//

import Foundation
import SwiftUI

struct ClockTrack: Shape {
    var remaining: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let clamped = min(max(remaining, 0), 1)
        guard clamped > 0 else { return path }

        let size = min(rect.width, rect.height)
        let radius = size / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)

        let start = Angle.degrees(-90)
        let end = Angle.degrees(-90 - Double(clamped * 360))

        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: start,
            endAngle: end,
            clockwise: true
        )
        path.closeSubpath()
        return path
    }

    var animatableData: CGFloat {
        get { remaining }
        set { remaining = newValue }
    }
}
