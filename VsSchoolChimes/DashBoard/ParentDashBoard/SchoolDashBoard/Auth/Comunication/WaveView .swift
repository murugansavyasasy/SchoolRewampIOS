//
//  WaveView.swift
//  Pods
//
//  Created by admin on 15/11/24.
//

import UIKit

class WaveView: UIView {
    private var waveLayers: [CAShapeLayer] = []
    private var displayLink: CADisplayLink?
    
    // Wave configuration
    private var baseAmplitude: CGFloat = 20.0 // Base height of the wave bars
    private var waveFrequency: CGFloat = 0.5 // Frequency of the wave variation
    private var waveSpeed: CGFloat = 0.1 // Speed of the wave phase shift
    private var wavePhase: CGFloat = 0.0 // Initial phase shift
    private var numberOfBars: Int = 40 // Number of bars in the waveform
    
    // Current amplitude factor from audio level
    private var currentAmplitude: CGFloat = 1.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupWaveBars()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupWaveBars()
    }
    
    private func setupWaveBars() {
        // Remove existing bars if any
        waveLayers.forEach { $0.removeFromSuperlayer() }
        waveLayers.removeAll()
        
        // Calculate the width and spacing of each bar
        let barWidth: CGFloat = self.bounds.width / CGFloat(numberOfBars) - 2
        let barSpacing: CGFloat = 1.5
        
        // Create each bar layer
        for i in 0..<numberOfBars {
            let barLayer = CAShapeLayer()
            barLayer.fillColor = UIColor.systemBlue.cgColor
            barLayer.strokeColor = UIColor.systemBlue.cgColor
            
            // Set initial frame and add to the view's layer
            let xPosition = CGFloat(i) * (barWidth + barSpacing)
            barLayer.frame = CGRect(x: xPosition, y: 0, width: barWidth, height: self.bounds.height)
            self.layer.addSublayer(barLayer)
            waveLayers.append(barLayer)
        }
        
        // Start the display link for animation
        displayLink = CADisplayLink(target: self, selector: #selector(updateWaveBars))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    // New method to update the amplitude based on the audio level
    func updateWithLevel(_ level: CGFloat) {
        // Scale the base amplitude with the normalized audio level
        currentAmplitude = baseAmplitude * level
    }
    
    @objc private func updateWaveBars() {
        wavePhase += waveSpeed
        
        // Update each bar's height and color based on audio level
        for (index, barLayer) in waveLayers.enumerated() {
            let path = UIBezierPath()
            
            // Calculate the height of the bar using a sine function, adjusted by audio level
            let normalizedIndex = CGFloat(index) / CGFloat(numberOfBars)
            let barHeight = currentAmplitude * sin(normalizedIndex * waveFrequency * 2 * .pi + wavePhase)
            let adjustedHeight = max(5, abs(barHeight)) // Ensure a minimum height
            
            // Set the path for each bar, centered vertically
            let centerY = self.bounds.height / 2
            path.move(to: CGPoint(x: 0, y: centerY - adjustedHeight / 2))
            path.addLine(to: CGPoint(x: 0, y: centerY + adjustedHeight / 2))
            
            // Update bar height
            barLayer.path = path.cgPath
            
            // Animate color change based on height (higher bars become lighter)
            let colorLevel = CGFloat(abs(barHeight) / baseAmplitude)
            barLayer.fillColor = UIColor(red: 0.0, green: colorLevel, blue: 1.0, alpha: 1.0).cgColor
            barLayer.strokeColor = UIColor(red: 0.0, green: colorLevel, blue: 1.0, alpha: 1.0).cgColor
        }
    }
    
    deinit {
        displayLink?.invalidate()
    }
}
