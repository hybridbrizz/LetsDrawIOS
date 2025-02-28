//
//  CombinedGestureView.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 2/27/25.
//  Copyright © 2025 Eric Versteeg. All rights reserved.
//

import UIKit

// Thanks Claude!
class CombinedGestureView: UIView {
    // Callbacks for different gesture types
    var onPanGesture: ((CGPoint) -> Void)?
    var onPinchGesture: ((CGFloat, CGPoint) -> Void)?
    
    // Touch tracking
    private var activeTouches: [UITouch: CGPoint] = [:]
    private var initialTouchDistance: CGFloat?
    private var lastPinchCenter: CGPoint?
    
    // Override touch handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        // Add new touches to our tracking dictionary
        for touch in touches {
            let location = touch.location(in: self)
            activeTouches[touch] = location
        }
        
        updateGestureState()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        // Update tracked touch positions
        for touch in touches {
            let location = touch.location(in: self)
            activeTouches[touch] = location
        }
        
        updateGestureState()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        // Remove ended touches
        for touch in touches {
            activeTouches.removeValue(forKey: touch)
        }
        
        // Reset tracking if all touches are gone
        if activeTouches.isEmpty {
            initialTouchDistance = nil
            lastPinchCenter = nil
        } else {
            updateGestureState()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        activeTouches.removeAll()
        initialTouchDistance = nil
        lastPinchCenter = nil
    }
    
    private func updateGestureState() {
        let touchLocations = Array(activeTouches.values)
        
        if touchLocations.count == 1 {
            // Single touch - handle as pan
            handlePan(location: touchLocations[0])
        }
        else if touchLocations.count >= 2 {
            // Get the first two touch points for pinch calculation
            let point1 = touchLocations[0]
            let point2 = touchLocations[1]
            
            // Calculate current distance and center
            let currentDistance = distance(between: point1, and: point2)
            let center = CGPoint(x: (point1.x + point2.x) / 2, y: (point1.y + point2.y) / 2)
            
            // Initialize tracking values if needed
            if initialTouchDistance == nil {
                initialTouchDistance = currentDistance
                lastPinchCenter = center
            }
            
            if let initialDist = initialTouchDistance, let lastCenter = lastPinchCenter {
                // Calculate scale factor
                let scale = currentDistance / initialDist
                
                // Handle combined pan and pinch
                handlePan(location: center)
                handlePinch(scale: scale, center: center)
                
                // Update last center
                lastPinchCenter = center
            }
        }
    }
    
    private func handlePan(location: CGPoint) {
        onPanGesture?(location)
    }
    
    private func handlePinch(scale: CGFloat, center: CGPoint) {
        onPinchGesture?(scale, center)
    }
    
    private func distance(between point1: CGPoint, and point2: CGPoint) -> CGFloat {
        let dx = point2.x - point1.x
        let dy = point2.y - point1.y
        return sqrt(dx*dx + dy*dy)
    }
}
