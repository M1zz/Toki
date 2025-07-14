//
//  ContentView.swift
//  toki
//
//  Created by POS on 7/7/25.
//

import SwiftUI
import SwiftData
import UserNotifications

struct ContentView: View {
    var body: some View {
        TimerView()
            .onAppear {
                // 알림 권한 요청
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if let error = error {
                        print("알림 권한 요청 오류: \(error)")
                    }
                }
            }
    }
}

#Preview {
    ContentView()
}
