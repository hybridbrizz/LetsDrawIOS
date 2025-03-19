//
//  PaintColorIndicator.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 2/11/21.
//  Copyright © 2021 Eric Versteeg. All rights reserved.
//

import UIKit

protocol PaintColorSelectionDelegate: AnyObject {
    func notifyPaintColorSelected(color: Int)
}

class PaintColorIndicator: UIView, ActionButtonViewTouchDelegate {
    
    weak var paintColorSelectionDelegate: PaintColorSelectionDelegate?
    
    var panelThemeConfig: PanelThemeConfig!
    
    var selectedOutline = false

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
    
    func setPaintColor(color: Int32) {
        SessionSettings.instance.paintColor = color
        setNeedsDisplay()
        
        self.paintColorSelectionDelegate?.notifyPaintColorSelected(color: 0)
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let ctx = UIGraphicsGetCurrentContext()!
        
        var fillAndStroke = false
        if SessionSettings.instance.paintIndicatorFill || SessionSettings.instance.paintIndicatorSquare {
            fillAndStroke = true
        }
        
        var indicatorStrokeWidth = ringSizeFromOption(widthVal: SessionSettings.instance.paintIndicatorWidth)
        
        let indicatorColor = SessionSettings.instance.paintColor!
        
        ctx.setStrokeColor(UIColor(argb: panelThemeConfig.paintColorIndicatorLineColor).cgColor)
        ctx.setFillColor(UIColor(argb: indicatorColor).cgColor)
        
        var radius = frame.size.width / 3
        
        let w = frame.size.width
//        if !SessionSettings.instance.paintIndicatorFill && !SessionSettings.instance.paintIndicatorSquare && w > 3 {
//            if w == 4 {
//                radius = frame.size.width * 0.38
//            }
//            else if w == 5 {
//                radius = frame.size.width * 0.43
//            }
//        }
        
        if SessionSettings.instance.paintIndicatorSquare {
            var padding = CGFloat(0)
            
            if indicatorColor == 0 {
                ctx.setLineWidth(5)
                
                padding = 2.5
            }
            
            let width = frame.size.width
            
            ctx.addRect(CGRect(x: frame.size.width / 2 - width / 2, y: frame.size.height / 2 - width / 2, width: width - padding, height: width - padding))
            
            if indicatorColor == 0 {
                ctx.drawPath(using: .stroke)
            }
            else {
                ctx.drawPath(using: .fill)
            }
        }
        else if SessionSettings.instance.paintIndicatorFill {
            var padding = CGFloat(0)
            
            if indicatorColor == 0 {
                ctx.setLineWidth(5)
                
                padding = 2.5
            }
            
            let width = circleSizeFromOption(widthVal: SessionSettings.instance.paintIndicatorWidth)
            
            ctx.addArc(center: CGPoint(x: self.frame.size.width / CGFloat(2), y: self.frame.size.height / CGFloat(2)), radius: width - padding, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
            
            if indicatorColor == 0 {
                ctx.drawPath(using: .stroke)
            }
            else {
                ctx.drawPath(using: .fill)
            }
        }
        else {
            if SessionSettings.instance.paintIndicatorOutline || indicatorColor == 0 {
                drawIndicatorOutline(ctx: ctx, radius: radius, indicatorStrokeWidth: indicatorStrokeWidth)
            }
            
            ctx.setLineWidth(indicatorStrokeWidth)
            ctx.setStrokeColor(UIColor(argb: indicatorColor).cgColor)
            ctx.setFillColor(UIColor(argb: indicatorColor).cgColor)
            
            if indicatorColor != 0 {
                ctx.addArc(center: CGPoint(x: self.frame.size.width / CGFloat(2), y: self.frame.size.height / CGFloat(2)), radius: radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
                
                ctx.drawPath(using: .stroke)
            }
        }
        
        if SessionSettings.instance.paintIndicatorOutline && (SessionSettings.instance.paintIndicatorSquare || SessionSettings.instance.paintIndicatorFill) {
            drawIndicatorOutline(ctx: ctx, radius: radius, indicatorStrokeWidth: indicatorStrokeWidth)
        }
    }
    
    func drawIndicatorOutline(ctx: CGContext, radius: CGFloat, indicatorStrokeWidth: CGFloat) {
        let borderStrokeWidth = CGFloat(1.0)
        ctx.setLineWidth(borderStrokeWidth)
        
        if panelThemeConfig.paintColorIndicatorLineColor == ActionButtonView.blackColor {
            if selectedOutline {
                ctx.setStrokeColor(UIColor(argb: ActionButtonView.twoThirdGrayColor).cgColor)
            }
            else {
                ctx.setStrokeColor(UIColor.black.cgColor)
            }
        }
        else {
            if selectedOutline {
                ctx.setStrokeColor(UIColor(argb: ActionButtonView.thirdGrayColor).cgColor)
            }
            else {
                ctx.setStrokeColor(UIColor.white.cgColor)
            }
        }
        
        ctx.addArc(center: CGPoint(x: self.frame.size.width / CGFloat(2), y: self.frame.size.height / CGFloat(2)), radius: radius - (indicatorStrokeWidth / 2  + borderStrokeWidth / 2), startAngle: 0, endAngle: 6.3, clockwise: true)
        
        if !SessionSettings.instance.paintIndicatorFill && !SessionSettings.instance.paintIndicatorSquare {
            ctx.addArc(center: CGPoint(x: self.frame.size.width / CGFloat(2), y: self.frame.size.height / CGFloat(2)), radius: radius + (indicatorStrokeWidth / 2  + borderStrokeWidth / 2), startAngle: 0, endAngle: 6.3, clockwise: true)
        }
        
        ctx.drawPath(using: .stroke)
    }
    
    func ringSizeFromOption(widthVal: Int) -> CGFloat {
        switch widthVal {
            case 1:
                return 12
            case 2:
                return 14
            case 3:
                return 16
            case 4:
                return 16
            case 5:
                return 16
            default:
                return 0
        }
    }
    
    func squareSizeFromOption(widthVal: Int) -> CGFloat {
        switch widthVal {
            case 1:
                return frame.size.width * 0.6
            case 2:
                return frame.size.width * 0.7
            case 3:
                return frame.size.width * 0.8
            case 4:
                return frame.size.width * 0.9
            case 5:
                return frame.size.width * 0.95
            default:
                return 0
        }
    }
    
    func circleSizeFromOption(widthVal: Int) -> CGFloat {
        switch widthVal {
            case 1:
                return frame.size.width * 0.3
            case 2:
                return frame.size.width * 0.35
            case 3:
                return frame.size.width * 0.4
            case 4:
                return frame.size.width * 0.45
            case 5:
                return frame.size.width * 0.49
            default:
                return 0
        }
    }
    
    // action button view touch delegate
    func notifyTouchStateChanged(state: UIGestureRecognizer.State) {
        if state == .began {
            selectedOutline = true
            setNeedsDisplay()
        }
        else if state == .ended {
            selectedOutline = false
            setNeedsDisplay()
        }
    }
    
    static func darkness(color: Int32) -> CGFloat {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        let uiColor = UIColor(argb: color)
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let darkness = 1 - (0.299 * r + 0.587 * g + 0.114 * b)
        return darkness
    }
    
    static func isColorDark(color: Int32) -> Bool {
        return darkness(color: color) > 0.85
    }
    
    static func isColorLight(color: Int32) -> Bool {
        return darkness(color: color) < 0.15
    }
}
