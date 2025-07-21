//
//  PreTimer.swift
//  Toki
//
//  Created by POS on 7/20/25.
//

import Foundation
import SwiftUI

struct PreTimerSelectorViewModel: View {
    let alertTimeOptions: [Int]
    @Binding var selectedAlertTimes: Set<Int>
    var isSettingMode: Bool
    var toggleAlertTime: (Int) -> Void

    var body: some View {
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
                            .foregroundColor(
                                selectedAlertTimes.contains(minutes)
                                    ? .white : .primary
                            )
                            .frame(width: 50, height: 50)
                            .background(
                                Circle()
                                    .fill(
                                        selectedAlertTimes.contains(minutes)
                                            ? Color.black
                                            : Color.gray.opacity(0.2)
                                    )
                            )
                    }
                    .disabled(!isSettingMode)
                    .opacity(isSettingMode ? 1.0 : 0.6)
                }
            }
        }
    }
}
