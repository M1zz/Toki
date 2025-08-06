//
//  SettingView.swift
//  Toki
//
//  Created by 내꺼다 on 8/6/25.
//

import SwiftUI

struct SettingView: View {
    // 시, 분, 초 저장할 변수
    @State private var selectedHour = 0
    @State private var selectedMinute = 0
    @State private var selectedSecond = 0
    
    var body: some View {
        VStack(spacing: 10) {
            Text("타이머 시간 설정하기")
            
            HStack {
                Picker(selection: $selectedHour, label: Text("시")) {
                    // 24까지 할지는 더 고민해보기
                    ForEach(0..<24) { Text(String(format: "%02d", $0)) }
                }
                .frame(width: 50)
                .clipped()
                .focusable()
                
                Picker(selection: $selectedMinute, label: Text("분")) {
                    ForEach(0..<60) { Text(String(format: "%02d", $0)) }
                }
                .frame(width: 50)
                .clipped()
                .focusable()
                
                Picker(selection: $selectedSecond, label: Text("초")) {
                    ForEach(0..<60) { Text(String(format: "%02d", $0)) }
                }
                .frame(width: 50)
                .clipped()
                .focusable()
            }
            .frame(height: 100)
            
            Button("다음") {
                // 여기서 액션 넣어주기
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

// 워치 크기별 반응형 UI로 수정해야함
// 몇분 전 울릴지.. 설정..
