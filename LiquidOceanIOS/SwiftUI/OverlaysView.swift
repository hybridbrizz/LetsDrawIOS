//
//  OverlaysView.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 2/28/25.
//  Copyright © 2025 Eric Versteeg. All rights reserved.
//

import SwiftUI

struct OverlaysView: View {
    @ObservedObject var surfaceView: InteractiveCanvasView
    @ObservedObject var interactiveCanvas: InteractiveCanvas
    
    let circleSize = CGFloat(20)
    
    var body: some View {
        Canvas { context, size in
            for info in interactiveCanvas.clientsInfo {
                if surfaceView.redrawCount > 3 {}
                
                let x = info.center % interactiveCanvas.cols
                let y = info.center / interactiveCanvas.cols
                let unitRect = interactiveCanvas.getScreenSpaceForUnit(x: x, y: y)
                let centerPoint = CGPoint(x: unitRect.origin.x, y: unitRect.origin.y)
                
                let circlePath = Path(ellipseIn: CGRect(x: centerPoint.x - circleSize / 2, y: centerPoint.y - circleSize / 2, width: circleSize, height: circleSize))
                context.fill(circlePath, with: .color(Color(uiColor: UIColor(argb: info.color))))
            }
        }
        .ignoresSafeArea()
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
    }
}
