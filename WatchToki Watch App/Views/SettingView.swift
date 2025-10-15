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
    
    private var minuteRange: ClosedRange<Int> { 1...60 }
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 12) {
                TimePicker()
                
                Spacer() // ✅ 버튼을 아래로 밀기
                
                NextButton()
                    .buttonStyle(.borderedProminent)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
            }
            .onAppear {
                if !(minuteRange.contains(settingViewModel.time.minute)) || settingViewModel.time.minute == 0 {
                    settingViewModel.time.minute = 30
                }
            }
            .navigationDestination(for: NavigationTarget.self) { target in
                destination(for: target)
            }
        }
    }
    
    @ViewBuilder
    private func TimePicker() -> some View {
        HStack(alignment: .center, spacing: 8) {
            MinuteWheel(selectedMinute: $settingViewModel.time.minute, range: minuteRange, selectionOffset: 0)
                .frame(width: 90, height: 90)
            
            Text("분")
                .font(.system(size: 40, weight: .semibold, design: .rounded))
                .accessibilityHidden(true)
        }
    }
    
    @ViewBuilder
    private func NextButton() -> some View {
        NavigationLink(value: NavigationTarget.setNotiView) {
            Text("타이머 설정") // ✅ "다음" 대신 명확한 텍스트
                .frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder
    private func destination(for target: NavigationTarget) -> some View {
        switch target {
        case .setNotiView:
            SetNotiView(
                viewModel: SetNotiViewModel(maxTimeInSeconds: totalTime),
                path: $path
            )
        case .timerView(let mainDuration, let notificationDuration):
            TimerView(
                timerViewModel: TimerViewModel(
                    mainDuration: mainDuration,
                    notificationDuration: notificationDuration
                ),
                path: $path
            )
        }
    }
    
    private struct MinuteWheel: View {
        @Binding var selectedMinute: Int
        let range: ClosedRange<Int>
        let selectionOffset: CGFloat

        @State private var scrollID: Int?

        private let rowHeight: CGFloat = 45

        var body: some View {
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    ForEach(Array(range), id: \.self) { minute in
                        Text("\(minute)")
                            .font(.system(size: 40, weight: .semibold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(minute == selectedMinute ? Color.white : Color.gray.opacity(0.5))
                            .frame(height: rowHeight)
                            .frame(maxWidth: .infinity)
                            .id(minute)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
            .scrollTargetLayout()
            .contentMargins(.vertical, (90 - rowHeight) / 2, for: .scrollContent)
            .contentMargins(.vertical, selectionOffset, for: .scrollContent)
            .scrollPosition(id: $scrollID)
            .onChange(of: scrollID) { _, newID in
                if let m = newID { selectedMinute = m }
            }
            .onChange(of: selectedMinute) { _, newValue in
                if scrollID != newValue {
                    scrollID = newValue
                }
            }
            .sensoryFeedback(.alignment, trigger: selectedMinute)
            .onAppear {
                if !range.contains(selectedMinute) {
                    selectedMinute = range.lowerBound
                }
                scrollID = selectedMinute
            }
            .frame(width: 90, height: 90)
            .clipped()
            .contentShape(Rectangle())
        }
    }
}

#Preview {
    SettingView()
}
