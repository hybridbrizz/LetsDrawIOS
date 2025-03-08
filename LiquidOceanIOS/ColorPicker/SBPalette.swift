//
//  SBPalette.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 3/6/25.
//  Copyright © 2025 Eric Versteeg. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

protocol ColorSelectionDelegate: AnyObject {
    func onColorSelected(selectedColor: UIColor)
}

class SBPalette: UIView, HueSelectionDelegate {
    
    private var w: Int = 0
    private var h: Int = 0
    
    private var minSb: CGFloat = 0
    private var maxSb: CGFloat = 1
    
    private var s: CGFloat = 0.5
    private var b: CGFloat = 0.5
    
    private var indicatorSize: CGFloat = 20
    
    private var indicator: SBIndicator
    
    private var hue: CGFloat = 0
    private var maxHue: CGFloat = 360
    
    var colorSelectionDelegate: ColorSelectionDelegate? = nil
    
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
        drawSBSquare(hue: hue, context: ctx)
        
        moveIndicator()
    }
    
    // Converted from Kotlin by Claude
    private func drawSBSquare(hue: CGFloat, context: CGContext) {
        if w == 0 || h == 0 { return }
        
        let wf = CGFloat(w)
        let hf = CGFloat(h)
        
        var pixels = [UInt32](repeating: 0, count: w * h)
        
        for y in 0..<h {
            for x in 0..<w {
                let s = CGFloat(x) / wf
                let br = maxSb - (CGFloat(h - y) / hf)
                
                // Convert HSB to RGB directly
                let color = UIColor(hue: CGFloat(hue),
                                   saturation: CGFloat(s),
                                   brightness: CGFloat(br),
                                   alpha: 1.0)
                
                // Convert UIColor to RGBA format
                var red: CGFloat = 0
                var green: CGFloat = 0
                var blue: CGFloat = 0
                var alpha: CGFloat = 0
                
                color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                
                let r = UInt32(red * 255.0)
                let g = UInt32(green * 255.0)
                let b = UInt32(blue * 255.0)
                let a = UInt32(alpha * 255.0)
                
                // Format for RGBA8888
                pixels[y * w + x] = (a << 24) | (r << 16) | (g << 8) | b
            }
        }
        
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Little.rawValue
        bitmapInfo |= CGImageAlphaInfo.premultipliedFirst.rawValue
        
        let bitmapContext = CGContext(
            data: &pixels,
            width: w,
            height: h,
            bitsPerComponent: 8,
            bytesPerRow: w * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        )
        
        if let cgImage = bitmapContext?.makeImage() {
            // Create a UIImage for scaling
            let uiImage = UIImage(cgImage: cgImage)
            
            // Resize the image
            UIGraphicsBeginImageContextWithOptions(CGSize(width: w, height: h), false, 0.0)
            uiImage.draw(in: CGRect(x: 0, y: 0, width: w, height: h))
            if let resizedImage = UIGraphicsGetImageFromCurrentImageContext(),
               let resizedCGImage = resizedImage.cgImage {
                UIGraphicsEndImageContext()
                
                // Draw the scaled image to the provided context
                context.draw(resizedCGImage, in: CGRect(x: 0, y: 0, width: w, height: h))
            } else {
                UIGraphicsEndImageContext()
            }
        }
    }
    
    @objc func didDraw(sender: UIDrawGestureRecognizer) {
        let location = sender.location(in: self)

        if sender.state == .began || sender.state == .changed {
            s = max(min(location.x / CGFloat(w), maxSb), minSb)
            b = max(min(1 - (location.y / CGFloat(h)), maxSb), minSb)
            
            colorSelectionDelegate?.onColorSelected(selectedColor: UIColor(hue: hue,
                                                                   saturation: s,
                                                                   brightness: b,
                                                                   alpha: 1.0))
            
            print("s = \(s), b = \(b)")
            
            moveIndicator()
        }
    }
    
    private func moveIndicator() {
        indicator.frame = CGRect(x: CGFloat(w) * s - indicatorSize / 2,
                                 y: CGFloat(h) - CGFloat(h) * b - indicatorSize / 2, width: indicatorSize, height: indicatorSize)
        indicator.setNeedsDisplay()
    }
    
    func setColor(color: UIColor) {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        s = saturation
        b = brightness
        self.hue = hue
        
        setNeedsDisplay()
    }
    
    // Hue Selection
    func onHueSelected(hue: CGFloat) {
        self.hue = hue / CGFloat(maxHue)
        colorSelectionDelegate?.onColorSelected(selectedColor: UIColor(hue: self.hue,
                                                               saturation: s,
                                                               brightness: b,
                                                               alpha: 1.0))
        setNeedsDisplay()
    }
}
