//
//  ControlButton.swift
//  Toki
//
//  Created by POS on 7/20/25.
//

import Foundation
import SwiftUI

class ControlButtonsViewModel: ObservableObject {
    @Published var isSettingMode: Bool
    @ObservedObject var timerManager: TimerManager
    @Binding var selectedMinutes: Int

    init(isSettingMode: Bool, timerManager: TimerManager, selectedMinutes: Binding<Int>) {
        self.isSettingMode = isSettingMode
        self.timerManager = timerManager
        self._selectedMinutes = selectedMinutes
    }

    var leftside: ControlButtonType {
        return .reset
    }

    var rightside: ControlButtonType? {
        if isSettingMode {
            return .start
        } else if timerManager.isRunning {
            return .pause
        } else if timerManager.isPaused {
            return .resume
        } else {
            return nil
        }
    }

    var isResetEnabled: Bool {
        return timerManager.isRunning || timerManager.isPaused
    }

    func performAction(for type: ControlButtonType) {
        switch type {
        case .start:
            timerManager.startTimer(minutes: selectedMinutes)
        case .pause:
            timerManager.pauseTimer()
        case .resume:
            timerManager.resumeTimer()
        case .reset:
            if isResetEnabled {
                timerManager.stopTimer()
                selectedMinutes = 25
            }
        }
    }
}
