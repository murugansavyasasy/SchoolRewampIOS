//
//  WaveView.swift
//  Pods
//
//  Created by admin on 15/11/24.
//

import UIKit

class WaveView: UIView {
    private var waveLayers: [CAShapeLayer] = []
    private var progressLayer: CALayer = CALayer() // Separate progress layer
    private var displayLink: CADisplayLink?
    
    // Wave configuration
    private var baseAmplitude: CGFloat = 20.0
    private var waveFrequency: CGFloat = 0.5
    private var waveSpeed: CGFloat = 0.1
    private var wavePhase: CGFloat = 0.0
    private var numberOfBars: Int = 40

    // Current amplitude factor from audio level
    private var currentAmplitude: CGFloat = 1.0
    
    // Progress Tracking
    var progress: CGFloat = 0.0  // Added progress tracking for playback
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupWaveBars()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupWaveBars()
        setupGesture()
    }
    
    // MARK: - Wave Setup
    private func setupWaveBars() {
        waveLayers.forEach { $0.removeFromSuperlayer() }
        waveLayers.removeAll()
        
        let barWidth: CGFloat = self.bounds.width / CGFloat(numberOfBars) - 2
        let barSpacing: CGFloat = 1.5
        
        for i in 0..<numberOfBars {
            let barLayer = CAShapeLayer()
            barLayer.fillColor = UIColor.systemBlue.cgColor
            barLayer.strokeColor = UIColor.systemBlue.cgColor
            
            let xPosition = CGFloat(i) * (barWidth + barSpacing)
            barLayer.frame = CGRect(x: xPosition, y: 0, width: barWidth, height: self.bounds.height)
            self.layer.addSublayer(barLayer)
            waveLayers.append(barLayer)
        }
        
        // Progress Layer Setup
        progressLayer.backgroundColor = UIColor.clear.cgColor // Background stays transparent
        progressLayer.frame = CGRect(x: 0, y: 0, width: 0, height: self.bounds.height)
        self.layer.addSublayer(progressLayer)
        
        displayLink = CADisplayLink(target: self, selector: #selector(updateWaveBars))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    // MARK: - Gesture Setup
    private func setupGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleWaveSlide(_:)))
        self.addGestureRecognizer(panGesture)
    }
    
    // MARK: - Gesture Action
    @objc private func handleWaveSlide(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        let waveWidth = self.frame.width
        
        // Calculate progress based on touch position
        progress = max(0, min(location.x / waveWidth, 1.0))
        
        // Notify for playback adjustment
        NotificationCenter.default.post(name: NSNotification.Name("WaveViewSliderChanged"), object: progress)
    }
    
    // MARK: - Amplitude Update
    func updateWithLevel(_ level: CGFloat) {
        currentAmplitude = baseAmplitude * level
    }
    
    // MARK: - Wave Animation
    @objc private func updateWaveBars() {
        wavePhase += waveSpeed
        
        for (index, barLayer) in waveLayers.enumerated() {
            let path = UIBezierPath()
            
            let normalizedIndex = CGFloat(index) / CGFloat(numberOfBars)
            let barHeight = currentAmplitude * sin(normalizedIndex * waveFrequency * 2 * .pi + wavePhase)
            let adjustedHeight = max(5, abs(barHeight))
            
            let centerY = self.bounds.height / 2
            path.move(to: CGPoint(x: 0, y: centerY - adjustedHeight / 2))
            path.addLine(to: CGPoint(x: 0, y: centerY + adjustedHeight / 2))
            
            barLayer.path = path.cgPath
            
            // ✅ Bar color changes based on playback progress
            let progressPosition = CGFloat(index) / CGFloat(numberOfBars)
            let isInProgress = progressPosition <= progress
            
            let color = isInProgress
                ? UIColor.systemGreen.cgColor  // Bars that have been played
                : UIColor.systemBlue.cgColor  // Bars yet to be played
            
            barLayer.fillColor = color
            barLayer.strokeColor = color
        }
    }
    
    deinit {
        displayLink?.invalidate()
    }
}

// MARK: WhatsApp Audio SeekBar
//class WaveView: UIView {
//
//    // MARK: - Properties
//    private var canvasWidth: CGFloat = 0
//    private var canvasHeight: CGFloat = 0
//    private let wavePaint = CAShapeLayer()
//    private let markerLayer = CAShapeLayer()
//    private var progressLayer = CAShapeLayer()
//    private var touchDownX: CGFloat = 0
//    private var alreadyMoved = false
//    private var maxSampleValue: Int = 0
//    private var scaledTouchSlop: CGFloat = 10
//
//    var onProgressChanged: ((WaveView, CGFloat, Bool) -> Void)?
//
//    var samples: [Int]? {
//        didSet {
//            updateMaxSampleValue()
//            setNeedsDisplay()
//        }
//    }
//
//    var progress: CGFloat = 0 {
//        didSet {
//            setNeedsDisplay()
//            updateWaveformProgress()
//            onProgressChanged?(self, progress, false)
//        }
//    }
//
//    var maxProgress: CGFloat = 100 {
//        didSet {
//            setNeedsDisplay()
//        }
//    }
//
//    var waveBackgroundColor: UIColor = .lightGray {
//        didSet {
//            setNeedsDisplay()
//        }
//    }
//
//    var waveProgressColor: UIColor = .white {
//        didSet {
//            setNeedsDisplay()
//        }
//    }
//
//    var waveGap: CGFloat = 2 {
//        didSet {
//            setNeedsDisplay()
//        }
//    }
//
//    var waveWidth: CGFloat = 5 {
//        didSet {
//            setNeedsDisplay()
//        }
//    }
//
//    var waveMinHeight: CGFloat = 5 {
//        didSet {
//            setNeedsDisplay()
//        }
//    }
//
//    var waveCornerRadius: CGFloat = 2 {
//        didSet {
//            setNeedsDisplay()
//        }
//    }
//
//    var wavePadding: UIEdgeInsets = .zero {
//        didSet {
//            setNeedsDisplay()
//        }
//    }
//
//    var markers: [CGFloat: String]? {
//        didSet {
//            setNeedsDisplay()
//        }
//    }
//
//    var markerWidth: CGFloat = 1 {
//        didSet {
//            setNeedsDisplay()
//        }
//    }
//
//    var markerColor: UIColor = .green {
//        didSet {
//            setNeedsDisplay()
//        }
//    }
//
//    var markerTextColor: UIColor = .red {
//        didSet {
//            setNeedsDisplay()
//        }
//    }
//
//    var markerTextSize: CGFloat = 12 {
//        didSet {
//            setNeedsDisplay()
//        }
//    }
//
//    var markerTextPadding: CGFloat = 2 {
//        didSet {
//            setNeedsDisplay()
//        }
//    }
//
//    // MARK: - Initialization
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setup()
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setup()
//    }
//
//    private func setup() {
//        layer.addSublayer(progressLayer)
//        layer.addSublayer(markerLayer)
//    }
//
//    // MARK: - Drawing
//    override func draw(_ rect: CGRect) {
//        guard let samples = samples, !samples.isEmpty else { return }
//        let context = UIGraphicsGetCurrentContext()
//        context?.clear(rect)
//
//        let totalWaveWidth = waveWidth + waveGap
//        let step = CGFloat(samples.count) / (canvasWidth / totalWaveWidth)
//
//        var previousWaveRight = wavePadding.left
//        let availableHeight = canvasHeight - wavePadding.top - wavePadding.bottom
//
//        for i in stride(from: 0, to: samples.count, by: Int(step)) {
//            let sample = samples[i]
//            let waveHeight = max(waveMinHeight, availableHeight * CGFloat(sample) / CGFloat(maxSampleValue))
//            let waveTop = wavePadding.top + (availableHeight - waveHeight) / 2
//
//            let waveRect = CGRect(x: previousWaveRight, y: waveTop, width: waveWidth, height: waveHeight)
//            drawWave(in: waveRect, context: context)
//
//            previousWaveRight += totalWaveWidth
//        }
//
//        drawMarkers()
//    }
//
//    private func drawWave(in rect: CGRect, context: CGContext?) {
//        context?.setFillColor(waveBackgroundColor.cgColor)
//        let path = UIBezierPath(roundedRect: rect, cornerRadius: waveCornerRadius)
//        context?.addPath(path.cgPath)
//        context?.fillPath()
//    }
//
//    private func drawMarkers() {
//        guard let markers = markers else { return }
//        for (position, label) in markers {
//            let markerX = canvasWidth * (position / maxProgress)
//            drawMarker(at: markerX, label: label)
//        }
//    }
//
//    private func drawMarker(at x: CGFloat, label: String) {
//        let path = UIBezierPath(rect: CGRect(x: x - markerWidth / 2, y: 0, width: markerWidth, height: canvasHeight))
//        markerColor.setFill()
//        path.fill()
//
//        let textAttributes: [NSAttributedString.Key: Any] = [
//            .font: UIFont.systemFont(ofSize: markerTextSize),
//            .foregroundColor: markerTextColor
//        ]
//        let textSize = label.size(withAttributes: textAttributes)
//        let textRect = CGRect(x: x - textSize.width / 2, y: canvasHeight - textSize.height - markerTextPadding, width: textSize.width, height: textSize.height)
//        label.draw(in: textRect, withAttributes: textAttributes)
//    }
//
//    // MARK: - Helpers
//    private func updateMaxSampleValue() {
//        maxSampleValue = samples?.max() ?? 0
//    }
//
//    private func updateWaveformProgress() {
//        let progressWidth = canvasWidth * (progress / maxProgress)
//        let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: progressWidth, height: canvasHeight))
//        progressLayer.path = path.cgPath
//        progressLayer.fillColor = waveProgressColor.cgColor
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        canvasWidth = bounds.width
//        canvasHeight = bounds.height
//    }
//}
