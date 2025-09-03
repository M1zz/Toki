//
//  SetNotiView.swift
//  Toki
//
//  Created by 내꺼다 on 8/7/25.
//

import SwiftUI

struct SetNotiView: View {
    @ObservedObject var viewModel: SetNotiViewModel
    
    @Binding var path: [NavigationTarget]
    
    var body: some View {
        //        NavigationStack {
        VStack(spacing: 10) {
            Text("완료 전 알림 설정")

            
            let maxHour = viewModel.maxSelectableTimeModel.hour
            let maxMinute = viewModel.maxSelectableTimeModel.minute
            let maxSecond = viewModel.maxSelectableTimeModel.second
            
            HStack {
                Picker(selection: $viewModel.notiTime.hour, label: Text("시")) {
                    ForEach(0...maxHour, id: \.self) { Text(String(format: "%02d", $0)) }
                }
                .frame(width: 50)
                .clipped()
                .focusable()
                
                Picker(selection: $viewModel.notiTime.minute, label: Text("분")) {
                    ForEach(0...maxMinute, id: \.self) { Text(String(format: "%02d", $0)) }
                }
                .frame(width: 50)
                .clipped()
                .focusable()
                
                Picker(selection: $viewModel.notiTime.second, label: Text("초")) {
                    ForEach(0...maxSecond, id: \.self) { Text(String(format: "%02d", $0)) }
                }
                .frame(width: 50)
                .clipped()
                .focusable()
            }
            .frame(height: 100)
            
            NavigationLink(value: NavigationTarget.timerView(mainDuration: viewModel.maxTimeInSeconds, NotificationDuration: viewModel.notiTime.convertedSecond)) {
                Text("시작")
            }
        }
    }
}

//}


//#Preview {
//    SetNotiView()
//}

// 타이머 설정화면이랑 같게
// 앞에서 시간 입력값 받아서 그것보다 짧게 만들어야 하는데
// 입력받은 값에서 1분(60초) 적은 값까지로 제한 걸어주기 - 초단위는 삭제하는게 나을지 고민하기



// 백그라운드, 워치꺼져있을 때 도 햅틱알림이 있어야?

// 완료 전 알림이니까 만약 5분전이면 지정한 시간에서 -5분을 빼고 타이머를 만드는 겪 -> 결국 완료 전 알림 타이머
