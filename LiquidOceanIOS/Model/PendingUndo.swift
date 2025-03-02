//
//  PendingUndo.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 2/17/25.
//  Copyright © 2025 Eric Versteeg. All rights reserved.
//

import Foundation

class PendingUndo {
    var message: String
    
    private var task: Task<(), any Error>?
    
    init(restorePoints: [InteractiveCanvas.RestorePoint], message: String, onUndo: @escaping ([InteractiveCanvas.RestorePoint]) -> Void) {
        self.message = message
        
        self.task = Task {
            try await Task.sleep(for: .milliseconds(1500))
            
            if !Task.isCancelled {
                DispatchQueue.main.async {
                    onUndo(restorePoints)
                }
            }
        }
    }
    
    func cancel() {
        self.task?.cancel()
        self.task = nil
    }
}
