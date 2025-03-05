//
//  PincodeViewController.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 3/22/21.
//  Copyright © 2021 Eric Versteeg. All rights reserved.
//

import UIKit

class PincodeViewController: UIViewController, UITextFieldDelegate {

    var mode = 1
    
    let modeSetPincode = 0
    let modeChangePincode = 1
    
    @IBOutlet weak var backAction: ActionButtonView!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var backActionLeading: NSLayoutConstraint!
    
    @IBOutlet weak var titleAction: ActionButtonView!
    
    @IBOutlet weak var pincodeOldLabel: UILabel!
    @IBOutlet weak var pincodeLabel: UILabel!
    @IBOutlet weak var pincodeLabel2: UILabel!
    
    @IBOutlet weak var pincodeOldTextField: UITextField!
    @IBOutlet weak var pincodeTextField: UITextField!
    @IBOutlet weak var pincodeTextField2: UITextField!
    
    @IBOutlet weak var pincodeButton: UIButton!
    
    @IBOutlet weak var pincodeTitleTop: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackground()
        
        backAction.type = .backSolid
        
        backAction.setOnClickListener {
            self.performSegue(withIdentifier: "UnwindToOptions", sender: nil)
        }
        
        titleAction.selectable = false
        titleAction.type = .pincode
        
        pincodeOldTextField.text = ""
        pincodeTextField.text = ""
        pincodeTextField2.text = ""
        
        statusLabel.textColor = UIColor(argb: ActionButtonView.altGreenColor)
        
        if mode == modeSetPincode {
            pincodeTitleTop.constant = 30
            
            pincodeOldLabel.isHidden = true
            pincodeOldTextField.isHidden = true
            
            pincodeLabel.text = "8-digit pincode"
            pincodeLabel2.text = "Repeat 8-dgit pincode"
            
            pincodeButton.setTitle("Set Pincode", for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.OrientationUtility.lockOrientation(UIInterfaceOrientationMask.landscape)
    }
    
    override func viewDidLayoutSubviews() {
        let backX = self.backAction.frame.origin.x
        if backX < 0 {
            backActionLeading.constant += 30
        }
    }
    
    @IBAction func pincodeButtonPressed() {
        if mode == modeChangePincode {
            changePincode()
        }
        else {
            setPincode()
        }
    }
    
    func setBackground() {
        let gradient = CAGradientLayer()

        gradient.frame = view.bounds
        gradient.colors = [UIColor(argb: Utils.int32FromColorHex(hex: "0xff000000")).cgColor, UIColor(argb: Utils.int32FromColorHex(hex: "0xff333333")).cgColor]
        
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)

        view.layer.insertSublayer(gradient, at: 0)
    }
    
    // ui textfield delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        pincodeButton.isEnabled = true
        return true
    }
    
    func setPincode() {
        pincodeButton.isEnabled = false
        
        let pincodeInput = pincodeTextField.text!
        let pincodeInput2 = pincodeTextField2.text!
        
        if SessionSettings.instance.displayName == "" {
            statusLabel.text = "You must first set a display name in Options"
            return
        }
        
        if pincodeInput.count == 0 {
            pincodeButton.isEnabled = true
            return
        }
        else if pincodeInput.count != 8 {
            statusLabel.text = "Pincode length is incorrect"
            return
        }
        
        if pincodeInput != pincodeInput2 {
            statusLabel.text = "Pincodes don't match"
            return
        }
        
//        URLSessionHandler.instance.setPincode(pincode: pincodeInput) { (success, data) in
//            if success {
//                SessionSettings.instance.pincodeSet = true
//
//                self.statusLabel.text = "Pincode changed. Go to options -> Sign-in to access your account from any device."
//            }
//            else {
//                self.statusLabel.text = "Server or connection error"
//            }
//        }
    }
    
    func changePincode() {
        pincodeButton.isEnabled = false
        
        let oldPincodeInput = pincodeOldTextField.text!
        let pincodeInput = pincodeTextField.text!
        let pincodeInput2 = pincodeTextField2.text!
        
        if oldPincodeInput.count == 0 {
            pincodeButton.isEnabled = true
            return
        }
        else if oldPincodeInput.count != 8 {
            statusLabel.text = "Old pincode length is incorrect"
            return
        }
        
        if pincodeInput.count == 0 {
            pincodeButton.isEnabled = true
            return
        }
        else if pincodeInput.count != 8 {
            statusLabel.text = "Pincode length is incorrect"
            return
        }
        
        if pincodeInput != pincodeInput2 {
            statusLabel.text = "Pincodes don't match"
            return
        }
        
//        URLSessionHandler.instance.changePincode(oldPincode: oldPincodeInput, pincode: pincodeInput) { (success, data) in
//            
//            if success {
//                if data["error"] != nil {
//                    self.statusLabel.text = "Pincode is incorrect"
//                }
//                else {
//                    SessionSettings.instance.pincodeSet = true
//                    
//                    self.statusLabel.text = "Pincode changed. Go to options -> Sign-in to access your account from any device."
//                }
//            }
//            else {
//                self.statusLabel.text = "Server or connection error"
//            }
//        }
    }
}
