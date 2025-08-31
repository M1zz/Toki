//
//  ClockMarkers.swift
//  Toki
//
//  Created by xa on 8/31/25.
//

import Foundation
import SwiftUI

struct ClockMarkers: View {
    var remaining: CGFloat
    var markers: [CGFloat]
    var dotSize: CGFloat = 12
    var inset: CGFloat = 3
    var upcoming: Bool = true

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let r = size / 2
            let cx = geo.size.width / 2
            let cy = geo.size.height / 2

            ZStack {
                ForEach(Array(markers.enumerated()), id: \.offset) { _, m in
                    let t = max(0, min(1, m))
                    let theta = (-90.0 + Double(t * 360.0)) * .pi / 180.0
                    let rr = r - inset
                    let x = cx + CGFloat(cos(theta)) * rr
                    let y = cy + CGFloat(sin(theta)) * rr

                    let isUpcoming = t >= remaining
                    Circle()
                        .fill(isUpcoming ? .red.opacity(0.5) : .red )
                        .frame(width: dotSize, height: dotSize)
                        .position(x: x, y: y)
                }
            }
        }
        .allowsHitTesting(false)
    }
}
