//
//  PaletteColorsViewController.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 2/18/21.
//  Copyright © 2021 Eric Versteeg. All rights reserved.
//

import UIKit

protocol PaletteColorsDelegate: AnyObject {
    func notifyPaletteColorSelected(color: Int32)
}

class PaletteColorsViewController: UIViewController {
    @IBOutlet weak var paletteColorsView: PaletteColorsView!
}
