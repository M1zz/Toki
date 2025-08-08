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
    @Published var timer: Timer?
    
    private let notificaionTime: Int
    private var notificationTrigged: Bool = false
    
    init(mainDuration: Int, notificationDuration: Int) {
        self.timeRemaining = mainDuration
        self.notificaionTime = notificationDuration
    }
    
//    init(timeRemaining: Int, isPaused: Bool = false, timer: Timer? = nil) {
//        self.timeRemaining = timeRemaining
//        self.isPaused = isPaused
//    }
    
    func start() {
        startTimer()
    }
    
    func stop() {
        stopTimer()
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
}


