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
            // 남은 시간 표시
            Text(timerViewModel.timeRemaining.formattedTimeString)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .monospacedDigit()
            
            HStack(spacing: 12) {
                Button("취소") {
                    // 루트뷰로 이동
                    path = []
                    timerViewModel.stop()
                }
                .buttonStyle(.bordered)
                .tint(.red)
                
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
}
