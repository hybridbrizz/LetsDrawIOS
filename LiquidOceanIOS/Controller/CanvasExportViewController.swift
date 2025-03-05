//
//  CanvasExportViewController.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 11/3/21.
//  Copyright © 2021 Eric Versteeg. All rights reserved.
//

import UIKit

class CanvasExportViewController: UIViewController {

    @IBOutlet weak var backAction: ActionButtonView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setBackground()
        
        backAction.type = .backSolid
        
        backAction.setOnClickListener {
            self.performSegue(withIdentifier: "UnwindToOptions", sender: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.OrientationUtility.lockOrientation(UIInterfaceOrientationMask.landscape)
    }
    
    func setBackground() {
        let gradient = CAGradientLayer()

        gradient.frame = view.bounds
        gradient.colors = [UIColor(argb: Utils.int32FromColorHex(hex: "0xff000000")).cgColor, UIColor(argb: Utils.int32FromColorHex(hex: "0xff333333")).cgColor]
        
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)

        view.layer.insertSublayer(gradient, at: 0)
    }
}
