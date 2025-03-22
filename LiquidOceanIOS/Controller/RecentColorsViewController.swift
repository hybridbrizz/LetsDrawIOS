//
//  RecentColorsViewController.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 2/18/21.
//  Copyright © 2021 Eric Versteeg. All rights reserved.
//

import UIKit

protocol RecentColorsDelegate: AnyObject {
    func notifyRecentColorSelected(color: Int32)
}

class RecentColorsViewController: UIViewController {
    @IBOutlet weak var recentColorsView: RecentColorsView!
}
