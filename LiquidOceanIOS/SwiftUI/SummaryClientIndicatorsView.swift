//
//  SummaryClientIndicatorsView.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 3/1/25.
//  Copyright © 2025 Eric Versteeg. All rights reserved.
//

import SwiftUI

struct SummaryClientIndicatorsView: View {
    @ObservedObject var surfaceView: InteractiveCanvasView
    @ObservedObject var interactiveCanvas: InteractiveCanvas
    
    let circleSize = CGFloat(4)
    
    let cClientName = SessionSettings.instance.displayNameOrId()
    
    var body: some View {
        if interactiveCanvas.showSummaryClientIndicators {
            Canvas { context, size in
                for info in interactiveCanvas.clientsInfo {
                    if info.name == cClientName {
                        continue
                    }
                    
                    if surfaceView.redrawCount > 3 {}
                    
                    let x = CGFloat(info.center % interactiveCanvas.cols)
                    let y = CGFloat(info.center / interactiveCanvas.cols)
                    let centerPoint = CGPoint(x: (x / CGFloat(interactiveCanvas.cols)) * size.width, y: (y / CGFloat(interactiveCanvas.rows)) * size.height)
                    
                    let circlePath = Path(ellipseIn: CGRect(x: centerPoint.x - circleSize / 2, y: centerPoint.y - circleSize / 2, width: circleSize, height: circleSize))
                    context.fill(circlePath, with: .color(Color(uiColor: UIColor(argb: info.color))))
                }
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .topLeading
            )
        }
    }
}
