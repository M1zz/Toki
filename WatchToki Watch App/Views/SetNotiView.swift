//
//  SetNotiView.swift
//  Toki
//
//  Created by 내꺼다 on 8/7/25.
//

import SwiftUI
import UserNotifications

struct SetNotiView: View {
    @ObservedObject var viewModel: SetNotiViewModel
    
    @Binding var path: [NavigationTarget]
    
    var body: some View {
        VStack(spacing: 10) {
            Text("완료 전 알림 설정")
            
            let maxMinute = viewModel.maxSelectableTimeModel.minute
            
            Picker(selection: $viewModel.notiTime.minute, label: Text("분")) {
                ForEach(0...maxMinute, id: \.self) { minute in
                    Text("\(minute)") }
            }
            .frame(width: 70)
            .clipped()
            .focusable()
            
            .frame(height: 100)
            
            Button {
                requestNotificationPermissionIfNeeded { _ in
                    schedulePreFinishNotification(after: TimeInterval(viewModel.notiTime.convertedSecond))
                }
                path.append(.timerView(mainDuration: viewModel.maxTimeInSeconds, NotificationDuration: viewModel.notiTime.convertedSecond))
            } label: {
                Text("시작")
            }
        }
    }
}

// MARK: - Notification helpers
private func requestNotificationPermissionIfNeeded(completion: @escaping (Bool) -> Void) {
    let center = UNUserNotificationCenter.current()
    center.getNotificationSettings { settings in
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            completion(true)
        case .denied:
            completion(false)
        case .notDetermined:
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                completion(granted)
            }
        @unknown default:
            completion(false)
        }
    }
}

private func schedulePreFinishNotification(after seconds: TimeInterval) {
    let content = UNMutableNotificationContent()
    content.title = "완료 전 알림"
    if seconds >= 60 {
        let minutes = Int(seconds) / 60
        content.body = "\(minutes)분 뒤에 타이머가 완료됩니다."
    } else {
        content.body = "\(Int(seconds))초 뒤에 타이머가 완료됩니다."
    }
    content.sound = .default

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, seconds), repeats: false)
    let request = UNNotificationRequest(
        identifier: "preFinish-\(UUID().uuidString)",
        content: content,
        trigger: trigger
    )

    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Failed to schedule notification: \(error)")
        }
    }
}


//}


//#Preview {
//    SetNotiView()
//}

// 타이머 설정화면이랑 같게
// 앞에서 시간 입력값 받아서 그것보다 짧게 만들어야 하는데
// 입력받은 값에서 1분(60초) 적은 값까지로 제한 걸어주기 - 초단위는 삭제하는게 나을지 고민하기



// 백그라운드, 워치꺼져있을 때 도 햅틱알림이 있어야?

// 완료 전 알림이니까 만약 5분전이면 지정한 시간에서 -5분을 빼고 타이머를 만드는 겪 -> 결국 완료 전 알림 타이머

