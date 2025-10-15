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
    
    private var timer: Timer?
    private let notificationService: NotificationService
    let mainDuration: Int
    let notificationTime: Int
    
    private var startDate: Date?        // 타이머 시작 시각
    private var pauseDate: Date?        // 일시정지한 시각
    private var accumulatedPause: TimeInterval = 0 // 총 정지 시간
    
    init(mainDuration: Int, notificationDuration: Int, notificationService: NotificationService = .init()) {
        self.mainDuration = mainDuration
        self.timeRemaining = mainDuration
        self.notificationTime = notificationDuration
        self.notificationService = notificationService
    }
    
    // MARK: - Public Methods
    
    func start() {
        startDate = Date()
        accumulatedPause = 0
        isPaused = false
        
        startTimer()
        
        // 알림 초기화
        notificationService.removeAllNotifications()
        scheduleNotifications(for: mainDuration)
    }
    
    func stop() {
        stopTimer()
        startDate = nil
        pauseDate = nil
        accumulatedPause = 0
        timeRemaining = mainDuration
        
        notificationService.removeAllNotifications()
    }
    
    func togglePause() {
        isPaused.toggle()
        
        if isPaused {
            // 멈춤 상태 기록
            pauseDate = Date()
            stopTimer()
            notificationService.removeAllNotifications()
        } else {
            // 정지 시간 보정
            if let pauseDate {
                accumulatedPause += Date().timeIntervalSince(pauseDate)
            }
            self.pauseDate = nil
            
            // 알림 재설정
            notificationService.removeAllNotifications()
            if timeRemaining > 0 {
                scheduleNotifications(for: timeRemaining)
            }
            
            startTimer()
        }
    }
    
    // MARK: - Private Methods
    
    private func startTimer() {
        guard timer == nil else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.updateTimeRemaining()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateTimeRemaining() {
        guard let startDate else { return }
        
        // 실제 경과 시간 = (현재 - 시작) - 멈췄던 시간
        let elapsed = Date().timeIntervalSince(startDate) - accumulatedPause
        let remaining = max(mainDuration - Int(elapsed), 0)
        
        self.timeRemaining = remaining
        
        if remaining == 0 {
            stopTimer()
        }
    }
    
    private func scheduleNotifications(for duration: Int) {
        // 메인 완료 알림
        notificationService.scheduleNotification(
            timeInterval: TimeInterval(duration),
            title: "타이머 종료",
            body: "설정한 시간이 종료되었습니다.",
            identifier: "main_timer_notification"
        )
        
        // 종료 전 알림
        if notificationTime > 0 && duration > notificationTime {
            let pointTime = duration - notificationTime
            notificationService.scheduleNotification(
                timeInterval: TimeInterval(pointTime),
                title: "지정 알림",
                body: "완료 \(notificationTime.formattedTimeString) 전입니다.",
                identifier: "point_timer_notification"
            )
        }
    }
    
    deinit {
        stop()
    }
}
