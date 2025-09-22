//
//  SettingView.swift
//  Toki
//
//  Created by 내꺼다 on 8/6/25.
//

import SwiftUI

enum NavigationTarget: Hashable {
    case setNotiView
    case timerView(mainDuration: Int, NotificationDuration: Int)
}

struct SettingView: View {    
    @StateObject private var settingViewModel = SettingViewModel()
    
    @State private var path: [NavigationTarget] = []
    
    var totalTime: Int {
        settingViewModel.time.convertedSecond
    }
    
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 10) {
                
                Text("타이머 시간 설정")
                                
                Picker(selection: $settingViewModel.time.minute, label: Text("분")) {
                    ForEach(1...60, id: \.self) { minute in
                        Text("\(minute)")
                    }
                }
                .frame(width: 70)
                .clipped()
                .focusable()
                
                .frame(height: 100)
                
                NavigationLink(value: NavigationTarget.setNotiView) {
                    Text("다음")
                }
            }
            .navigationDestination(for: NavigationTarget.self) { target in
                switch target {
                case .setNotiView:
                    SetNotiView(viewModel: SetNotiViewModel(maxTimeInSeconds: totalTime),
                                path: $path
                    )
                case .timerView(let mainDuration, let notificationDuration):
                    TimerView(timerViewModel: TimerViewModel(
                        mainDuration: mainDuration, notificationDuration: notificationDuration
                    ), path: $path)
                    
                }
            }            
        }
    }
}



#Preview {
    SettingView()
}





// 디자인 기본 타이머 비슷하게 피커로
// 시, 분, 초? 각각 독립적으로 돌아가고
// 시작 눌렀을 때 각 피커 값들 다음 화면으로 전달



// 워치 크기별 반응형 UI로 수정해야함 - 다음에

