import SwiftUI
import UserNotifications

struct TimerView: View {
    @StateObject private var timerManager = TimerManager()
    @State private var selectedAlertTimes: Set<Int> = [5] // 중복 선택을 위한 Set
    @State private var customMessage: String = "알림 문구 설정하기"
    @State private var isEditingMessage: Bool = false
    @State private var selectedMinutes: Int = 25 // 사용자가 설정한 시간 (기본 25분)
    
    private let alertTimeOptions = [1, 3, 5, 10, 15] // 분 단위
    
    // 현재 모드 확인 (설정 모드 vs 실행 모드)
    private var isSettingMode: Bool {
        !timerManager.isRunning && !timerManager.isPaused
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // 상단 상태바 공간
            Spacer().frame(height: 50)
            
            // 알림 문구 설정
            VStack {
                if isEditingMessage {
                    TextField("알림 문구를 입력하세요", text: $customMessage)
                        .font(.system(size: 20, weight: .medium))
                        .multilineTextAlignment(.center)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            isEditingMessage = false
                        }
                } else {
                    Text("\"\(customMessage)\"")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.primary)
                        .onTapGesture {
                            if isSettingMode {
                                isEditingMessage = true
                            }
                        }
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // 원형 타이머
            ZStack {
                CircularProgressView(
                    progress: timerManager.progress,
                    totalTime: timerManager.totalTime,
                    remainingTime: timerManager.remainingTime,
                    selectedMinutes: $selectedMinutes,
                    isSettingMode: isSettingMode,
                    onTimeChanged: { newMinutes in
                        if isSettingMode {
                            selectedMinutes = newMinutes
                        }
                    }
                )
                .frame(width: 300, height: 300)
                
                // 중앙에 시작/제어 버튼
                if isSettingMode {
                    Button(action: {
                        handleTimerStart()
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                            Text("시작")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.black)
                        }
                        .frame(width: 80, height: 80)
                        .background(
                            Circle()
                                .fill(Color.white)
                                .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
                        )
                    }
                } else if timerManager.isRunning {
                    Button(action: {
                        timerManager.pauseTimer()
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: "pause.fill")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            Text("일시정지")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .frame(width: 80, height: 80)
                        .background(
                            Circle()
                                .fill(Color.orange)
                        )
                    }
                } else if timerManager.isPaused {
                    Button(action: {
                        timerManager.resumeTimer()
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            Text("재개")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .frame(width: 80, height: 80)
                        .background(
                            Circle()
                                .fill(Color.green)
                        )
                    }
                }
            }
            
            Spacer()
            
            // 알림 시간 선택 버튼들 (중복 선택 가능)
            VStack(spacing: 10) {
                Text("완료 전 알림")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
                
                HStack(spacing: 20) {
                    ForEach(alertTimeOptions, id: \.self) { minutes in
                        Button(action: {
                            toggleAlertTime(minutes)
                        }) {
                            Text("\(minutes)분")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(selectedAlertTimes.contains(minutes) ? .white : .primary)
                                .frame(width: 50, height: 50)
                                .background(
                                    Circle()
                                        .fill(selectedAlertTimes.contains(minutes) ? Color.black : Color.gray.opacity(0.2))
                                )
                        }
                        .disabled(!isSettingMode)
                        .opacity(isSettingMode ? 1.0 : 0.6)
                    }
                }
            }
            
            // 시간 표시
            HStack(spacing: 8) {
                // 분
                Text(String(format: "%02d", displayMinutes))
                    .font(.system(size: 72, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(":")
                    .font(.system(size: 72, weight: .bold))
                    .foregroundColor(.primary)
                
                // 초
                Text(String(format: "%02d", displaySeconds))
                    .font(.system(size: 72, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            // 리셋 버튼 (실행 중이거나 일시정지 상태일 때만 표시)
            if !isSettingMode {
                Button("리셋") {
                    timerManager.stopTimer()
                    selectedMinutes = 25 // 기본값으로 리셋
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.red)
                .padding(.horizontal, 30)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.red, lineWidth: 1)
                )
            }
            
            Spacer().frame(height: 40)
        }
        .background(Color(.systemBackground))
        .onReceive(timerManager.$shouldShowAlert) { shouldShow in
            if shouldShow {
                handleAlert()
            }
        }
        .onReceive(timerManager.$isCompleted) { isCompleted in
            if isCompleted {
                handleCompletion()
            }
        }
    }
    
    // 표시할 분과 초 계산
    private var displayMinutes: Int {
        if isSettingMode {
            return selectedMinutes
        } else {
            return timerManager.displayMinutes
        }
    }
    
    private var displaySeconds: Int {
        if isSettingMode {
            return 0
        } else {
            return timerManager.displaySeconds
        }
    }
    
    // 알림 시간 토글 (중복 선택)
    private func toggleAlertTime(_ minutes: Int) {
        if selectedAlertTimes.contains(minutes) {
            selectedAlertTimes.remove(minutes)
        } else {
            selectedAlertTimes.insert(minutes)
        }
    }
    
    // 타이머 시작 처리
    private func handleTimerStart() {
        // 선택된 모든 알림 시간을 배열로 변환
        let alertTimes = Array(selectedAlertTimes).sorted()
        
        timerManager.startTimer(
            minutes: selectedMinutes,
            alertMinutes: alertTimes,
            message: customMessage
        )
    }
    
    // 사전 알림 처리 (ring 함수 사용)
    private func handleAlert() {
        ring() // 기존 프로젝트의 ring 함수 사용
        
        // 추가 시각적 피드백 (선택사항)
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    // 타이머 완료 처리 (ring 함수 사용)
    private func handleCompletion() {
        ring() // 기존 프로젝트의 ring 함수 사용
        
        // 완료 시 더 강한 진동 피드백
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        // 짧은 딜레이 후 한 번 더 알림 (완료 강조)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            ring()
        }
    }
}

#Preview {
    TimerView()
} 
