//
//  ButtonFrame.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 8/7/22.
//  Copyright © 2022 Eric Versteeg. All rights reserved.
//

import UIKit

class ButtonFrame: UIView {
    
    enum ToggleState {
        case none
        case single
        case double
    }
    
    var toggleState = ToggleState.none
    
    private var _isLight = false
    var isLight: Bool {
        set {
//            _isLight = newValue
//            
//            if newValue {
//                baseColor = Utils.int32FromColorHex(hex: "0xFFFFFFFF")
//            }
//            else {
//                baseColor = Utils.int32FromColorHex(hex: "0xFF000000")
//            }
//            select(selected: false)
        }
        get {
            return _isLight
        }
    }
    
    private var baseColor = Utils.int32FromColorHex(hex: "0xFFFFFFFF")
    private var highlightColor = Utils.int32FromColorHex(hex: "0xFFFAD452")
    
    private var _highlight = false
    var highlight: Bool {
        set {
            _highlight = newValue
            
            select(selected: _highlight)
        }
        get {
            return _highlight
        }
    }
    
    private var _color: Int32? = nil
    var color: Int32? {
        set {
            _color = newValue
            select(selected: false)
        }
        get {
            return _color
        }
    }
    
    var clickHandler: (() -> Void)?

    required override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
        
        commonInit()
    }
    
    func commonInit() {
        let dgr = UIDrawGestureRecognizer(target: self, action: #selector(onTouchAction(sender:)))
        addGestureRecognizer(dgr)
        
        backgroundColor = UIColor.clear
        
        select(selected: false)
    }
    
    @objc func onTouchAction(sender: UIDrawGestureRecognizer) {
        if sender.state == .began {
            select(selected: true)
        }
        else if sender.state == .changed {
            select(selected: true)
        }
        else if sender.state == .ended {
            select(selected: false)
            clickHandler?()
        }
    }
    
    func setOnClickListener(handler: @escaping () -> Void) {
        self.clickHandler = handler
    }
    
    private func getImageView() -> UIImageView? {
        for view in subviews {
            if view is UIImageView {
                return view as? UIImageView
            }
        }
        return nil
    }
    
    private func getLabel() -> UILabel? {
        for view in subviews {
            if view is UILabel {
                return view as? UILabel
            }
        }
        return nil
    }
    
    func select(selected: Bool) {
        if color != nil {
            if selected {
                setTint(color: Utils.brightenColor(color: color!, by: 0.15))
            }
            else {
                setTint(color: color!)
            }
        }
        else {
            if selected {
                setTint(color: highlightColor)
            }
            else {
                setTint(color: baseColor)
            }
        }
    }
    
    func setTint(color: Int32) {
        let imageView = getImageView()
        let label = getLabel()
        
        if imageView != nil {
            imageView?.tintColor = UIColor(argb: color)
        }
        else if label != nil {
            label?.textColor = UIColor(argb: color)
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            print("could not get graphics context")
            return
        }
        
        context.setFillColor(UIColor.darkGray.cgColor)
        context.fillEllipse(in: CGRect(x: 0, y: 0, width: context.width, height: context.height))
    }
}
