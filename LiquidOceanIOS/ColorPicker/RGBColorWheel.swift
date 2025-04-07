//
//  RGBColorWheel.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 4/6/25.
//  Copyright © 2025 Eric Versteeg. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

protocol RGBSelectionDelegate: AnyObject {
    func onRGBChanged()
}

class RGBColorWheel: UIView {
    
    private var w: Int = 0
    private var h: Int = 0
    
    private var indicatorSize: CGFloat = 20
    
    private var indicator: SBIndicator
    
    var rgbSelectionDelegate: RGBSelectionDelegate? = nil
    
    private var pcv: PickedColorValues? = nil
    
    required override init(frame: CGRect) {
        indicator = SBIndicator(frame: CGRect(x: 0, y: 0, width: indicatorSize, height: indicatorSize))
        
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init(coder: NSCoder) {
        indicator = SBIndicator(frame: CGRect(x: 0, y: 0, width: indicatorSize, height: indicatorSize))
        
        super.init(coder: coder)!
        
        commonInit()
    }
    
    func commonInit() {
        let dgr = UIDrawGestureRecognizer(target: self, action: #selector(didDraw(sender:)))
        dgr.delaysTouchesBegan = false
        addGestureRecognizer(dgr)
        
        indicator.backgroundColor = UIColor.clear
        addSubview(indicator)
    }
    
    override func layoutSubviews() {
        w = Int(frame.width)
        h = Int(frame.height)
        
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let ctx = UIGraphicsGetCurrentContext()!
        
        if let pcv = pcv {
            drawColorWheel(context: ctx, pcv: pcv)
        }
        
        moveIndicator()
    }
    
    // By Claude
    private func drawColorWheel(context: CGContext, pcv: PickedColorValues) {
        // Number of segments to create the wheel (increasing for smoother transitions)
        let segments = 360 // Doubled from 360 for smoother transitions
        let angleIncrement = CGFloat(2.0 * Double.pi / Double(segments))
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2.0
        
        // Draw white circle background first to ensure center is white
        context.setFillColor(UIColor.white.cgColor)
        context.addArc(center: center, radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: false)
        context.fillPath()
        context.setAllowsAntialiasing(false)
        context.setShouldAntialias(false)
        
        for i in 0..<segments {
            // Calculate the angle for this segment
            let angle = CGFloat(i) * angleIncrement
            let nextAngle = angle + angleIncrement
            
            // Create a path for this segment (pie slice)
            context.saveGState()
            context.move(to: center)
            context.addArc(center: center, radius: radius, startAngle: angle, endAngle: nextAngle, clockwise: false)
            context.closePath()
            
            // Create a gradient from center (white/low saturation) to edge (full saturation)
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let hue = angle / (2.0 * CGFloat.pi)
            
            // Create gradient colors
            // Start with white in the center
            let centerColor = UIColor(hue: hue, saturation: 0, brightness: pcv.b, alpha: 1.0).cgColor
            
            // Edge color (full saturation, same hue)
            let edgeColor = UIColor(hue: hue, saturation: 1.0, brightness: pcv.b, alpha: 1.0).cgColor
            
            let colors = [centerColor, edgeColor] as CFArray
            
            // Use more control points to make the gradient smoother
            let locations: [CGFloat] = [0.0, 1.0]
            
            // Create the gradient
            if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) {
                // Draw the gradient within the segment path
                context.clip()
                
                // Use radial gradient instead of linear for smoother transitions
                context.drawRadialGradient(
                    gradient,
                    startCenter: center,
                    startRadius: 0,
                    endCenter: center,
                    endRadius: radius,
                    options: []
                )
            }
            
            context.restoreGState()
        }
        
        // Optional: draw a subtle border around the wheel for definition
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(1 / UIScreen.main.scale)
        context.addArc(center: center, radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: false)
        context.strokePath()
    }
    
    // By Claude
    func colorAt(point: CGPoint) -> UIColor? {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2.0
        
        // Calculate distance from center
        let dx = point.x - center.x
        let dy = point.y - center.y
        let distance = sqrt(dx * dx + dy * dy)
        
        // Check if the point is within the wheel's radius
        guard distance <= radius else {
            return nil // Point is outside the color wheel
        }
        
        // Calculate angle (in radians, 0 is to the right, increasing counterclockwise)
        var angle = atan2(dy, dx)
        
        // Convert to positive angle (0 to 2π)
        if angle < 0 {
            angle += 2.0 * .pi
        }
        
        // Convert angle to hue (0 to 1)
        let hue = angle / (2.0 * .pi)
        
        // Optional: Use distance from center for saturation
        // This creates a wheel where center is white and edge has pure colors
        // Comment this out if you want full saturation everywhere
        // let saturation = distance / radius
        
        // Use fixed saturation (full color)
        let saturation: CGFloat = distance / radius
        
        // Create and return the color
        return UIColor(hue: hue, saturation: saturation, brightness: pcv?.b ?? 1.0, alpha: 1.0)
    }
    
    // By Claude
    func pointForColor(h: CGFloat, s: CGFloat) -> CGPoint {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2.0
        
        // Convert hue to angle (0 to 2π)
        let angle = h * 2.0 * .pi
        
        // Calculate the distance from center based on saturation
        // Full saturation (1.0) is at the edge of the wheel
        let distance = s * radius
        
        // Calculate x, y coordinates from angle and distance
        let x = center.x + distance * cos(angle)
        let y = center.y + distance * sin(angle)
        
        return CGPoint(x: x, y: y)
    }
    
    @objc func didDraw(sender: UIDrawGestureRecognizer) {
        let location = sender.location(in: self)

        if sender.state == .began || sender.state == .changed {
            if let pcv = pcv {
                let rgbColor = colorAt(point: location)
                if let rgbColor = rgbColor {
                    var hue: CGFloat = 0
                    var saturation: CGFloat = 0
                    var brightness: CGFloat = 0
                    var alpha: CGFloat = 0
                    
                    rgbColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
                    
                    pcv.h = hue
                    pcv.s = saturation
                    pcv.b = brightness
                    
                    moveIndicator()
                    
                    rgbSelectionDelegate?.onRGBChanged()
                }
            }
        }
    }
    
    func moveIndicator() {
        if let pcv = pcv {
            let colorPoint = pointForColor(h: pcv.h, s: pcv.s)
            
            indicator.frame = CGRect(x: colorPoint.x - indicatorSize / 2,
                                     y: colorPoint.y - indicatorSize / 2, width: indicatorSize, height: indicatorSize)
            indicator.setNeedsDisplay()
        }
    }
    
    func setPCV(pcv: PickedColorValues) {
        self.pcv = pcv
        setNeedsDisplay()
        moveIndicator()
    }
}

