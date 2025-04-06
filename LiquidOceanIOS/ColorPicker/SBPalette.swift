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

protocol SBSelectionDelegate: AnyObject {
    func onSBChanged()
}

class SBPalette: UIView {
    
    private var w: Int = 0
    private var h: Int = 0
    
    private var indicatorSize: CGFloat = 20
    
    private var indicator: SBIndicator
    
    var sbSelectionDelegate: SBSelectionDelegate? = nil
    
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
            drawSBSquare(context: ctx, pcv: pcv)
        }
        
        moveIndicator()
    }
    
    // Converted from Kotlin by Claude
    private func drawSBSquare(context: CGContext, pcv: PickedColorValues) {
        if w == 0 || h == 0 { return }
        
        let wf = CGFloat(w)
        let hf = CGFloat(h)
        
        var pixels = [UInt32](repeating: 0, count: w * h)
        
        for y in 0..<h {
            for x in 0..<w {
                let s = CGFloat(x) / wf
                let br = pcv.maxValue - (CGFloat(h - y) / hf)
                
                // Convert HSB to RGB directly
                let color = UIColor(hue: pcv.h,
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
            if let pcv = pcv {
                pcv.s = max(min(location.x / CGFloat(w), pcv.maxValue), pcv.minValue)
                pcv.b = max(min(1 - (location.y / CGFloat(h)), pcv.maxValue), pcv.minValue)
                
                print("s = \(pcv.s), b = \(pcv.b)")
                
                moveIndicator()
                
                sbSelectionDelegate?.onSBChanged()
            }
        }
    }
    
    private func moveIndicator() {
        if let pcv = pcv {
            indicator.frame = CGRect(x: CGFloat(w) * pcv.s - indicatorSize / 2,
                                     y: CGFloat(h) - CGFloat(h) * pcv.b - indicatorSize / 2, width: indicatorSize, height: indicatorSize)
            indicator.setNeedsDisplay()
        }
    }
    
    func setPCV(pcv: PickedColorValues) {
        self.pcv = pcv
        setNeedsDisplay()
        moveIndicator()
    }
}
