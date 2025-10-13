//
//  TimerView.swift
//  Toki
//
//  Created by 내꺼다 on 8/8/25.
//

import SwiftUI

public struct TimerView: View {
    @StateObject private var timerViewModel: TimerViewModel
    @Binding var path: [NavigationTarget]
    
    init(timerViewModel: TimerViewModel, path: Binding<[NavigationTarget]>) {
        self._timerViewModel = StateObject(wrappedValue: timerViewModel)
        self._path = path
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            
            Spacer()

            // 프로그래스바
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.5), lineWidth: 8)
                    .frame(width: 110, height: 110)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 110, height: 110)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progress)
                
                // 남은 시간 표시
                Text(timerViewModel.timeRemaining.formattedTimeString)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .monospacedDigit()
            }
            
            HStack(spacing: 12) {
                Button("취소") {
                    // 루트뷰로 이동
                    path = []
                    timerViewModel.stop()
                }
                .buttonStyle(.bordered)
                .tint(.gray)
                
                Button(timerViewModel.isPaused ? "재생" : "일시정지") {
                    timerViewModel.togglePause()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .onAppear {
            timerViewModel.start()
        }
        .onDisappear {
            timerViewModel.stop()
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("타이머")
    }
    
    // 프로그래스 계산
    private var progress: Double {
        guard timerViewModel.mainDuration > 0 else { return 0 }
        return Double(timerViewModel.timeRemaining) / Double(timerViewModel.mainDuration)
    }
}
