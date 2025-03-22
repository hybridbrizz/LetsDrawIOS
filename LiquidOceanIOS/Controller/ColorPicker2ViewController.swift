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

protocol ColorPicker2LayoutDelegate: AnyObject {
    func onColorPicker2LayoutSubviews()
}

class ColorPicker2ViewController: UIViewController {
    
    @IBOutlet weak var sbPalette: SBPalette!
    @IBOutlet weak var hPalette: HPalette!
    
    @IBOutlet weak var colorHexTextField: UITextField!
    
    var colorSelectionDelegate: ColorSelectionDelegate? = nil
    var layoutDelegate: ColorPicker2LayoutDelegate? = nil
    
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
//        sbPalette.layer.borderWidth = 1
//        sbPalette.layer.borderColor = UIColor(argb: Utils.int32FromColorHex(hex: "0x99ffffff")).cgColor
//        
//        hPalette.layer.borderWidth = 1
//        hPalette.layer.borderColor = UIColor(argb: Utils.int32FromColorHex(hex: "0x99ffffff")).cgColor
        
        layoutDelegate?.onColorPicker2LayoutSubviews()
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
