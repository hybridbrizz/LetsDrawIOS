//
//  ColorPickerOutletsViewController.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 3/12/21.
//  Copyright © 2021 Eric Versteeg. All rights reserved.
//

import UIKit
import FlexColorPicker

protocol ColorPickerLayoutDelegate {
    func colorPickerDidLayoutSubviews(colorPickerViewController: ColorPickerOutletsViewController)
}

class ColorPickerOutletsViewController: CustomColorPickerViewController {

    @IBOutlet weak var defaultBlackButton: ActionButtonFrame!
    @IBOutlet weak var defaultBlackAction: ActionButtonView!
    
    @IBOutlet weak var defaultWhiteButton: ActionButtonFrame!
    @IBOutlet weak var defaultWhiteAction: ActionButtonView!
    
    //@IBOutlet weak var colorHexTextField: UITextField!
    
    @IBOutlet weak var hsbWheelXCenter: NSLayoutConstraint!
    @IBOutlet weak var hsbWheelYCenter: NSLayoutConstraint!
    
    @IBOutlet weak var hsbWheelWidth: NSLayoutConstraint!
    @IBOutlet weak var hsbWheelHeight: NSLayoutConstraint!
    
    @IBOutlet weak var brightnessSliderWidth: NSLayoutConstraint!
    
    var layoutDelegate: ColorPickerLayoutDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        defaultBlackAction.type = .defaultBlack
        defaultBlackButton.actionButtonView = defaultBlackAction
        
        defaultWhiteAction.type = .defaultWhite
        defaultWhiteButton.actionButtonView = defaultWhiteAction
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.OrientationUtility.lockOrientation(UIInterfaceOrientationMask.landscape)
    }
    
    override func viewDidLayoutSubviews() {
        layoutDelegate?.colorPickerDidLayoutSubviews(colorPickerViewController: self)
        
        if view.frame.size.height > 600 {
            //hsbWheelYCenter.constant = 0
        }
    }
}
