//
//  RingDebugView.swift
//  Toki
//
//  Created by POS on 7/8/25.
//

import SwiftUI

struct RingDebugView: View {
    @AppStorage("ringMode") private var ringMode: RingMode = .sound
    @AppStorage("pushEnabled") private var pushEnabled: Bool = true

    var body: some View {
        Form {
            Picker("notice", selection: $ringMode) {
                ForEach(RingMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            Toggle("푸시 알림 보내기", isOn: $pushEnabled)

            Button("ring() Test") {
                ring()
            }
            Button("pushNotice() Test - 4초뒤 푸시수신") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    pushNotice()
                }
            }
        }
    }
}

#Preview {
    RingDebugView()
}
