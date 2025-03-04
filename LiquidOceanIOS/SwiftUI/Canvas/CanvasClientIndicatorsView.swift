//
//  OverlaysView.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 2/28/25.
//  Copyright © 2025 Eric Versteeg. All rights reserved.
//

import SwiftUI

struct CanvasClientIndicatorsView: View {
    @ObservedObject var surfaceView: InteractiveCanvasView
    @ObservedObject var interactiveCanvas: InteractiveCanvas
    
    let circleSize = CGFloat(20)
    
    var body: some View {
        if interactiveCanvas.showCanvasClientIndicators {
            Canvas { context, size in
                for info in interactiveCanvas.clientsInfo {
                    if info.name == SessionSettings.instance.displayNameOrId() {
                        continue
                    }
                    
                    if surfaceView.redrawCount > 3 {}
                    
                    let x = info.center % interactiveCanvas.cols
                    let y = info.center / interactiveCanvas.cols
                    let unitRect = interactiveCanvas.getScreenSpaceForUnit(x: x, y: y)
                    let centerPoint = CGPoint(x: unitRect.origin.x, y: unitRect.origin.y)
                    
                    let attrString = AttributedString(info.name, attributes: AttributeContainer().foregroundColor(.white))
                    let nameText = Text(attrString).font(.custom("Inter", size: 18)).fontWeight(.regular)
                    let resolvedNameText = context.resolve(nameText)
                    let textViewSize = resolvedNameText.measure(in: size)
                    
                    let firstLineEnd = CGPoint(x: centerPoint.x + 10, y: centerPoint.y - 20)
                    let secondLineEnd = CGPoint(x: firstLineEnd.x + textViewSize.width, y: firstLineEnd.y)
                    
                    var firstLinePath = Path()
                    firstLinePath.move(to: centerPoint)
                    firstLinePath.addLine(to: firstLineEnd)
                    
                    var secondLinePath = Path()
                    secondLinePath.move(to: firstLineEnd)
                    secondLinePath.addLine(to: secondLineEnd)
                    
                    context.draw(resolvedNameText, at: CGPoint(x: Int((secondLineEnd.x - firstLineEnd.x) / 2 + firstLineEnd.x), y: Int(firstLineEnd.y - textViewSize.height / 2) - 2), anchor: .center)
                    
                    context.stroke(firstLinePath, with: .color(Color.white), lineWidth: 1)
                    context.stroke(secondLinePath, with: .color(Color.white), lineWidth: 1)
                    
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
}
