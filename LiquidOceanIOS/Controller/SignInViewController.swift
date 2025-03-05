//
//  SignInViewController.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 2/23/21.
//  Copyright © 2021 Eric Versteeg. All rights reserved.
//

import UIKit
import GoogleSignIn

class SignInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var backAction: ActionButtonView!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var backActionLeading: NSLayoutConstraint!
    
    @IBOutlet weak var titleAction: ActionButtonView!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var pincodeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackground()
        
        backAction.type = .backSolid
        
        backAction.setOnClickListener {
            self.performSegue(withIdentifier: "UnwindToOptions", sender: nil)
        }
        
        titleAction.type = .signIn
        titleAction.selectable = false
        
        nameTextField.text = ""
        pincodeTextField.text = ""
        
        statusLabel.textColor = UIColor(argb: ActionButtonView.altGreenColor)
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
    
    @IBAction func signInPressed() {
        let nameInput = nameTextField.text!
        let pincodeInput = pincodeTextField.text!
        
        if nameInput.count > 20 {
            statusLabel.text = "Too many characters"
            return
        }
        else if nameInput.count == 0 {
            statusLabel.text = "Please enter a display name"
            return
        }
        
        if pincodeInput.count == 0 {
            statusLabel.text = "Please enter a pincode"
            return
        }
        else if pincodeInput.count != 8 {
            statusLabel.text = "Pincode length is incorrect"
            return
        }
        
//        URLSessionHandler.instance.pincodeAuth(name: nameInput, pincode: pincodeInput) { (success, data) in
//            if success {
//                if data["error"] != nil {
//                    self.statusLabel.text = "Display name or password is incorrect"
//                }
//                else {
//                    SessionSettings.instance.pincodeSet = true
//
//                    SessionSettings.instance.uniqueId = data["uuid"] as? String
//                    SessionSettings.instance.dropsAmt = data["paint_qty"] as? Int
//                    SessionSettings.instance.xp = data["xp"] as! Int
//
//                    SessionSettings.instance.displayName = data["name"] as! String
//
//                    SessionSettings.instance.sentUniqueId = true
//
//                    StatTracker.instance.numPixelsPaintedWorld = data["wt"] as! Int
//                    StatTracker.instance.numPixelsPaintedSingle = data["st"] as! Int
//                    StatTracker.instance.totalPaintAccrued = data["tp"] as! Int
//                    StatTracker.instance.numPixelOverwritesIn = data["oi"] as! Int
//                    StatTracker.instance.numPixelOverwritesOut = data["oo"] as! Int
//
//                    StatTracker.instance.save()
//
//                    self.statusLabel.text = "Successfully signed in"
//                }
//            }
//            else {
//                self.statusLabel.text = "Server or connection error"
//            }
//        }
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
}
