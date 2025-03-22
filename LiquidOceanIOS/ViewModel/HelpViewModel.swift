//
//  HelpViewModel.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 3/22/25.
//  Copyright © 2025 Eric Versteeg. All rights reserved.
//

import Foundation

class HelpViewModel: ObservableObject {
    
    @Published var helpMessages = [HelpMessage]()
    
    func getHelpMessages() -> [HelpMessage] {
        var messages = [HelpMessage]()
        for message in SessionSettings.instance.getStartingHelpMessages() {
            messages.append(HelpMessage(msg: message))
        }
        helpMessages = messages
        return messages
    }
}

class HelpMessage: Identifiable {
    var msg: String
    
    init(msg: String) {
        self.msg = msg
    }
}
