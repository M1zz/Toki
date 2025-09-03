//
//  NotificationService.swift
//  Toki
//
//  Created by 내꺼다 on 8/10/25.
//

import UserNotifications
import WatchKit

struct NotificationService {
    func scheduleNotification(timeInterval: TimeInterval, title: String, body: String, identifier: String) {
        guard timeInterval > 0 else {
            print("알림 예약 실패: \(identifier) - 유효하지 않은 시간 간격 (\(timeInterval))")
            return
        }
        
        // 먼저 해당 identifier의 기존 알림 제거
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("알림 권한 요청 실패: \(error.localizedDescription)")
                return
            }
            
            if granted {
                let content = UNMutableNotificationContent()
                content.title = title
                content.body = body
                content.sound = UNNotificationSound.default
                content.badge = 1
                
                // 백그라운드에서도 작동하도록 중요도 설정
                content.interruptionLevel = .active  // critical 대신 active 사용
                content.relevanceScore = 1.0  // 높은 관련성 점수
                
                
                // watchOS 전용 haptic 피드백 설정
                if identifier == "main_timer_notification" {
                    content.userInfo = ["haptic": "success"]
                } else {
                    content.userInfo = ["haptic": "warning"]
                }
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
                
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("알림 예약 실패: \(identifier) - \(error.localizedDescription)")
                    } else {
                        print("알림 예약 성공: \(identifier) - \(Int(timeInterval))초 후 알림")
                        
                        // 즉시 haptic 피드백으로 예약 확인
                        DispatchQueue.main.async {
                            WKInterfaceDevice.current().play(.click)
                        }
                    }
                }
            } else {
                print("알림 권한이 거부되었습니다.")
            }
        }
    }
    
    
    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        print("예약된 모든 알림이 취소되었습니다.")
    }
    
    func removeNotification(withIdentifier identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        print("알림 취소: \(identifier)")
    }
}

class NotificationDelegate: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        print("알림 표시: \(notification.request.identifier)")
        
        completionHandler([.sound])
        
        // haptic 피드백 실행
        DispatchQueue.main.async {
            let hapticType = notification.request.content.userInfo["haptic"] as? String ?? "click"
            switch hapticType {
            case "success":
                WKInterfaceDevice.current().play(.success)
            case "warning":
                WKInterfaceDevice.current().play(.failure)
            default:
                WKInterfaceDevice.current().play(.click)
            }
        }
    }
}
