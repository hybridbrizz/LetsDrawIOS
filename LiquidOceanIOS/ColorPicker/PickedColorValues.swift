//
//  PickedColor.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 4/6/25.
//  Copyright © 2025 Eric Versteeg. All rights reserved.
//

import UIKit

class PickedColorValues {
    let minValue: CGFloat = 0
    let maxValue: CGFloat = 1
    
    var h: CGFloat
    var s: CGFloat
    var b: CGFloat
    
    init(h: CGFloat, s: CGFloat, b: CGFloat) {
        self.h = h
        self.s = s
        self.b = b
    }
    
    init(color: UIColor) {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        self.h = hue
        self.s = saturation
        self.b = brightness
    }
}
