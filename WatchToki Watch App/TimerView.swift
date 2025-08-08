//
//  TimerView.swift
//  Toki
//
//  Created by 내꺼다 on 8/8/25.
//

import SwiftUI

public struct TimerView: View {
    @ObservedObject var timerViewModel: TimerViewModel
    
    @Binding var path: [NavigationTarget]
    
//    @Binding var path: NavigationPath
    
//    init(timerViewModel: TimerViewModel, path: Binding<NavigationPath>) {
//        self._timerViewModel = StateObject(wrappedValue: timerViewModel)
//        self._path = path
//    }
    
    public var body: some View {
        VStack {
            Text("\(timerViewModel.timeRemaining.formattedTimeString)")
            
            HStack {
                Button("Cancel") {
                    // 루트뷰로 가야함
                    path = []
                }
                
                Button("Pause") {
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
