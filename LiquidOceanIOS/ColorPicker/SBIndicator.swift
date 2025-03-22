//
//  SBIndicator.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 3/7/25.
//  Copyright © 2025 Eric Versteeg. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

class SBIndicator: UIView {
    
    private var w: Int = 0
    private var h: Int = 0
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
        
        commonInit()
    }
    
    func commonInit() {
        
    }
    
    override func layoutSubviews() {
        w = Int(frame.width)
        h = Int(frame.height)
        
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let ctx = UIGraphicsGetCurrentContext()!
        
//        ctx.setFillColor(UIColor.white.cgColor)
//        ctx.addRect(CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
//        ctx.drawPath(using: .fill)
        
        ctx.setStrokeColor(UIColor(argb: Utils.int32FromColorHex(hex: "0xccffffff")).cgColor)
        ctx.setLineWidth(2)
        
        ctx.addEllipse(in: CGRect(x: 2.5, y: 2.5, width: frame.width - 5, height: frame.height - 5))
        ctx.drawPath(using: .stroke)
    }
}
