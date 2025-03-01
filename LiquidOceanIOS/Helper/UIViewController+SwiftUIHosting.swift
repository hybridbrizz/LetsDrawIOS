//
//  UIViewController+SwiftUIHosting.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 3/1/25.
//  Copyright © 2025 Eric Versteeg. All rights reserved.
//

import UIKit
import SwiftUI

extension UIViewController {
    
    func addSwiftUIViewToContainer(swiftUIView: some View, containerView: UIView) {
        let hostingController = UIHostingController(rootView: swiftUIView)
        hostingController.view.backgroundColor = UIColor.clear
        
        containerView.backgroundColor = UIColor.clear
        containerView.addSubview(hostingController.view)
        
        addChild(hostingController)
        
        hostingController.view.frame = containerView.bounds
        hostingController.didMove(toParent: self)
    }
}
