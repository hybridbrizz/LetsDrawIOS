//
//  PaintPanelIcon.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 4/3/25.
//  Copyright © 2025 Eric Versteeg. All rights reserved.
//

import Foundation
import UIKit

class ColorPanelIcon {
    let name: String
    let iconViews: [UIView]
    let touchTargetView: UIView
    let outerBgView: UIView
    let isSelected: () -> Bool
    let onPress: () -> Void
    
    init(name: String, iconViews: [UIView], touchTargetView: UIView, outerBgView: UIView,
         isSelected: @escaping () -> Bool, onPress: @escaping () -> Void) {
        
        self.name = name
        self.iconViews = iconViews
        self.touchTargetView = touchTargetView
        self.outerBgView = outerBgView
        self.isSelected = isSelected
        self.onPress = onPress
        
        touchTargetView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapTouchTarget)))
        touchTargetView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(didLongPressTouchTarget)))
    }
    
    func update(color: Int32) {
        if (isSelected()) {
            let bgViews = [touchTargetView, outerBgView]
            for bgView in bgViews {
                if Utils.isColorBright(UIColor(argb: color)) {
                    bgView.layer.borderColor = UIColor.black.cgColor
                }
                else {
                    bgView.layer.borderColor = UIColor.white.cgColor
                }
                bgView.backgroundColor = UIColor.clear
                bgView.layer.borderWidth = 3
                bgView.layer.cornerRadius = bgView.frame.size.width / 2
            }
            touchTargetView.backgroundColor = UIColor(argb: Utils.int32FromColorHex(hex: "0x99ffffff"))
        }
        else {
            if Utils.isColorBright(UIColor(argb: color)) {
                touchTargetView.layer.borderColor = UIColor.black.cgColor
            }
            else {
                touchTargetView.layer.borderColor = UIColor.white.cgColor
            }
            touchTargetView.backgroundColor = UIColor.clear
            touchTargetView.layer.borderWidth = 3
            touchTargetView.layer.cornerRadius = touchTargetView.frame.size.width / 2
            
            outerBgView.backgroundColor = UIColor.clear
            outerBgView.layer.borderWidth = 0
            touchTargetView.backgroundColor = UIColor.clear
        }
        
        for iconView in iconViews {
            if iconView is UILabel {
                if Utils.isColorBright(UIColor(argb: color)) {
                    (iconView as! UILabel).textColor = UIColor.black
                }
                else {
                    (iconView as! UILabel).textColor = UIColor.white
                }
            }
            else if iconView is ButtonFrame {
                if Utils.isColorBright(UIColor(argb: color)) {
                    (iconView as! ButtonFrame).setTint(color: UIColor.black.argb())
                }
                else {
                    (iconView as! ButtonFrame).setTint(color: UIColor.white.argb())
                }
            }
        }
    }
    
    @objc func didTapTouchTarget() {
        onPress()
    }
    
    @objc func didLongPressTouchTarget() {
        self.touchTargetView.showToast(message: name)
    }
}
