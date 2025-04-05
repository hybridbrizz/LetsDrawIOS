//
//  PaintQuantityBar.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 4/5/25.
//  Copyright © 2025 Eric Versteeg. All rights reserved.
//

import UIKit

class LoadingBar: UIView {

    private var _progress = 0.0
    var progress: Double {
        set {
            _progress = newValue
            animateProgress(progress: newValue)
        }
        get {
            return _progress
        }
    }
    
    var barView = UIView()
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
        
        commonInit()
    }
    
    func commonInit() {
        barView.frame = CGRect(x: 0, y: 0, width: 0, height: frame.size.height)
        barView.backgroundColor = UIColor(argb: Utils.int32FromColorHex(hex: "0xFFFAD452"))
        self.addSubview(barView)
    }
    
    func animateProgress(progress: Double) {
        UIView.animate(withDuration: 0.2) {
            self.barView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width * progress, height: self.frame.size.height)
        }
    }
}
