//
//  RingVib.swift
//  Toki
//
//  Created by POS on 7/8/25.
//

import UserNotifications

/// 푸시알림 권한을 요청하는 함수 
func requestNotice() {
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if let error = error {
            print("Fail to request notification authorization: \(error)")
        } else {
            print("notification: \(granted ? "allowed" : "denied")")
        }
    }
}

func pushNotice() {
    let pushEnabled = UserDefaults.standard.bool(forKey: "pushEnabled")
    guard pushEnabled else { return }

    let center = UNUserNotificationCenter.current()
    
    //TODO: selected message가 표시되도록 수정
    let content = UNMutableNotificationContent()
    content.body = "타이머가 종료되었습니다!"
    content.sound = .default

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

    center.add(request)
}
