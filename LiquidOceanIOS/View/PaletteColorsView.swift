//
//  PaletteColorsView.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 3/20/25.
//  Copyright © 2025 Eric Versteeg. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

protocol PaletteColorsLoadDelegate: AnyObject {
    func onRequestLoadInto(index: Int)
}

class PaletteColorsView: UIView, PaletteColorsChangedDelegate {
    
    enum PaletteMode {
        case load
        case select
    }
    
    var rows = 2
    var cols = 8
    
    var _delegate: PaletteColorsDelegate? = nil
    var delegate: PaletteColorsDelegate? {
        set {
            _delegate = newValue
        }
        get {
            return _delegate
        }
    }
    
    var loadDelegate: PaletteColorsLoadDelegate? = nil
    
    var _mode: PaletteMode = .select
    var mode: PaletteMode {
        set {
            _mode = newValue
            setNeedsDisplay()
        }
        get {
            return _mode
        }
    }
    
    var isTablet = false
    
    var _paletteColors = [Int32]()
    var paletteColors: [Int32] {
        set {
            _paletteColors = newValue
            
            if isTablet {
                rows = 1
                cols = 16
            }
            
            // Thanks Claude
            let transition = CATransition()
            transition.duration = 0.3
            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            transition.type = .fade // Or other transitions like .moveIn, .push, .reveal

            // Add the transition to the view's layer
            self.layer.add(transition, forKey: nil)

            // Then trigger the redraw
            self.setNeedsDisplay()
        }
        get {
            return _paletteColors
        }
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
        
        commonInit()
    }
    
    func commonInit() {
        if !SessionSettings.instance.paletteColors.isEmpty {
            paletteColors = SessionSettings.instance.paletteColors
        }
        SessionSettings.instance.paletteColorsChangedDelegates.append(self)
        
        let dgr = UIDrawGestureRecognizer(target: self, action: #selector(didDraw(sender:)))
        dgr.delaysTouchesBegan = false
        addGestureRecognizer(dgr)
    }
    
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()!
        
        let itemSize = self.frame.size.width / CGFloat(cols)
        
        ctx.setShouldAntialias(false)
        
        for i in 0..<rows {
            for j in 0..<cols {
                let index = i * cols + j
                ctx.setFillColor(UIColor(argb: paletteColors[index]).cgColor)
                
                let x = CGFloat(cols - 1 - j) * itemSize
                let y = CGFloat(i) * itemSize
                
                ctx.addRect(CGRect(x: x, y: y, width: itemSize, height: itemSize))
                
                ctx.drawPath(using: .fill)
            }
        }
        
        if mode == .load {
            ctx.setStrokeColor(UIColor.white.cgColor)
            ctx.setLineWidth(2)
            
            for i in 0..<rows {
                for j in 0..<cols {
                    let x = CGFloat(cols - 1 - j) * itemSize
                    let y = CGFloat(i) * itemSize
                    
                    ctx.move(to: CGPoint(x: x, y: y))
                    ctx.addLine(to: CGPoint(x: x + itemSize, y: y))
                    
                    ctx.move(to: CGPoint(x: x, y: y))
                    ctx.addLine(to: CGPoint(x: x, y: y + itemSize))
                    
                    if j == cols - 1 {
                        ctx.move(to: CGPoint(x: x + itemSize, y: y))
                        ctx.addLine(to: CGPoint(x: x + itemSize, y: y + itemSize))
                    }
                    
                    if i == rows - 1 {
                        ctx.move(to: CGPoint(x: x, y: y + itemSize))
                        ctx.addLine(to: CGPoint(x: x + itemSize, y: y + itemSize))
                    }
                }
            }
            
            ctx.drawPath(using: .stroke)
        }
    }
    
    private var touchDownIndex: Int? = nil
    
    @objc func didDraw(sender: UITapGestureRecognizer) {
        let location = sender.location(in: self)
        let itemSize = self.frame.size.width / CGFloat(cols)
        
        let x = cols - 1 - Int(floor(location.x / itemSize))
        let y = Int(floor(location.y / itemSize))
        
        let index = y * cols + x
        
        if sender.state == .began {
            touchDownIndex = index
        }
        else if sender.state == .ended {
            if index == touchDownIndex {
                if mode == .select {
                    if paletteColors.indices.contains(index) {
                        let color = paletteColors[index]
                        SessionSettings.instance.paintColor = color
                        self.delegate?.notifyPaletteColorSelected(color: color)
                    }
                }
                else if mode == .load {
                    loadDelegate?.onRequestLoadInto(index: index)
                }
            }
        }
    }
    
    // Palette Colors Changed Delegate
    func onPaletteColorsChanged(paletteColors: [Int32]) {
        self.paletteColors = paletteColors
    }
}
