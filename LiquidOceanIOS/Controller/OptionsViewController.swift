//
//  OptionsViewController.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 2/23/21.
//  Copyright © 2021 Eric Versteeg. All rights reserved.
//

import UIKit
import FlexColorPicker

class OptionsViewController: UIViewController, UITextFieldDelegate, ColorPickerDelegate {
    
    @IBOutlet weak var colorPickerContainerView: UIView!
    @IBOutlet weak var colorPickerDoneButton: UIButton!
    @IBOutlet weak var colorPickerCancelButton: UIButton!
    
    @IBOutlet weak var optionsTitleLabel: UILabel!
    
    @IBOutlet weak var backButton: ButtonFrame!
    
    @IBOutlet weak var changeNameLabel: UILabel!
    @IBOutlet weak var changeNameButton: UIButton!
    @IBOutlet weak var changeNameTextField: UITextField!
    
    @IBOutlet weak var gridLineColorContainer: UIView!
    @IBOutlet weak var gridLineColorColorView: UIView!
    @IBOutlet weak var gridLineColorResetButton: UIButton!
    
    @IBOutlet weak var canvasBackgroundPrimaryColorContainer: UIView!
    @IBOutlet weak var canvasBackgroundPrimaryColorColorView: UIView!
    @IBOutlet weak var canvasBackgroundPrimaryColorResetButton: UIButton!
    
    @IBOutlet weak var canvasBackgroundSecondaryColorContainer: UIView!
    @IBOutlet weak var canvasBackgroundSecondaryColorColorView: UIView!
    @IBOutlet weak var canvasBackgroundSecondaryColorResetButton: UIButton!

    @IBOutlet weak var creditsScrollView: UIScrollView!
    
    @IBOutlet weak var backActionLeading: NSLayoutConstraint!
    
    weak var colorPickerViewController: CustomColorPickerViewController!
    
    var showSignIn = "ShowSignIn"
    var showPincode = "ShowPincode"
    var showCanvasImport = "ShowCanvasImport"
    var showCanvasExport = "ShowCanvasExport"
    let unwindToCanvas = "UnwindToCanvas"
    
    var images = [UIImage]()
    
    var alertTextField: UITextField!
    
    var checkedName: String!
    
    var panels = PanelThemeConfig.panels
    
    var selectingPaintMeterColor = false
    var selectingGridLineColor = false
    var selectingCanvasLockColor = false
    var selectingCanvasPrimaryColor = false
    var selectingCanvasSecondaryColor = false
    var selectingFrameColor = false
    var selectingCloseDrawPanelColor = false
    
    var fromCanvas = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if SessionSettings.instance.onceResetColorSettings {
            SessionSettings.instance.paintIndicatorColor = Utils.int32FromColorHex(hex: "0xffffffff")
            SessionSettings.instance.gridLineColor = Utils.int32FromColorHex(hex: "0xffffffff")
            gridLineColorColorView.backgroundColor = UIColor.white
            SessionSettings.instance.canvasBackgroundPrimaryColor = Utils.int32FromColorHex(hex: "0xffffffff")
            canvasBackgroundPrimaryColorColorView.backgroundColor = UIColor(argb: Utils.int32FromColorHex(hex: "0xffffffff"))
            SessionSettings.instance.canvasBackgroundSecondaryColor = Utils.int32FromColorHex(hex: "0xffffffff")
            canvasBackgroundSecondaryColorColorView.backgroundColor = UIColor(argb: Utils.int32FromColorHex(hex: "0xffffffff"))
            SessionSettings.instance.canvasLockColor = Utils.int32FromColorHex(hex: "0x66ff0000")
            SessionSettings.instance.frameColor = Utils.int32FromColorHex(hex: "0xff999999")
            SessionSettings.instance.paintPanelCloseButtonColor = Utils.int32FromColorHex(hex: "0xffffffff")
            
            SessionSettings.instance.onceResetColorSettings = false
            SessionSettings.instance.save()
        }
        
        setGradientBackground()
        
        backButton.setOnClickListener {
            if (!self.creditsScrollView.isHidden) {
                self.creditsScrollView.isHidden = true
            }
            else {
                if SessionSettings.instance.reloadCanvas && !SessionSettings.instance.replaceCanvas {
                    SessionSettings.instance.saveCanvas = true
                }
                SessionSettings.instance.replaceCanvas = false
                
                if self.fromCanvas {
                    self.performSegue(withIdentifier: self.unwindToCanvas, sender: nil)
                }
                else {
                    self.presentingViewController?.dismiss(animated: false, completion: nil)
                }
            }
        }
        
        for panel in panels {
            images.append(UIImage(named: panel)!)
        }
        
        checkedName = SessionSettings.instance.displayName
        changeNameTextField.text = SessionSettings.instance.displayName
        
        // grid line color
        gridLineColorContainer.layer.borderColor = UIColor(argb: Utils.int32FromColorHex(hex: "0x99FFFFFF")).cgColor
        gridLineColorContainer.layer.borderWidth = 0
        
        var tgr = UITapGestureRecognizer(target: self, action: #selector(tappedGridLineColorView(sender:)))
        gridLineColorColorView.addGestureRecognizer(tgr)
        
        if SessionSettings.instance.gridLineColor != Utils.int32FromColorHex(hex: "0xffffffff") {
            gridLineColorColorView.backgroundColor = UIColor(argb: SessionSettings.instance.gridLineColor)
        }
        
        // canvas background primary color
        canvasBackgroundPrimaryColorContainer.layer.borderColor = UIColor(argb: Utils.int32FromColorHex(hex: "0x99FFFFFF")).cgColor
        canvasBackgroundPrimaryColorContainer.layer.borderWidth = 0
        
        tgr = UITapGestureRecognizer(target: self, action: #selector(tappedCanvasBackgroundPrimaryColorView(sender:)))
        canvasBackgroundPrimaryColorColorView.addGestureRecognizer(tgr)
        
        if SessionSettings.instance.canvasBackgroundPrimaryColor != Utils.int32FromColorHex(hex: "0xffffffff") {
            canvasBackgroundPrimaryColorColorView.backgroundColor = UIColor(argb: SessionSettings.instance.canvasBackgroundPrimaryColor)
        }
        
        // canvas background secondary color
        canvasBackgroundSecondaryColorContainer.layer.borderColor = UIColor(argb: Utils.int32FromColorHex(hex: "0x99FFFFFF")).cgColor
        canvasBackgroundSecondaryColorContainer.layer.borderWidth = 0
        
        tgr = UITapGestureRecognizer(target: self, action: #selector(tappedCanvasBackgroundSecondaryColorView(sender:)))
        canvasBackgroundSecondaryColorColorView.addGestureRecognizer(tgr)
        
        if SessionSettings.instance.canvasBackgroundSecondaryColor != Utils.int32FromColorHex(hex: "0xffffffff") {
            canvasBackgroundSecondaryColorColorView.backgroundColor = UIColor(argb: SessionSettings.instance.canvasBackgroundSecondaryColor)
        }
        
        if SessionSettings.instance.lastVisitedServer?.uuid == "" {
            changeNameLabel.isHidden = true
            changeNameTextField.isHidden = true
            changeNameButton.isHidden = true
        }
        
        // before animation
        if view.frame.size.height <= 600 {
            optionsTitleLabel.isHidden = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        let backX = self.backButton.frame.origin.x
        if backX < 0 {
            backActionLeading.constant += 30
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if view.frame.size.height <= 600 {
            //Animator.animateTitleFromTop(titleView: optionsTitleLabel)
            Animator.animateTitleFromTop(titleView: backButton)
            
            Animator.animateHorizontalViewEnter(view: gridLineColorContainer, left: true)
            Animator.animateHorizontalViewEnter(view: canvasBackgroundPrimaryColorContainer, left: true)
            Animator.animateHorizontalViewEnter(view: canvasBackgroundSecondaryColorContainer, left: true)
        }
        
        AppDelegate.OrientationUtility.lockOrientation(UIInterfaceOrientationMask.landscape)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        if SessionSettings.instance.changedGoogleAuth {
//            URLSessionHandler.instance.getDeviceInfo { (success) -> (Void) in
//                if success {
//                    self.changeNameTextField.text = SessionSettings.instance.displayName
//                }
//            }
//        }
    }
    
    @IBAction func resetButtonPressed(_ sender: UIButton) {
        if sender == gridLineColorResetButton {
            SessionSettings.instance.gridLineColor = Utils.int32FromColorHex(hex: "0xffffffff")
            gridLineColorColorView.backgroundColor = UIColor.white
        }
        else if sender == canvasBackgroundPrimaryColorResetButton {
            SessionSettings.instance.canvasBackgroundPrimaryColor = Utils.int32FromColorHex(hex: "0xffffffff")
            canvasBackgroundPrimaryColorColorView.backgroundColor = UIColor(argb: Utils.int32FromColorHex(hex: "0xffffffff"))
        }
        else if sender == canvasBackgroundSecondaryColorResetButton {
            SessionSettings.instance.canvasBackgroundSecondaryColor = Utils.int32FromColorHex(hex: "0xffffffff")
            canvasBackgroundSecondaryColorColorView.backgroundColor = UIColor(argb: Utils.int32FromColorHex(hex: "0xffffffff"))
        }
    }
    
    @objc func tappedTextureTitle() {
        creditsScrollView.isHidden = false
    }
    
    @objc func tappedPaintMeterColorView(sender: UIView) {
        colorPickerViewController.selectedColor = UIColor(argb: SessionSettings.instance.paintIndicatorColor)
        
        colorPickerContainerView.isHidden = false
        colorPickerContainerView.alpha = 0
        
        colorPickerCancelButton.isHidden = false
        colorPickerCancelButton.alpha = 0
        
        colorPickerDoneButton.isHidden = false
        colorPickerDoneButton.alpha = 0
        
        UIView.animate(withDuration: 0.2) {
            self.colorPickerContainerView.alpha = 1
            self.colorPickerCancelButton.alpha = 1
            self.colorPickerDoneButton.alpha = 1
        }
        
        selectingPaintMeterColor = true
    }
    
    @objc func tappedGridLineColorView(sender: UIView) {
        if SessionSettings.instance.gridLineColor == Utils.int32FromColorHex(hex: "0xffffffff") {
            colorPickerViewController.selectedColor = UIColor.white
        }
        else {
            colorPickerViewController.selectedColor = UIColor(argb: SessionSettings.instance.gridLineColor)
        }
        
        colorPickerContainerView.isHidden = false
        colorPickerContainerView.alpha = 0
        
        colorPickerCancelButton.isHidden = false
        colorPickerCancelButton.alpha = 0
        
        colorPickerDoneButton.isHidden = false
        colorPickerDoneButton.alpha = 0
        
        UIView.animate(withDuration: 0.2) {
            self.colorPickerContainerView.alpha = 1
            self.colorPickerCancelButton.alpha = 1
            self.colorPickerDoneButton.alpha = 1
        }
        
        selectingGridLineColor = true
    }
    
    @objc func tappedCanvasLockColorView(sender: UIView) {
        colorPickerViewController.selectedColor = UIColor(argb: SessionSettings.instance.canvasLockColor)
        
        colorPickerContainerView.isHidden = false
        colorPickerContainerView.alpha = 0
        
        colorPickerCancelButton.isHidden = false
        colorPickerCancelButton.alpha = 0
        
        colorPickerDoneButton.isHidden = false
        colorPickerDoneButton.alpha = 0
        
        UIView.animate(withDuration: 0.2) {
            self.colorPickerContainerView.alpha = 1
            self.colorPickerCancelButton.alpha = 1
            self.colorPickerDoneButton.alpha = 1
        }
        
        selectingCanvasLockColor = true
    }
    
    @objc func tappedCanvasBackgroundPrimaryColorView(sender: UIView) {
        if SessionSettings.instance.canvasBackgroundPrimaryColor == Utils.int32FromColorHex(hex: "0xffffffff") {
            colorPickerViewController.selectedColor = UIColor(argb: Utils.int32FromColorHex(hex: "0xffffffff"))
        }
        else {
            colorPickerViewController.selectedColor = UIColor(argb: SessionSettings.instance.canvasBackgroundPrimaryColor)
        }
        
        setupColorPicker()
        
        selectingCanvasPrimaryColor = true
    }
    
    @objc func tappedCanvasBackgroundSecondaryColorView(sender: UIView) {
        if SessionSettings.instance.canvasBackgroundSecondaryColor == Utils.int32FromColorHex(hex: "0xffffffff") {
            colorPickerViewController.selectedColor = UIColor(argb: Utils.int32FromColorHex(hex: "0xffffffff"))
        }
        else {
            colorPickerViewController.selectedColor = UIColor(argb: SessionSettings.instance.canvasBackgroundSecondaryColor)
        }
        
        setupColorPicker()
        
        selectingCanvasSecondaryColor = true
    }
    
    @objc func tappedFrameColorView(sender: UIView) {
        colorPickerViewController.selectedColor = UIColor(argb: SessionSettings.instance.frameColor)
        
        setupColorPicker()
        
        selectingFrameColor = true
    }
    
    @objc func tappedCloseDrawPanelColorView(sender: UIView) {
        if SessionSettings.instance.paintPanelCloseButtonColor == Utils.int32FromColorHex(hex: "0xffffffff") {
            colorPickerViewController.selectedColor = UIColor.white
        }
        else {
            colorPickerViewController.selectedColor = UIColor(argb: SessionSettings.instance.paintPanelCloseButtonColor)
        }
        
        setupColorPicker()
        
        selectingCloseDrawPanelColor = true
    }
    
    @IBAction func colorPickerCancelPressed(_ sender: Any) {
        if selectingGridLineColor {
            if SessionSettings.instance.gridLineColor == Utils.int32FromColorHex(hex: "0xffffffff") {
                gridLineColorColorView.backgroundColor = UIColor.white
                colorPickerViewController.selectedColor = UIColor.white
            }
            else {
                gridLineColorColorView.backgroundColor = UIColor(argb: SessionSettings.instance.gridLineColor)
                colorPickerViewController.selectedColor = UIColor(argb: SessionSettings.instance.gridLineColor)
            }
            
            selectingGridLineColor = false
        }
        else if selectingCanvasPrimaryColor {
            if SessionSettings.instance.canvasBackgroundPrimaryColor == Utils.int32FromColorHex(hex: "0xffffffff") {
                canvasBackgroundPrimaryColorColorView.backgroundColor = UIColor.white
                colorPickerViewController.selectedColor = UIColor.white
            }
            else {
                canvasBackgroundPrimaryColorColorView.backgroundColor = UIColor(argb: SessionSettings.instance.canvasBackgroundPrimaryColor)
                colorPickerViewController.selectedColor = UIColor(argb: SessionSettings.instance.canvasBackgroundPrimaryColor)
            }
            
            selectingCanvasPrimaryColor = false
        }
        else if selectingCanvasSecondaryColor {
            if SessionSettings.instance.canvasBackgroundSecondaryColor == Utils.int32FromColorHex(hex: "0xffffffff") {
                canvasBackgroundSecondaryColorColorView.backgroundColor = UIColor.white
                colorPickerViewController.selectedColor = UIColor.white
            }
            else {
                canvasBackgroundSecondaryColorColorView.backgroundColor = UIColor(argb: SessionSettings.instance.canvasBackgroundSecondaryColor)
                colorPickerViewController.selectedColor = UIColor(argb: SessionSettings.instance.canvasBackgroundSecondaryColor)
            }
            
            selectingCanvasSecondaryColor = false
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.colorPickerContainerView.alpha = 0
            self.colorPickerCancelButton.alpha = 0
            self.colorPickerDoneButton.alpha = 0
        }) { (success) in
            if success {
                self.colorPickerContainerView.isHidden = true
                self.colorPickerCancelButton.isHidden = true
                self.colorPickerDoneButton.isHidden = true
            }
        }
    }
    
    @IBAction func colorSelectDonePressed(_ sender: Any) {
        let color = self.colorPickerViewController.selectedColor
    
        if selectingPaintMeterColor {
            SessionSettings.instance.paintIndicatorColor = color.argb()
            
            selectingPaintMeterColor = false
        }
        else if selectingGridLineColor {
            SessionSettings.instance.gridLineColor = color.argb()
            
            selectingGridLineColor = false
        }
        else if selectingCanvasPrimaryColor {
            SessionSettings.instance.canvasBackgroundPrimaryColor = color.argb()
            
            selectingCanvasPrimaryColor = false
        }
        else if selectingCanvasSecondaryColor {
            SessionSettings.instance.canvasBackgroundSecondaryColor = color.argb()
            
            selectingCanvasSecondaryColor = false
        }
        else if selectingCanvasLockColor {
            SessionSettings.instance.canvasLockColor = color.argb()
            
            selectingCanvasLockColor = false
        }
        else if selectingFrameColor {
            SessionSettings.instance.frameColor = color.argb()
            
            selectingFrameColor = false
        }
        else if selectingCloseDrawPanelColor {
            SessionSettings.instance.paintPanelCloseButtonColor = color.argb()
            
            selectingCloseDrawPanelColor = false
        }
        
        UIView.animate(withDuration: 0.2) {
            self.colorPickerContainerView.alpha = 0
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.colorPickerContainerView.alpha = 0
            self.colorPickerCancelButton.alpha = 0
            self.colorPickerDoneButton.alpha = 0
        }) { (success) in
            if success {
                self.colorPickerContainerView.isHidden = true
                self.colorPickerCancelButton.isHidden = true
                self.colorPickerDoneButton.isHidden = true
            }
        }
    }
    
    func setupColorPicker() {
        colorPickerContainerView.isHidden = false
        colorPickerContainerView.alpha = 0
        
        colorPickerCancelButton.isHidden = false
        colorPickerCancelButton.alpha = 0
        
        colorPickerDoneButton.isHidden = false
        colorPickerDoneButton.alpha = 0
        
        UIView.animate(withDuration: 0.2) {
            self.colorPickerContainerView.alpha = 1
            self.colorPickerCancelButton.alpha = 1
            self.colorPickerDoneButton.alpha = 1
        }
    }
    
    @IBAction func changeNamePressed(_ sender: Any) {
        let server = SessionSettings.instance.lastVisitedServer
        if (server == nil) {
            return
        }
        
        URLSessionHandler.instance.updateDisplayName(server: server!, name: self.checkedName) { (success) -> (Void) in
            if success {
                SessionSettings.instance.displayName = self.checkedName
                
                self.changeNameButton.isEnabled = false
                self.changeNameButton.setTitle("Updated", for: .disabled)
                
                self.changeNameTextField.isEnabled = false
                self.changeNameTextField.layer.borderWidth = 0
            }
        }
    }
    
    @IBAction func unwindToViewController(segue: UIStoryboardSegue) {
        changeNameTextField.text = SessionSettings.instance.displayName
    }
    
    func resizeImage(image: UIImage, newHeight: CGFloat) -> UIImage {
        let scale = newHeight / image.size.height
        let newWidth = image.size.width * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.changeNameButton.isEnabled = false
        textField.layer.borderWidth = 0
        return true
    }
    
    // ui textfield delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        let name = textField.text
        if (name != nil) {
            if name!.count > 20 {
                self.changeNameButton.isEnabled = false
                
                textField.layer.borderWidth = 0
                textField.layer.borderColor = UIColor(argb: ActionButtonView.redColor).cgColor
                
                return false
            }
            
            let server = SessionSettings.instance.lastVisitedServer
            
            if server == nil {
                return false
            }
            
            URLSessionHandler.instance.sendNameCheck(server: server!, name: name!.trimmingCharacters(in: .whitespacesAndNewlines)) { (success) -> (Void) in
                if success {
                    self.changeNameButton.isEnabled = true
                    self.checkedName = name!.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    textField.layer.borderWidth = 0
                    textField.layer.borderColor = UIColor(argb: ActionButtonView.greenColor).cgColor
                }
                else {
                    self.changeNameButton.isEnabled = false
                    
                    textField.layer.borderWidth = 0
                    textField.layer.borderColor = UIColor(argb: ActionButtonView.redColor).cgColor
                }
            }
        }
        
        
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UnwindToMenu" {
            SessionSettings.instance.save()
        }
        else if segue.identifier == "ColorPickerEmbed" {
            colorPickerViewController = segue.destination as! CustomColorPickerViewController
            colorPickerViewController.delegate = self
        }
        else if segue.identifier == "ShowPincode" {
            let pincodeViewContoller = segue.destination as! PincodeViewController
            
            if SessionSettings.instance.pincodeSet {
                pincodeViewContoller.mode = pincodeViewContoller.modeChangePincode
            }
            else {
                pincodeViewContoller.mode = pincodeViewContoller.modeSetPincode
            }
        }
    }
    
    // color picker delegate
    func colorPicker(_ colorPicker: ColorPickerController, selectedColor: UIColor, usingControl: ColorControl) {
        if selectingGridLineColor {
            gridLineColorColorView.backgroundColor = selectedColor
        }
        else if selectingCanvasPrimaryColor {
            canvasBackgroundPrimaryColorColorView.backgroundColor = selectedColor
        }
        else if selectingCanvasSecondaryColor {
            canvasBackgroundSecondaryColorColorView.backgroundColor = selectedColor
        }
    }
    
    func setGradientBackground() {
        let gradient = CAGradientLayer()

        gradient.frame = self.view.frame
        gradient.colors = [UIColor(argb: Utils.int32FromColorHex(hex: "0xff242E8F")).cgColor, UIColor(argb: Utils.int32FromColorHex(hex: "0xff8F3234")).cgColor]
        
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)

        view.layer.insertSublayer(gradient, at: 0)
    }
}
