//
//  HPalette.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 3/7/25.
//  Copyright © 2025 Eric Versteeg. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

protocol HueSelectionDelegate: AnyObject {
    func onHueSelected(hue: CGFloat)
}

class HPalette: UIView {
    
    private var w: Int = 0
    private var h: Int = 0
    
    private var hue: CGFloat = 0
    private var minHue: CGFloat = 0
    private var maxHue: CGFloat = 360
    
    private var indicator: HIndicator
    private var indicatorWidth: CGFloat = 5
    
    var hueSelectionDelegate: HueSelectionDelegate? = nil
    
    required override init(frame: CGRect) {
        indicator = HIndicator(frame: CGRect(x: 0, y: 0, width: indicatorWidth, height: 0))
            
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init(coder: NSCoder) {
        indicator = HIndicator(frame: CGRect(x: 0, y: 0, width: indicatorWidth, height: 0))
        
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
        drawHuePalette(on: ctx)
        
        moveIndicator()
    }
    
    // Converted from Kotlin by Claude
    private func drawHuePalette(on context: CGContext) {
        let wf = CGFloat(w)
        
        var pixels = [UInt32](repeating: 0, count: w * h)
        
        for x in 0..<w {
            let h = CGFloat(x) / wf * maxHue
            
            // Convert hue to UIColor using HSB color space
            let color = UIColor(hue: CGFloat(h / maxHue), saturation: 1.0, brightness: 1.0, alpha: 1.0)
            
            // Convert UIColor to RGBA format
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            
            color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            // Pack RGBA values into UInt32
            let r = UInt32(red * 255.0)
            let g = UInt32(green * 255.0)
            let b = UInt32(blue * 255.0)
            let a = UInt32(alpha * 255.0)
            
            // RGBA8888 format
            pixels[x] = (a << 24) | (b << 16) | (g << 8) | r
        }
        
        // Create a bitmap from the pixel data
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let provider = CGDataProvider(data: Data(bytes: pixels, count: w * MemoryLayout<UInt32>.size) as CFData) else {
            return
        }
        
        guard let image = CGImage(
            width: w,
            height: 1,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: w * MemoryLayout<UInt32>.size,
            space: colorSpace,
            bitmapInfo: bitmapInfo,
            provider: provider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        ) else {
            return
        }
        
        // Scale the image to desired size
        context.saveGState()
        context.interpolationQuality = .none
        context.draw(image, in: CGRect(x: 0, y: 0, width: w, height: h))
        context.restoreGState()
    }
    
    @objc func didDraw(sender: UIDrawGestureRecognizer) {
        let location = sender.location(in: self)

        if sender.state == .began || sender.state == .changed {
            hue = max(min(location.x / CGFloat(w) * maxHue, maxHue), minHue)
            hueSelectionDelegate?.onHueSelected(hue: hue)
            
            print("hue = \(hue)")
            
            moveIndicator()
        }
    }
    
    private func moveIndicator() {
        indicator.frame = CGRect(x: CGFloat(w) * (hue / maxHue) - indicatorWidth / 2,
                                 y: 0, width: indicatorWidth, height: frame.height)
        indicator.setNeedsDisplay()
    }
    
    func setColor(color: UIColor) {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        self.hue = hue * maxHue
        
        setNeedsDisplay()
    }
}
