//
//  TimerView.swift
//  Toki
//
//  Created by 내꺼다 on 8/8/25.
//

import SwiftUI

public struct TimerView: View {
    @StateObject private var timerViewModel: TimerViewModel
//    @ObservedObject var timerViewModel: TimerViewModel
    
    @Binding var path: [NavigationTarget]
    
//    @Binding var path: NavigationPath
    
    init(timerViewModel: TimerViewModel, path: Binding<[NavigationTarget]>) {
        self._timerViewModel = StateObject(wrappedValue: timerViewModel)
        self._path = path
    }
    
    public var body: some View {
        VStack {
            Text("\(timerViewModel.timeRemaining.formattedTimeString)")
            
            HStack {
                Button("취소") {
                    // 루트뷰로 가야함
                    path = []
                }
                
                Button(timerViewModel.isPaused ? "재생" : "일시정지") {
                    timerViewModel.togglePause()
                }
            }
        }
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


//#Preview {
//        TimerView()
//}


// 취소 / 일시정지 
// 일시정지 -> 타이머 멈춤
// 취소 타이머 설정으로 돌아가기
