//
//  HPalette.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 4/5/25.
//  Copyright © 2025 Eric Versteeg. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

protocol BSelectionDelegate: AnyObject {
    func onBChanged()
}

class BPalette: UIView {
    
    private var w: Int = 0
    private var h: Int = 0
    
    private var indicator: SBIndicator
    private var indicatorSize: CGFloat = 20
    
    var bSelectionDelegate: BSelectionDelegate? = nil
    
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
            drawBPalette(on: ctx, pcv: pcv)
        }
        
        moveIndicator()
    }
    
    // Converted from Kotlin by Claude
    private func drawBPalette(on context: CGContext, pcv: PickedColorValues) {

        let wf = CGFloat(w)
        
        var pixels = [UInt32](repeating: 0, count: w * h)
        
        for x in 0..<w {
            let b = CGFloat(x) / wf * pcv.maxValue
            
            // Convert hue to UIColor using HSB color space
            let color = UIColor(hue: pcv.h, saturation: pcv.s, brightness: b, alpha: 1.0)
            
            // Convert UIColor to RGBA format
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            
            color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            // Pack RGBA values into UInt32
            let r = UInt32(red * 255.0)
            let g = UInt32(green * 255.0)
            let br = UInt32(blue * 255.0)
            let a = UInt32(alpha * 255.0)
            
            // RGBA8888 format
            pixels[x] = (a << 24) | (br << 16) | (g << 8) | r
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
            if let pcv = pcv {
                pcv.b = max(min(location.x / CGFloat(w) * pcv.maxValue, pcv.maxValue), pcv.minValue)
                
                print("b = \(pcv.b)")
                
                bSelectionDelegate?.onBChanged()
                
                moveIndicator()
            }
        }
    }
    
    func moveIndicator() {
        if let pcv = pcv {
            indicator.frame = CGRect(x: CGFloat(w) * (pcv.b / pcv.maxValue) - indicatorSize / 2,
                                     y: 0, width: indicatorSize, height: frame.height)
            indicator.setNeedsDisplay()
        }
    }
    
    func setPCV(pcv: PickedColorValues) {
        self.pcv = pcv
        setNeedsDisplay()
        moveIndicator()
    }
}
