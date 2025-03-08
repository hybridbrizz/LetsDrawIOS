//
//  ColorPicker2ViewController.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 3/7/25.
//  Copyright © 2025 Eric Versteeg. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

class ColorPicker2ViewController: UIViewController {
    
    @IBOutlet weak var sbPalette: SBPalette!
    @IBOutlet weak var hPalette: HPalette!
    
    var colorSelectionDelegate: ColorSelectionDelegate? = nil
    
    private var pendingStartColor: UIColor? = nil
    
    override func viewDidLoad() {
        hPalette.hueSelectionDelegate = sbPalette
        sbPalette.colorSelectionDelegate = colorSelectionDelegate
        
        if pendingStartColor != nil {
            setColor(color: pendingStartColor!)
            pendingStartColor = nil
        }
    }
    
    override func viewDidLayoutSubviews() {
        sbPalette.layer.borderWidth = 1
        sbPalette.layer.borderColor = UIColor(argb: Utils.int32FromColorHex(hex: "0xFFFAD452")).cgColor
        
        hPalette.layer.borderWidth = 1
        hPalette.layer.borderColor = UIColor(argb: Utils.int32FromColorHex(hex: "0xFFFAD452")).cgColor
    }
    
    func setColor(color: UIColor) {
        if hPalette == nil || sbPalette == nil {
            pendingStartColor = color
            return
        }
        
        hPalette.setColor(color: color)
        sbPalette.setColor(color: color)
    }
}
