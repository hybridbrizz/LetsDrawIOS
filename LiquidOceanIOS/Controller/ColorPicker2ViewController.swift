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

protocol ColorSelectionDelegate: AnyObject {
    func onColorSelected(selectedColor: UIColor)
    func onColorSelectionCancel()
}

class ColorPicker2ViewController: UIViewController, RGBSelectionDelegate, HueSelectionDelegate,
                                    SatSelectionDelegate, BSelectionDelegate, UITextFieldDelegate {
    
//    @IBOutlet weak var sbPalette: SBPalette!
    @IBOutlet weak var rgbColorWheel: RGBColorWheel!
    @IBOutlet weak var hPalette: HPalette!
    @IBOutlet weak var sPalette: SPalette!
    @IBOutlet weak var bPalatte: BPalette!
    
    @IBOutlet weak var colorHexTextField: UITextField!
    @IBOutlet weak var hueValueTextField: UITextField!
    @IBOutlet weak var saturationValueTextField: UITextField!
    @IBOutlet weak var brightnessValueTextField: UITextField!
    
    @IBOutlet weak var oldColorIndicatorView: UIView!
    @IBOutlet weak var colorIndicatorView: UIView!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var selectButton: UIButton!
    
    @IBOutlet var keyboardLiftViewHeight: NSLayoutConstraint!
    
    var colorSelectionDelegate: ColorSelectionDelegate? = nil
    var layoutDelegate: ColorPicker2LayoutDelegate? = nil
    
    private var pendingStartPCV: PickedColorValues? = nil
    private var pcv: PickedColorValues? = nil
    
    var keyboardHeight = CGFloat(0)
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
//        sbPalette.sbSelectionDelegate = self
        rgbColorWheel.rgbSelectionDelegate = self
        hPalette.hueSelectionDelegate = self
        sPalette.satSelectionDelegate = self
        bPalatte.bSelectionDelegate = self
        
        if pendingStartPCV != nil {
            setPCV(pcv: pendingStartPCV!)
            
            pendingStartPCV = nil
        }
    }
    
    override func viewDidLayoutSubviews() {
//        sbPalette.layer.borderWidth = 1
//        sbPalette.layer.borderColor = UIColor(argb: Utils.int32FromColorHex(hex: "0x99ffffff")).cgColor
//        
//        hPalette.layer.borderWidth = 1
//        hPalette.layer.borderColor = UIColor(argb: Utils.int32FromColorHex(hex: "0x99ffffff")).cgColor
        
        hPalette.layer.cornerRadius = 5
        sPalette.layer.cornerRadius = 5
        bPalatte.layer.cornerRadius = 5
        
        colorHexTextField.addTarget(self, action: #selector(hexTextFieldDidChange), for: .editingChanged)
        hueValueTextField.addTarget(self, action: #selector(hueTextFieldDidChange), for: .editingChanged)
        saturationValueTextField.addTarget(self, action: #selector(saturationTextFieldDidChange), for: .editingChanged)
        brightnessValueTextField.addTarget(self, action: #selector(brightnessTextFieldDidChange), for: .editingChanged)
    }
    
    func setColor(color: UIColor) {
        setPCV(pcv: PickedColorValues(color: color))
    }
    
    func clearColor() {
        pcv = nil
    }
    
    func setPCV(pcv: PickedColorValues) {
        if hPalette == nil || sPalette == nil {
            pendingStartPCV = pcv
            return
        }
        
        if self.pcv == nil {
            self.oldColorIndicatorView.backgroundColor = getUIColor(pcv: pcv)
        }
        
        self.pcv = pcv
        
//        sbPalette.setPCV(pcv: pcv)
        rgbColorWheel.setPCV(pcv: pcv)
        hPalette.setPCV(pcv: pcv)
        sPalette.setPCV(pcv: pcv)
        bPalatte.setPCV(pcv: pcv)
        
        syncViews()
    }
    
    func getUIColor(pcv: PickedColorValues) -> UIColor {
        return UIColor(hue: pcv.h, saturation: pcv.s, brightness: pcv.b, alpha: 1.0)
    }
    
    func syncViews() {
//        sbPalette.setNeedsDisplay()
        rgbColorWheel.setNeedsDisplay()
        hPalette.setNeedsDisplay()
        sPalette.setNeedsDisplay()
        bPalatte.setNeedsDisplay()
        
        syncNonSpectrumViews()
    }
    
    func syncNonSpectrumViews() {
        if let pcv = pcv {
            let uiColor = getUIColor(pcv: pcv)
            
            colorIndicatorView.backgroundColor = uiColor
            
            // value textfields
            colorHexTextField.text = uiColor.hexString()
            
            let absHue = Int(round(pcv.h * 360))
            hueValueTextField.text = "\(absHue)"
            
            let absSat = Int(round(pcv.s * 100))
            saturationValueTextField.text = "\(absSat)"
            
            let absB = Int(round(pcv.b * 100))
            brightnessValueTextField.text = "\(absB)"
        }
    }
    
//    // SB Selection Delegate
//    func onSBChanged() {
//        syncViews()
//    }
    
    // RGB Selection Delegate
    func onRGBChanged() {
        hPalette.moveIndicator()
        sPalette.setNeedsDisplay()
        syncNonSpectrumViews()
    }
    
    // H Selection Delegate
    func onHueChanged() {
        rgbColorWheel.moveIndicator()
        sPalette.setNeedsDisplay()
        bPalatte.setNeedsDisplay()
        syncNonSpectrumViews()
    }
    
    // Sat Selection Delegate
    func onSatChanged() {
        rgbColorWheel.moveIndicator()
        syncNonSpectrumViews()
    }
    
    // B Selection Delegate
    func onBChanged() {
        rgbColorWheel.setNeedsDisplay()
        syncNonSpectrumViews()
    }
    
    @objc func hexTextFieldDidChange() {
        let textField = colorHexTextField!
        let range = NSRange(location: 0, length: textField.text!.count)
        let regex = try! NSRegularExpression(pattern: "[A-F0-9]{6}")
        
        let result = regex.firstMatch(in: textField.text!, options: [], range: range)
    
        if result != nil && textField.text!.count == 6 {
            setColor(color: UIColor(hexString: textField.text!))
            textField.resignFirstResponder()
        }
    }
    
    @objc func hueTextFieldDidChange() {
        let textField = hueValueTextField!
        let range = NSRange(location: 0, length: textField.text!.count)
        let regex = try! NSRegularExpression(pattern: "[0-9]{1,3}")
        
        let result = regex.firstMatch(in: textField.text!, options: [], range: range)
    
        if result != nil {
            let value = Int(textField.text!)!
            if value >= 0 && value <= 360 {
                pcv?.h = CGFloat(value) / 360.0
                onHueChanged()
            }
        }
    }
    
    @objc func saturationTextFieldDidChange() {
        let textField = saturationValueTextField!
        let range = NSRange(location: 0, length: textField.text!.count)
        let regex = try! NSRegularExpression(pattern: "[0-9]{1,3}")
        
        let result = regex.firstMatch(in: textField.text!, options: [], range: range)
    
        if result != nil {
            let value = Int(textField.text!)!
            if value >= 0 && value <= 100 {
                pcv?.s = CGFloat(value) / 100.0
                onSatChanged()
            }
        }
    }
    
    @objc func brightnessTextFieldDidChange() {
        let textField = brightnessValueTextField!
        let range = NSRange(location: 0, length: textField.text!.count)
        let regex = try! NSRegularExpression(pattern: "[0-9]{1,3}")
        
        let result = regex.firstMatch(in: textField.text!, options: [], range: range)
    
        if result != nil {
            let value = Int(textField.text!)!
            if value >= 0 && value <= 100 {
                pcv?.b = CGFloat(value) / 100.0
                onBChanged()
            }
        }
    }
    
    // UITextField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
            keyboardLiftViewHeight.constant = keyboardHeight
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        keyboardLiftViewHeight.constant = 0
        syncViews()
    }
    
    @IBAction func onCancelPressed(_ sender: Any) {
        colorSelectionDelegate?.onColorSelectionCancel()
    }
    
    @IBAction func onSelectPressed(_ sender: Any) {
        if let pcv = pcv {
            colorSelectionDelegate?.onColorSelected(selectedColor: getUIColor(pcv: pcv))
        }
    }
}
