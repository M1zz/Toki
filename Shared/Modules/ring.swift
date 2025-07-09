//
//  ring.swift
//  Toki
//
//  Created by POS on 7/8/25.
//

enum RingMode: String, CaseIterable, Identifiable {
    case sound = "sound"
    case vibration = "vib"

    var id: String { rawValue }
}
