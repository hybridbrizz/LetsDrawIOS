//
//  Utils.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 2/10/21.
//  Copyright © 2021 Eric Versteeg. All rights reserved.
//

import UIKit
import Alamofire

class Utils: NSObject {
    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat((rgbValue & 0xFF0000) >> 8) / 255.0
        )
    }
    
    static func int32FromColorHex(hex: String) -> Int32 {
        return Int32(bitPattern: UInt32(hex.dropFirst(2), radix: 16) ?? 0)
    }
    
    static func UIColorFromColorHex(hex: String) -> UIColor {
        return UIColor(argb: int32FromColorHex(hex: hex))
    }
    
    static func brightenColor(color: Int32, by: Float) -> Int32 {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        let uiColor = UIColor(argb: color)
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        r = CGFloat(fminf(1.0, Float(r) + Float(r) * by))
        g = CGFloat(fminf(1.0, Float(g) + Float(g) * by))
        b = CGFloat(fminf(1.0, Float(b) + Float(b) * by))
        
        return UIColor(red: r, green: g, blue: b, alpha: a).argb()
    }
    
    static func isNetworkAvailable() -> Bool {
        let reachability = NetworkReachabilityManager()!
        return reachability.isReachable
    }
    
    static func scaleImage(image: UIImage, scaleFactor: CGFloat) -> UIImage {
        let imageFrame = CGRect(x: 0, y: 0, width: image.size.width * scaleFactor, height: image.size.height * scaleFactor)
        
        UIGraphicsBeginImageContextWithOptions(imageFrame.size, false, 1.0)
        image.draw(in: imageFrame)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    static func clipImageToRect(image: UIImage, rect: CGRect) -> UIImage {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        imageView.image = image
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 1.0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.translateBy(x: -rect.origin.x, y: -rect.origin.y)
        imageView.layer.render(in: ctx)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    static func isColorBright(_ color: UIColor) -> Bool {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Formula for calculating relative luminance/brightness
        // 0.299 * R + 0.587 * G + 0.114 * B
        let brightness = (0.299 * red + 0.587 * green + 0.114 * blue)
        
        return brightness > 0.7
    }
}
