import SwiftUI
import UIKit

struct CircularProgressView: UIViewRepresentable {
    let progress: Double
    let totalTime: TimeInterval
    let remainingTime: TimeInterval
    @Binding var selectedMinutes: Int
    let isSettingMode: Bool
    let onTimeChanged: (Int) -> Void
    
    func makeUIView(context: Context) -> CircularProgressUIView {
        let view = CircularProgressUIView()
        view.onTimeChanged = onTimeChanged
        return view
    }
    
    func updateUIView(_ uiView: CircularProgressUIView, context: Context) {
        uiView.updateProgress(progress: progress, isSettingMode: isSettingMode, selectedMinutes: selectedMinutes)
    }
}

class CircularProgressUIView: UIView {
    private var progressLayer: CAShapeLayer!
    private var trackLayer: CAShapeLayer!
    private var handleLayer: CAShapeLayer!
    private var numberLabels: [CATextLayer] = []
    
    var onTimeChanged: ((Int) -> Void)?
    private var isDragging = false
    private var hasInitializedPosition = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
        setupGestures()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayerFrames()
        
        // 처음 레이아웃될 때만 초기 위치 설정
        if !hasInitializedPosition && bounds.width > 0 && bounds.height > 0 {
            hasInitializedPosition = true
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                // 25분에 해당하는 진행률로 초기 위치 설정
                let initialProgress = 25.0 / 60.0
                self.updateHandlePosition(progress: initialProgress)
            }
        }
    }
    
    private func setupLayers() {
        // 배경 원 (회색 점선)
        trackLayer = CAShapeLayer()
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = UIColor.systemRed.withAlphaComponent(0.3).cgColor
        trackLayer.lineWidth = 2
        trackLayer.lineDashPattern = [4, 4]
        layer.addSublayer(trackLayer)
        
        // 진행 원 (빨간색)
        progressLayer = CAShapeLayer()
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.systemRed.cgColor
        progressLayer.lineWidth = 8
        progressLayer.lineCap = .round
        layer.addSublayer(progressLayer)
        
        // 손잡이 (흰색 원)
        handleLayer = CAShapeLayer()
        handleLayer.fillColor = UIColor.white.cgColor
        handleLayer.strokeColor = UIColor.systemRed.cgColor
        handleLayer.lineWidth = 3
        layer.addSublayer(handleLayer)
        
        setupNumberLabels()
    }
    
    private func setupNumberLabels() {
        // 숫자 레이블들 (0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55)
        let numbers = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]
        
        for (index, number) in numbers.enumerated() {
            let textLayer = CATextLayer()
            textLayer.string = "\(number)"
            textLayer.fontSize = 16
            textLayer.foregroundColor = UIColor.systemRed.cgColor
            textLayer.alignmentMode = .center
            textLayer.contentsScale = UIScreen.main.scale
            
            // 폰트 설정
            let font = UIFont.systemFont(ofSize: 16, weight: .medium)
            textLayer.font = font
            
            numberLabels.append(textLayer)
            layer.addSublayer(textLayer)
        }
    }
    
    private func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        handleTouch(at: location, gesture: gesture)
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        handleTouch(at: location, gesture: gesture)
    }
    
    private func handleTouch(at location: CGPoint, gesture: UIGestureRecognizer) {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - 40
        
        // 터치 지점이 원형 영역 내부인지 확인
        let distance = sqrt(pow(location.x - center.x, 2) + pow(location.y - center.y, 2))
        guard distance <= radius + 30 && distance >= radius - 30 else { return }
        
        // 각도 계산
        let deltaX = location.x - center.x
        let deltaY = location.y - center.y
        var angle = atan2(deltaY, deltaX)
        
        // 12시 방향을 0으로 조정
        angle = angle + CGFloat.pi / 2
        if angle < 0 {
            angle += 2 * CGFloat.pi
        }
        
        // 각도를 분으로 변환 (0-60분)
        let minutes = Int((angle / (2 * CGFloat.pi)) * 60)
        let clampedMinutes = max(1, min(60, minutes == 0 ? 60 : minutes))
        
        onTimeChanged?(clampedMinutes)
    }
    
    private func updateLayerFrames() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - 40
        
        // 원형 경로 생성 (12시 방향부터 시작)
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + 2 * CGFloat.pi
        let circularPath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        
        trackLayer.path = circularPath.cgPath
        progressLayer.path = circularPath.cgPath
        
        // 숫자 레이블 위치 설정
        let labelRadius = radius + 25
        for (index, textLayer) in numberLabels.enumerated() {
            let angle = startAngle + (CGFloat(index) * 2 * CGFloat.pi / 12)
            let x = center.x + labelRadius * cos(angle)
            let y = center.y + labelRadius * sin(angle)
            
            textLayer.frame = CGRect(x: x - 15, y: y - 10, width: 30, height: 20)
        }
        
        // 손잡이 크기 설정
        let handleRadius: CGFloat = 8
        handleLayer.path = UIBezierPath(
            arcCenter: CGPoint.zero,
            radius: handleRadius,
            startAngle: 0,
            endAngle: 2 * CGFloat.pi,
            clockwise: true
        ).cgPath
    }
    
    func updateProgress(progress: Double, isSettingMode: Bool, selectedMinutes: Int) {
        if isSettingMode {
            // 설정 모드: 선택된 분수에 비례해서 빨간색 길이 설정 (60분 기준)
            let progressValue = Double(selectedMinutes) / 60.0
            progressLayer.strokeEnd = CGFloat(progressValue)
            updateHandlePosition(progress: progressValue)
        } else {
            // 타이머 모드: 남은 시간에 따라 진행률 표시 (설정된 시간 기준으로 줄어듦)
            progressLayer.strokeEnd = CGFloat(progress)
            updateHandlePosition(progress: progress)
        }
    }
    
    private func updateHandlePosition(progress: Double) {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - 40
        
        // 진행률에 따른 각도 계산 (12시 방향부터 시작)
        let startAngle = -CGFloat.pi / 2
        let currentAngle = startAngle + CGFloat(progress) * 2 * CGFloat.pi
        
        // 손잡이 위치 계산
        let handleX = center.x + radius * cos(currentAngle)
        let handleY = center.y + radius * sin(currentAngle)
        
        // 손잡이 위치 업데이트
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        handleLayer.position = CGPoint(x: handleX, y: handleY)
        CATransaction.commit()
    }
} 