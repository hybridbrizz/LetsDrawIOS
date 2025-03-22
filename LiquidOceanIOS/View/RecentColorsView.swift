//
//  RecentColorsView.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 3/20/25.
//  Copyright © 2025 Eric Versteeg. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

class RecentColorsView: UIView {
    
    private let rows = 2
    private let cols = 8
    
    
    var _delegate: RecentColorsDelegate? = nil
    var delegate: RecentColorsDelegate? {
        set {
            _delegate = newValue
        }
        get {
            return _delegate
        }
    }
    
    var _recentColors = [Int32]()
    var recentColors: [Int32] {
        set {
            _recentColors = newValue
            
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
            return _recentColors
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
                ctx.setFillColor(UIColor(argb: recentColors[index]).cgColor)
                
                let x = CGFloat(cols - 1 - j) * itemSize
                let y = CGFloat(i) * itemSize
                
                ctx.addRect(CGRect(x: x, y: y, width: itemSize, height: itemSize))
                
                ctx.drawPath(using: .fill)
            }
        }
    }
    
    @objc func didDraw(sender: UIDrawGestureRecognizer) {
        let location = sender.location(in: self)
        let itemSize = self.frame.size.width / CGFloat(cols)
        
        if sender.state == .began || sender.state == .changed {
            let x = cols - 1 - Int(floor(location.x / itemSize))
            let y = Int(floor(location.y / itemSize))
            
            let index = y * cols + x
            
            let color = recentColors[index]
            SessionSettings.instance.paintColor = color
            self.delegate?.notifyRecentColorSelected(color: color)
        }
    }
}
