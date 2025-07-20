//
//  ControlButtonType.swift
//  Toki
//
//  Created by POS on 7/20/25.
//

import Foundation
import SwiftUI

enum ControlButtonType: Hashable {
    case start, pause, resume, reset

    var label: String {
        switch self {
        case .start: return "Start"
        case .pause: return "Pause"
        case .resume: return "Resume"
        case .reset: return "Reset"
        }
    }

    var backgroundColor: Color {
        switch self {
        case .start: return .pink
        case .pause: return .orange
        case .resume: return .green
        case .reset: return .gray
        }
    }

    var foregroundColor: Color {
        switch self {
        case .start, .reset: return .black
        case .pause, .resume: return .white
        }
    }

    var isEnabled: Bool {
        switch self {
        case .reset:
            return true
        default:
            return true
        }
    }
}
