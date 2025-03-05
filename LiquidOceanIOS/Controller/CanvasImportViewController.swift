//
//  CanvasImportViewController.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 11/3/21.
//  Copyright © 2021 Eric Versteeg. All rights reserved.
//

import UIKit

class CanvasImportViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var backButton: ActionButtonFrame!
    @IBOutlet weak var backAction: ActionButtonView!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var urlTextField: UITextField!
    
    var alertTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setBackground()
        
        backButton.actionButtonView = backAction
        backAction.type = .backSolid
        
        backButton.setOnClickListener {
            self.performSegue(withIdentifier: "UnwindToOptions", sender: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.OrientationUtility.lockOrientation(UIInterfaceOrientationMask.landscape)
    }
    
    @IBAction func importButtonPressed(_ sender: Any) {
        let urlStr = urlTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if urlStr.count == 0 {
            showStatusText(text: "Please enter a Pastebin url.")
        }
        else if urlStr.count < 50 {
            if urlStr.contains("/") {
                let tokens = urlStr.split(separator: "/")
                if tokens.count > 0 {
                    let code = String(tokens[tokens.count - 1])
                    if code.count == 8 {
                        getAndImportCanvasData(code: code)
                    }
                    else {
                        showStatusText(text: "Code doesn\'t seem to be the right length.")
                    }
                }
                else {
                    showStatusText(text: "Could not find code in url.")
                }
            }
            else {
                let code = urlStr
                if code.count == 8 {
                    getAndImportCanvasData(code: code)
                }
                else {
                    showStatusText(text: "Code doesn\'t seem to be the right length.")
                }
            }
        }
        else {
            showStatusText(text: "Not a Pastebin url.")
        }
    }
    
    func showStatusText(text: String, color: Int32 = ActionButtonView.lightYellowColor) {
        statusLabel.isHidden = false
        statusLabel.textColor = UIColor(argb: color)
        statusLabel.text = text
    }
    
    func showCanvasReplaceAlert(jsonStr: String) {
        let alertController = UIAlertController(title: nil, message: "Importing canvas data will replace your current canvas and the canvas will be permanently erased. To proceed please type REPLACE CANVAS in all caps.", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            self.alertTextField = textField
        }
        
        alertController.addAction(UIAlertAction(title: "Import", style: .destructive, handler: { alertAction in
            if self.alertTextField.text != nil && self.alertTextField.text == "REPLACE CANVAS" {
                self.importCanvasData(jsonStr: jsonStr)
            }
            else {
                self.showStatusText(text: "Import cancelled.")
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { UIAlertAction in
            self.showStatusText(text: "Import cancelled.")
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func getAndImportCanvasData(code: String) {
        getCanvasData(code: code) { jsonStr in
            if jsonStr != nil {
                self.showCanvasReplaceAlert(jsonStr: jsonStr!)
            }
            else {
                self.showStatusText(text: "Error downloading canvas data.")
            }
        }
    }
    
    func importCanvasData(jsonStr: String) {
        let success = InteractiveCanvas.importCanvasFromJson(jsonString: jsonStr)
        if !success {
            showStatusText(text: "Error reading canvas data.")
        }
        else {
            SessionSettings.instance.restoreDeviceViewportCenterX = CGFloat(0)
            SessionSettings.instance.restoreCanvasScaleFactor = CGFloat(0)
            
            SessionSettings.instance.reloadCanvas = true
            SessionSettings.instance.replaceCanvas = true
            
            showStatusText(text: "Canvas data imported!", color: ActionButtonView.greenColor)
        }
    }
    
    func getCanvasData(code: String, completionHandler: @escaping (String?) -> Void) {
        let url = "https://pastebin.com/raw/" + code
        
        var request = URLRequest(url: URL(string: url)!)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue())
        request.httpMethod = "GET"

        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            if error != nil {
                DispatchQueue.main.async {
                    completionHandler(nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse {
                    if (httpResponse.statusCode == 404) {
                        self.showStatusText(text: "Pastebin code didn\'t find anything.")
                    }
                    else {
                        completionHandler(String(data: data!, encoding: .utf8))
                    }
                }
            }
        })

        task.resume()
    }
    
    func setBackground() {
        let gradient = CAGradientLayer()

        gradient.frame = view.bounds
        gradient.colors = [UIColor(argb: Utils.int32FromColorHex(hex: "0xff000000")).cgColor, UIColor(argb: Utils.int32FromColorHex(hex: "0xff333333")).cgColor]
        
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)

        view.layer.insertSublayer(gradient, at: 0)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
