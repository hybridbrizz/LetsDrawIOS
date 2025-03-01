//
//  ClientInfo.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 2/28/25.
//  Copyright © 2025 Eric Versteeg. All rights reserved.
//

import Foundation

class ClientInfo: NSObject {
    var name: String
    var color: Int32
    var center: Int
    
    init(name: String, color: Int32, center: Int) {
        self.name = name
        self.color = color
        self.center = center
        
        print("Client Info: \(name), \(color), \(center)")
    }
}
