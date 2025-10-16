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
        VStack(spacing: 12) {
            Spacer(minLength: 0)

            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.5), lineWidth: 8)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        Color.accentColor,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progress)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 15, height: 15)
                    .offset(alertMarkerOffset(ringSize: 123, lineWidth: 8))
                
                Text(timerViewModel.timeRemaining.formattedTimeString)
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .minimumScaleFactor(0.5)
            }

            HStack(spacing: 12) {
                Button {
                    path = []
                    timerViewModel.stop()
                } label: {
                    Image(systemName: "xmark.circle")
                        .font(.system(size: 22, weight: .semibold))
                }
                .buttonStyle(.bordered)
                .tint(.gray)
                .frame(height: 44)
                .accessibilityLabel("취소")

                Button {
                    timerViewModel.togglePause()
                } label: {
                    Image(systemName: timerViewModel.isPaused ? "play.fill" : "pause.fill")
                        .font(.system(size: 22, weight: .semibold))
                }
                .buttonStyle(.borderedProminent)
                .frame(height: 44)
                .accessibilityLabel(timerViewModel.isPaused ? "재생" : "일시정지")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .onAppear { timerViewModel.start() }
        .onDisappear { timerViewModel.stop() }
        .navigationBarBackButtonHidden(true)
    }
    
    private var progress: Double {
        guard timerViewModel.mainDuration > 0 else { return 0 }
        return Double(timerViewModel.timeRemaining) / Double(timerViewModel.mainDuration)
    }
    
    private var alertMarkerProgress: Double {
        guard timerViewModel.mainDuration > 0 else { return 0 }
        // Elapsed fraction when the alert should fire. Example: 10m total, alert at 3m remaining -> 0.7
        let value = 1.0 - (Double(timerViewModel.notificationTime) / Double(timerViewModel.mainDuration))
        return min(max(value, 0.0), 1.0)
    }
    
    private func alertMarkerOffset(ringSize: CGFloat, lineWidth: CGFloat) -> CGSize {
        let radius = ringSize / 2
        let r = radius - (lineWidth * 0.25)
        // Place marker clockwise from the top to match the visual expectation
        let angle = Angle.degrees(-90 - (360 * alertMarkerProgress))
        let x = cos(angle.radians) * r
        let y = sin(angle.radians) * r
        return CGSize(width: x, height: y)
    }
}

