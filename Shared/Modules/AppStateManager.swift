//
//  AppStateManager.swift
//  Toki
//
//  Created by 광로 on 9/13/25.
//

import SwiftUI
import UserNotifications

final class AppStateManager: ObservableObject {
    @Published private(set) var isInBackground: Bool = false
    
    func updateState(_ phase: ScenePhase) {
        switch phase {
        case .active:
            isInBackground = false
        case .background, .inactive:
            isInBackground = true
        @unknown default:
            isInBackground = false
        }
    }
    
    func sendNotificationIfNeeded(_ message: String) {
//        if isInBackground {
//            pushPrealertNotice(message: message)
//        }
        pushPrealertNotice(message: message)
    }
}

private func pushPrealertNotice(message: String) {
    let pushEnabled = UserDefaults.standard.bool(forKey: "pushEnabled")
    guard pushEnabled else { return }
    
    let center = UNUserNotificationCenter.current()
    
    let content = UNMutableNotificationContent()
    content.title = "Toki 타이머"
    content.body = message
    content.sound = .default
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    
    center.add(request)
}
