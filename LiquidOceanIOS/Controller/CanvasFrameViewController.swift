//
//  CanvasFrameViewController.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 10/31/21.
//  Copyright © 2021 Eric Versteeg. All rights reserved.
//

import UIKit

protocol CanvasFrameViewControllerDelegate: AnyObject {
    func createCanvasFrame(centerX: Int, centerY: Int, width: Int, height: Int)
}

class CanvasFrameViewController: UIViewController, UITextFieldDelegate {

    weak var delegate: CanvasFrameViewControllerDelegate?
    
    var x: Int!
    var y: Int!
    
    var panelThemeConfig: PanelThemeConfig!
    
    weak var canvasFrameViewTop: NSLayoutConstraint!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var widthLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    
    @IBOutlet weak var widthTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    
    var backgroundSet = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if panelThemeConfig.actionButtonColor == UIColor.black.argb() {
            titleLabel.textColor = UIColor(argb: Utils.int32FromColorHex(hex: "0xFF111111"))
            titleLabel.shadowColor = UIColor(argb: Utils.int32FromColorHex(hex: "0x7F333333"))
            
            widthLabel.textColor = UIColor.black
            widthTextField.textColor = UIColor.black
            
            heightLabel.textColor = UIColor.black
            heightTextField.textColor = UIColor.black
        }

        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(sender:)))
        lpgr.minimumPressDuration = 0
        lpgr.cancelsTouchesInView = false
        //view.addGestureRecognizer(lpgr)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.OrientationUtility.lockOrientation(UIInterfaceOrientationMask.landscape)
    }
    
    override func viewDidLayoutSubviews() {
        setBackground()
    }
    
    func updatePanelThemeConfig(panelThemeConfig: PanelThemeConfig) {
        self.panelThemeConfig = panelThemeConfig
        
        if panelThemeConfig.actionButtonColor == UIColor.black.argb() {
            titleLabel.textColor = UIColor(argb: Utils.int32FromColorHex(hex: "0xFF111111"))
            titleLabel.shadowColor = UIColor(argb: Utils.int32FromColorHex(hex: "0x7F333333"))
            
            widthLabel.textColor = UIColor.black
            heightLabel.textColor = UIColor.black
        }
        else {
            titleLabel.textColor = UIColor(argb: Utils.int32FromColorHex(hex: "0xDDFFFFFF"))
            titleLabel.shadowColor = UIColor(argb: Utils.int32FromColorHex(hex: "0x7F000000"))
            
            widthLabel.textColor = UIColor.white
            heightLabel.textColor = UIColor.white
        }
        
        setBackground()
    }
    
    @objc func didLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            widthTextField.resignFirstResponder()
            heightTextField.resignFirstResponder()
        }
    }
    
    @IBAction func createButtonPressed(_ sender: Any) {
        if isInputValid(text: widthTextField.text!) && isInputValid(text: heightTextField.text!) {
            let width = Int(widthTextField.text!)!
            let height = Int(heightTextField.text!)!
            
            if width > 0 && width < 1000 && height > 0 && height < 1000 {
                delegate?.createCanvasFrame(centerX: x, centerY: y, width: width, height: height)
            }
        }
    }
    
    func isInputValid(text: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: "^\\d{1,3}$", options: [])
        let result = regex.firstMatch(in: text, options: [], range: NSRange(location: 0, length: text.count))
        
        return result != nil
    }
    
    func closeKeyboard() {
        widthTextField.resignFirstResponder()
        heightTextField.resignFirstResponder()
    }
    
    func setBackground() {
        let backgroundImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        
        var textureImage: UIImage!
        if SessionSettings.instance.panelBackgroundName == "" {
            textureImage = UIImage(named: "wood_texture_light.jpg")
        }
        else {
            textureImage = UIImage(named: SessionSettings.instance.panelBackgroundName)
        }
        
        let scale = view.frame.size.width / textureImage.size.width
        textureImage = Utils.scaleImage(image: textureImage, scaleFactor: scale)
        
        textureImage = Utils.clipImageToRect(image: textureImage, rect: CGRect(x: 0, y: textureImage.size.height - view.frame.size.height, width: view.frame.size.width, height: view.frame.size.height))
        
        backgroundImageView.contentMode = .topLeft
        backgroundImageView.image = textureImage
        
        if backgroundSet {
            view.subviews[0].removeFromSuperview()
        }
        
        view.insertSubview(backgroundImageView, at: 0)
        
        backgroundSet = true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if canvasFrameViewTop.constant > 50 {
            canvasFrameViewTop.constant = 20
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == widthTextField {
            heightTextField.becomeFirstResponder()
        }
        else if textField == heightTextField {
            heightTextField.resignFirstResponder()
        }
        
        return true
    }
}
