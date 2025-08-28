//
//  ring.swift
//  Toki
//
//  Created by xa on 8/28/25.
//

import Foundation

enum RingMode: String, CaseIterable, Identifiable {
    case sound = "sound"
    case vibration = "vib"

    var id: String { rawValue }
}
