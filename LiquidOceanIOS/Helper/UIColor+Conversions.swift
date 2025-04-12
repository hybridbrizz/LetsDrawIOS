//
//  UIColor+Conversions.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 2/10/21.
//  Copyright © 2021 Eric Versteeg. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, a: Int = 0xFF) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: CGFloat(a) / 255.0
        )
    }

    // let's suppose alpha is the first component (ARGB)
    convenience init(argb: Int32) {
        self.init(
            red: Int((argb >> 16) & 0xFF),
            green: Int((argb >> 8) & 0xFF),
            blue: Int(argb & 0xFF),
            a: Int((argb >> 24) & 0xFF)
        )
    }
    
    convenience init(hexString: String) {
        var a: Int32 = 255
        var r: Int32 = 0
        var g: Int32 = 0
        var b: Int32 = 0
        
        var i = 0
        
        var firstVal: Int32 = 0
        var secondVal: Int32 = 0
        
        var str = String(hexString.suffix(6))
        
        for char in str.uppercased() {
            if i % 2 == 0 {
                firstVal = UIColor.numberForCharacter(char: char)
            }
            else {
                secondVal = UIColor.numberForCharacter(char: char)
            }
            
            if (i == 1) {
                r = firstVal * 16 + secondVal
            }
            else if (i == 3) {
                g = firstVal * 16 + secondVal
            }
            else if (i == 5) {
                b = firstVal * 16 + secondVal
            }
            
            i += 1
        }
        
        print("r = " + String(r))
        print("g = " + String(g))
        print("b = " + String(b))
        
        //var argb = (a << 24) | (r << 16) | (g << 8) | b
        
        self.init(
            red: Int(r),
            green: Int(g),
            blue: Int(b),
            a: Int(a)
        )
    }
    
    func argb() -> Int32 {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = Int32(fRed * 255.0)
            let iGreen = Int32(fGreen * 255.0)
            let iBlue = Int32(fBlue * 255.0)
            let iAlpha = Int32(fAlpha * 255.0)
            
            let rgb = (iRed << 16) | (iGreen << 8) | (iBlue) | (iAlpha << 24)
            return rgb
        } else {
            // Could not extract RGBA components:
            return 0
        }
    }
    
    func hexString() -> String {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let r = Int32(fRed * 255.0)
            let g = Int32(fGreen * 255.0)
            let b = Int32(fBlue * 255.0)
            let a = Int32(fAlpha * 255.0)
            
            return "#" + chHexString(value: r) + chHexString(value: g) + chHexString(value: b)
        } else {
            // Could not extract RGBA components:
            return ""
        }
    }
    
    // value between 0 - 255
    private func chHexString(value: Int32) -> String {
        let tensPlace = value / 16
        let onesPlace = value % 16
        
        return characterForNumber(number: tensPlace) + characterForNumber(number: onesPlace)
    }
    
    private func characterForNumber(number: Int32) -> String {
        if number > 9 {
            if number == 10 {
                return "A"
            }
            else if number == 11 {
                return "B"
            }
            else if number == 12 {
                return "C"
            }
            else if number == 13 {
                return "D"
            }
            else if number == 14 {
                return "E"
            }
            else if number == 15 {
                return "F"
            }
        }
        else {
            return String(number)
        }
        
        return ""
    }
    
    private static func numberForCharacter(char: Character) -> Int32 {
        if char == "A" {
            return 10
        }
        else if char == "B" {
            return 11
        }
        else if char == "C" {
            return 12
        }
        else if char == "D" {
            return 13
        }
        else if char == "E" {
            return 14
        }
        else if char == "F" {
            return 15
        }
        
        return Int32(String(char))!
    }
}
