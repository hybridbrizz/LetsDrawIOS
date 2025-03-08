//
//  HIndicator.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 3/7/25.
//  Copyright © 2025 Eric Versteeg. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

class HIndicator: UIView {
    
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
        
        ctx.setFillColor(UIColor(argb: Utils.int32FromColorHex(hex: "0xffffffff")).cgColor)
        ctx.addRect(CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        ctx.drawPath(using: .fill)
    }
}
