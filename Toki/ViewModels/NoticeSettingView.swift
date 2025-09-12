//
//  NoticeSettingView.swift
//  Toki
//
//  Created by POS on 7/8/25.
//

import SwiftUI

struct NoticeSettingView: View {
    @AppStorage("ringMode") private var ringMode: RingMode = .sound
    @AppStorage("pushEnabled") private var pushEnabled: Bool = true
    @AppStorage("toastEnabled") private var toastEnabled: Bool = true

    var body: some View {
        Form {
            HStack(spacing: 16){
                Text("알림 스타일")
                Picker("notice", selection: $ringMode) {
                    ForEach(RingMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }

            Toggle("푸시 알림 보내기", isOn: $pushEnabled)
            
            Toggle("토스트 메세지 표시", isOn: $toastEnabled)
        }
    }
}

#Preview {
    NoticeSettingView()
}
