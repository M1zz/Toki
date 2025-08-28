//
//  RingVib.swift
//  Toki
//
//  Created by POS on 7/8/25.
//

import UserNotifications

func pushNotice() {
    let pushEnabled = UserDefaults.standard.bool(forKey: "pushEnabled")
    guard pushEnabled else { return }

    let center = UNUserNotificationCenter.current()
    
    let content = UNMutableNotificationContent()
    content.body = "타이머가 종료되었습니다!"
    content.sound = .default

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

    center.add(request)
}
