//
//  TimerViewModel.swift
//  Toki
//
//  Created by 내꺼다 on 8/8/25.
//

import Foundation

class TimerViewModel: ObservableObject {
    @Published var timeRemaining: Int
    @Published var isPaused: Bool = false
    
//    @Published var timer: Timer?
    private var timer: Timer?
    private let notificationService: NotificationService
    
//    private let notificaionTime: Int
//    private var notificationTrigged: Bool = false
    private let mainDuration: Int
    private let notificationTime: Int
    
//    init(mainDuration: Int, notificationDuration: Int, notificationService: NotificationService = .init()) {
//        self.timeRemaining = mainDuration
//        self.notificaionTime = notificationDuration
//        self.notificationService = notificationService
//    }
    init(mainDuration: Int, notificationDuration: Int, notificationService: NotificationService = .init()) {
        self.mainDuration = mainDuration
        self.timeRemaining = mainDuration
        self.notificationTime = notificationDuration
        self.notificationService = notificationService
    }
    

    
    func start() {
        startTimer()
        
        // 기존 알림 모두 제거
        notificationService.removeAllNotifications()
        
        // 타이머 완료 알림 예약
        notificationService.scheduleNotification(timeInterval: TimeInterval(mainDuration), title: "타이머 종료", body: "설정한 시간이 종료되었습니다.", identifier: "main_timer_notification")
        
        // 종료 전 알림 예약 (notificationTime이 0보다 클 때만)
        if notificationTime > 0 {
            let pointNotificationTime = mainDuration - notificationTime
            if pointNotificationTime > 0 {
                notificationService.scheduleNotification(timeInterval: TimeInterval(pointNotificationTime), title: "지정 알림", body: "완료 \(notificationTime.formattedTimeString) 전입니다.", identifier: "point_timer_notification")
            }
        }
    }
    
    func stop() {
        stopTimer()
        
        notificationService.removeAllNotifications()
    }
    
    func togglePause() {
        self.isPaused.toggle()
        if isPaused {
            stopTimer()
            notificationService.removeAllNotifications()
        } else {
            // 기존 알림 모두 제거
            notificationService.removeAllNotifications()
            
            // 타이머 완료 알림 예약 (남은 시간 기준)
            notificationService.scheduleNotification(timeInterval: TimeInterval(timeRemaining), title: "타이머 종료", body: "설정한 시간이 종료되었습니다.", identifier: "main_timer_notification")
            
            // 종료 전 알림 예약 (남은 시간이 종료 전 알림 시간보다 클 때만)
            if notificationTime > 0 && timeRemaining > notificationTime {
                let remainingPointTime = timeRemaining - notificationTime
                if remainingPointTime > 0 {
                    notificationService.scheduleNotification(timeInterval: TimeInterval(remainingPointTime), title: "지정 알림", body: "완료 \(notificationTime.formattedTimeString) 전입니다.", identifier: "point_timer_notification")
                }
            }
            
            startTimer()
        }
    }
    
    
    private func startTimer() {
        guard timer == nil else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
            _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.stopTimer()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        stop()
    }
    
}


