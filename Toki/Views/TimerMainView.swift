//
//  TimerMainView.swift
//  Toki
//
//  Created by Oh Seojin on 9/24/25.
//

import SwiftUI

struct TimerMainView: View {
    @EnvironmentObject var screenVM: TimerScreenViewModel
    var size: CGFloat = 240
    var lineWidth: CGFloat = 20
    private var totalSec: Int { screenVM.configuredMainSeconds }
    private var remaining: TimeInterval { screenVM.remaining }
    
    private var ratio: CGFloat {
        guard totalSec > 0 else { return 0 }
        return CGFloat(max(0, min(1, remaining / TimeInterval(totalSec))))
    }
    private var markers: [CGFloat] {
        guard totalSec > 0 else { return [] }
        return screenVM.selectedOffsets
            .filter { 0 < $0 && $0 < totalSec }
            .sorted()
            .map { CGFloat($0) / CGFloat(totalSec) }
    }

    var body: some View {
        let mainSeconds = screenVM.mainMinutes * 60 + screenVM.mainSeconds
        VStack(spacing: 20) {
            ZStack {
                // 시계 눈금
                ZStack {
                    ForEach(1...TimeMapper.tickCount, id: \.self) { index in
                        Rectangle()
                            .fill(.black)
                            .frame(
                                width: index % 5 == 0 ? 3 : 2,
                                height: index % 5 == 0
                                    ? lineWidth / 2 : lineWidth / 4
                            )
                            .offset(y: (size - lineWidth) / 2 - 2)
                            .rotationEffect(.init(degrees: Double(index) * 6))
                    }
                }

                // 원형 배경
                Circle()
                    .stroke(
                        .gray,
                        style: StrokeStyle(
                            lineWidth: lineWidth,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .frame(width: size, height: size)

//                ClockMarkers(
//                    remaining: ratio,
//                    markers: markers,
//                    dotSize: 15,
//                    inset: 0,
//                    upcoming: true
//                )
//                .frame(width: size, height: size)
                
                // Progress
                Circle()
                    .trim(
                        from: 0,
                        to: screenVM.mainAngle / TimeMapper.maxAngle
                    )
                    .stroke(
                        Color.accentColor,
                        style: StrokeStyle(
                            lineWidth: lineWidth,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .frame(width: size, height: size)
                    .rotationEffect(.init(degrees: -90))
                
                // Drag Pointer
                Circle()
                    .fill(.white)
                    .frame(width: lineWidth, height: lineWidth)
                    .offset(x: size / 2)
                    .rotationEffect(.degrees(screenVM.mainAngle))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                withAnimation(.linear(duration: 0.3)) {
                                    onDrag(value: value)
                                }
                            }
                            .onEnded { _ in
                                let snapped = snappedAngle(from: screenVM.mainAngle)
                                withAnimation {
                                    screenVM.mainAngle = snapped
                                }
                            }
                    )
                    .rotationEffect(.init(degrees: -90))

                Text(screenVM.state == .running ? mmss(from:  screenVM.configuredMainSeconds) : mmss(sec: screenVM.mainSeconds, min: screenVM.mainMinutes))
            }
            
            TimerButton(
                state: screenVM.timerVM.state,
                onStart: {
                    screenVM.applyCurrentSettings()
                    screenVM.start()
                },
                onPause: { screenVM.pause() },
                onResume: { screenVM.resume() },
                onCancel: { screenVM.cancel() }
            )
            
            Divider()

            VStack(alignment: .leading, spacing: 12) {
                let presets = Timer.presetOffsetsSec

                VStack(alignment: .leading, spacing: 8) {
                    Text("예비 알림").font(.subheadline).foregroundStyle(
                        .secondary
                    )
                    HStack {
                        ForEach(presets, id: \.self) { sec in
                            let isDisabled = sec >= mainSeconds
                            Toggle(
                                "\(sec/60)분",
                                isOn: Binding(
                                    get: {
                                        screenVM.selectedOffsets.contains(
                                            sec
                                        )
                                    },
                                    set: { on in
                                        if on {
                                            screenVM.selectedOffsets.insert(
                                                sec
                                            )
                                        } else {
                                            screenVM.selectedOffsets.remove(
                                                sec
                                            )
                                        }
                                        screenVM.showPrealertToast(for: sec, isEnabled: on)
                                    }
                                )
                            )
                            .toggleStyle(.button)
                            .buttonStyle(.bordered)
                            .disabled(isDisabled)
                        }
                    }
                }
            }
        }
        .onAppear() {
            print(screenVM.mainAngle / TimeMapper.maxAngle)
        }
    }
    
    private func mmss(from sec: Int) -> String {
        let t = max(0, sec)
        let m = t / 60
        let s = t % 60
        return String(format: "%02d:%02d", m, s)
    }
    
    private func mmss(sec: Int, min: Int) -> String {
        return String(format: "%02d:%02d", min, sec)
    }
    
    func snappedAngle(from rawAngle: Double) -> Double {
        let totalSeconds = rawAngle * TimeMapper.secondsPerDegree
        let snappedSeconds = (totalSeconds / TimeMapper.secondsPerDegree).rounded() * TimeMapper.secondsPerDegree
        return snappedSeconds / TimeMapper.secondsPerDegree  // 도(degree) 단위로 환산
    }
    
    func onDrag(value: DragGesture.Value) {
        let vector = CGVector(dx: value.location.x, dy: value.location.y)
        let radians = atan2(vector.dy, vector.dx)  // 벡터가 x축과 이루는 각도를 구함
        var newAngle = radians * 180 / .pi
        if newAngle < 0 { newAngle = 360 + newAngle }
        
        var d = newAngle - screenVM.mainAngle
        if d > 180 { d -= 360 }
        if d < -180 { d += 360 }
        
        var next = screenVM.mainAngle + d
        if next > 360 { next = 360 }
        if next < 0 { next = 0 }
        
        let snapped = snappedAngle(from: next)
        screenVM.mainAngle = snapped
    }
}

#Preview {
    TimerMainView()
        .environmentObject(TimerScreenViewModel())

}
