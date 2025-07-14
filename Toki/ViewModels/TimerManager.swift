import Foundation
import Combine
import UserNotifications
import UIKit

class TimerManager: ObservableObject {
    // MARK: - Published Properties
    @Published var remainingTime: TimeInterval = 0
    @Published var totalTime: TimeInterval = 0
    @Published var isRunning: Bool = false
    @Published var isPaused: Bool = false
    @Published var progress: Double = 0
    @Published var shouldShowAlert: Bool = false
    @Published var isCompleted: Bool = false
    
    // 시간 표시용 계산된 프로퍼티
    var displayMinutes: Int {
        Int(remainingTime) / 60
    }
    
    var displaySeconds: Int {
        Int(remainingTime) % 60
    }
    
    // MARK: - Private Properties
    
    // 1. Foundation Timer 방식
    private var foundationTimer: Timer?
    
    // 2. DispatchSourceTimer 방식 (백그라운드 동작 지원)
    private var dispatchTimer: DispatchSourceTimer?
    private let timerQueue = DispatchQueue(label: "timer.queue", qos: .userInteractive)
    
    // 3. UIDatePicker 개념을 활용한 시간 설정
    private var startDate: Date?
    private var endDate: Date?
    
    // 알림 관련
    private var alertMinutes: [Int] = [5] // 배열로 변경
    private var alertMessage: String = ""
    private var hasShownAlerts: Set<Int> = [] // 여러 알림 추적
    
    // 백그라운드 처리
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    
    // MARK: - Initialization
    init() {
        requestNotificationPermission()
        setupBackgroundObservers()
    }
    
    deinit {
        stopAllTimers()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public Methods
    
    /// 타이머 시작 (UIDatePicker 개념 활용)
    func startTimer(minutes: Int, alertMinutes: [Int] = [5], message: String = "") {
        // 기존 타이머 정리
        stopAllTimers()
        
        // UIDatePicker 개념: 현재 시간부터 설정된 시간까지의 간격 계산
        let now = Date()
        self.startDate = now
        self.endDate = now.addingTimeInterval(TimeInterval(minutes * 60))
        
        // 설정 저장
        self.totalTime = TimeInterval(minutes * 60)
        self.remainingTime = self.totalTime
        self.alertMinutes = alertMinutes
        self.alertMessage = message
        self.hasShownAlerts = [] // 리셋
        self.isRunning = true
        self.isPaused = false
        self.isCompleted = false
        
        // 백그라운드 태스크 시작
        startBackgroundTask()
        
        // DispatchSourceTimer 방식으로 시작 (백그라운드 지원)
        startDispatchTimer()
        
        // 로컬 알림 스케줄링
        scheduleNotifications(totalMinutes: minutes, alertMinutes: alertMinutes, message: message)
    }
    
    /// 타이머 일시정지
    func pauseTimer() {
        guard isRunning else { return }
        
        isPaused = true
        isRunning = false
        
        // 모든 타이머 중지
        stopAllTimers()
        
        // 백그라운드 태스크 종료
        endBackgroundTask()
        
        // 스케줄된 알림 취소
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    /// 타이머 재개
    func resumeTimer() {
        guard isPaused else { return }
        
        isPaused = false
        isRunning = true
        
        // 백그라운드 태스크 재시작
        startBackgroundTask()
        
        // 타이머 재시작
        startDispatchTimer()
        
        // 남은 시간으로 알림 다시 스케줄링
        let remainingMinutes = Int(remainingTime / 60)
        let validAlertTimes = alertMinutes.filter { $0 < remainingMinutes && !hasShownAlerts.contains($0) }
        if !validAlertTimes.isEmpty {
            scheduleNotifications(totalMinutes: remainingMinutes, alertMinutes: validAlertTimes, message: alertMessage)
        }
    }
    
    /// 타이머 정지
    func stopTimer() {
        stopAllTimers()
        
        isRunning = false
        isPaused = false
        remainingTime = 0
        totalTime = 0
        progress = 0
        hasShownAlerts = []
        isCompleted = false
        
        endBackgroundTask()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    /// 타이머 리셋
    func resetTimer() {
        stopTimer()
        remainingTime = totalTime
        progress = 0
        hasShownAlerts = []
        isCompleted = false
    }
    
    // MARK: - Private Methods
    
    /// DispatchSourceTimer 시작 (백그라운드 동작 지원)
    private func startDispatchTimer() {
        dispatchTimer = DispatchSource.makeTimerSource(queue: timerQueue)
        dispatchTimer?.schedule(deadline: .now(), repeating: 0.1) // 0.1초마다 업데이트
        
        dispatchTimer?.setEventHandler { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.updateTimer()
            }
        }
        
        dispatchTimer?.resume()
    }
    
    /// Foundation Timer 시작 (대안 방법)
    private func startFoundationTimer() {
        foundationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    /// 타이머 업데이트
    private func updateTimer() {
        guard isRunning, remainingTime > 0 else {
            // 타이머 완료
            completeTimer()
            return
        }
        
        // UIDatePicker 개념: 현재 시간과 종료 시간의 차이 계산
        if let endDate = endDate {
            let now = Date()
            remainingTime = max(0, endDate.timeIntervalSince(now))
        } else {
            // 대안: 직접 시간 감소
            remainingTime -= 0.1
        }
        
        // 진행률 계산 (설정된 시간 기준으로 남은 시간 비율 계산)
        if totalTime > 0 {
            let remainingRatio = remainingTime / totalTime // 남은 시간 비율 (0.0 ~ 1.0)
            let totalMinutes = totalTime / 60.0 // 설정된 총 시간(분)
            progress = (remainingRatio * totalMinutes) / 60.0 // 60분 기준으로 변환
        }
        
        // 알림 체크 (설정된 모든 시간들에 대해)
        let remainingMinutes = remainingTime / 60
        for alertMinute in alertMinutes {
            if !hasShownAlerts.contains(alertMinute) && 
               remainingMinutes <= Double(alertMinute) && 
               remainingMinutes > 0 {
                hasShownAlerts.insert(alertMinute)
                DispatchQueue.main.async {
                    self.shouldShowAlert = true
                }
            }
        }
    }
    
    /// 타이머 완료 처리
    private func completeTimer() {
        remainingTime = 0
        progress = 0.0 // 완료 시 0
        isRunning = false
        isPaused = false
        
        stopAllTimers()
        endBackgroundTask()
        
        // 완료 상태 알림
        DispatchQueue.main.async {
            self.isCompleted = true
        }
    }
    
    /// 모든 타이머 중지
    private func stopAllTimers() {
        // DispatchSourceTimer 중지
        dispatchTimer?.cancel()
        dispatchTimer = nil
        
        // Foundation Timer 중지
        foundationTimer?.invalidate()
        foundationTimer = nil
    }
    
    // MARK: - Notification Methods
    
    /// 알림 권한 요청
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("알림 권한 요청 오류: \(error)")
            }
        }
    }
    
    /// 알림 스케줄링
    private func scheduleNotifications(totalMinutes: Int, alertMinutes: [Int], message: String) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        // 1. 사전 알림들 (설정된 각 분 전)
        for alertMinute in alertMinutes {
            if alertMinute < totalMinutes {
                let alertContent = UNMutableNotificationContent()
                alertContent.title = "타이머 알림"
                alertContent.body = "\(alertMinute)분 후에 \"\(message)\""
                alertContent.sound = .default
                
                let alertTrigger = UNTimeIntervalNotificationTrigger(
                    timeInterval: TimeInterval((totalMinutes - alertMinute) * 60),
                    repeats: false
                )
                
                let alertRequest = UNNotificationRequest(
                    identifier: "timer-alert-\(alertMinute)",
                    content: alertContent,
                    trigger: alertTrigger
                )
                
                center.add(alertRequest)
            }
        }
        
        // 2. 완료 알림
        let completionContent = UNMutableNotificationContent()
        completionContent.title = "타이머 완료"
        completionContent.body = message
        completionContent.sound = .default
        
        let completionTrigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(totalMinutes * 60),
            repeats: false
        )
        
        let completionRequest = UNNotificationRequest(
            identifier: "timer-completion",
            content: completionContent,
            trigger: completionTrigger
        )
        
        center.add(completionRequest)
    }
    
    // MARK: - Background Handling
    
    /// 백그라운드 관찰자 설정
    private func setupBackgroundObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc private func appDidEnterBackground() {
        // 백그라운드 진입 시 현재 시간 저장
        if isRunning {
            UserDefaults.standard.set(Date(), forKey: "backgroundTime")
            UserDefaults.standard.set(remainingTime, forKey: "remainingTime")
        }
    }
    
    @objc private func appWillEnterForeground() {
        // 포그라운드 복귀 시 시간 동기화
        if isRunning,
           let backgroundTime = UserDefaults.standard.object(forKey: "backgroundTime") as? Date {
            let elapsedTime = Date().timeIntervalSince(backgroundTime)
            let savedRemainingTime = UserDefaults.standard.double(forKey: "remainingTime")
            
            remainingTime = max(0, savedRemainingTime - elapsedTime)
            
            if remainingTime <= 0 {
                completeTimer()
            } else {
                // 진행률 업데이트
                if totalTime > 0 {
                    let remainingRatio = remainingTime / totalTime
                    let totalMinutes = totalTime / 60.0
                    progress = (remainingRatio * totalMinutes) / 60.0
                }
            }
            
            // UserDefaults 정리
            UserDefaults.standard.removeObject(forKey: "backgroundTime")
            UserDefaults.standard.removeObject(forKey: "remainingTime")
        }
    }
    
    /// 백그라운드 태스크 시작
    private func startBackgroundTask() {
        endBackgroundTask()
        
        backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "TimerTask") { [weak self] in
            self?.endBackgroundTask()
        }
    }
    
    /// 백그라운드 태스크 종료
    private func endBackgroundTask() {
        if backgroundTaskID != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }
    }
} 