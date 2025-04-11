//
//  ClientListView.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 3/1/25.
//  Copyright © 2025 Eric Versteeg. All rights reserved.
//

import SwiftUI

struct ClientListView: View {
    @ObservedObject var interactiveCanvas: InteractiveCanvas

    let cClientName = SessionSettings.instance.displayNameOrId()
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 80)
            
            VStack(spacing: 0) {
                HStack(alignment: .center) {
                    Text("Map markers:")
                        .foregroundStyle(.white)
                        .font(.custom("Inter", size: 16))
                        .fontWeight(.regular)
                        .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))
                    Spacer()
                    ZStack(alignment: .center) {
                        Text(interactiveCanvas.mapMarkerMode)
                            .foregroundStyle(.white)
                            .font(.custom("Inter", size: 16))
                            .fontWeight(.bold)
                    }
                    .frame(width: 150, height: 50)
                    .clickable(bgColor: Color.black.opacity(0.2), selectionColor: Color.black.opacity(0.5)) {
                        interactiveCanvas.switchToNextMapMarkerMode()
                    }
                }
                .frame(maxWidth: .infinity)
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(interactiveCanvas.clientsInfo) { info in
                            VStack {
                                ZStack {}
                                    .frame(maxWidth: .infinity, minHeight: 1, maxHeight: 1)
                                    .background(Color(UIColor(red: 255, green: 255, blue: 255, a: 50)))
                                HStack(alignment: .center) {
                                    ZStack {}
                                    .frame(width: 20, height: 20)
                                    .background(Color(UIColor(argb: info.color)), in: Circle())
                                    Spacer().frame(width: 8)
                                    
                                    let name = info.name == cClientName ? "\(info.name) (you)" : info.name
                                    
                                    Text(name)
                                        .foregroundStyle(.white)
                                        .font(.custom("Inter", size: 20))
                                        .fontWeight(.regular)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
                            }
                            .clickable(bgColor: Color.clear, selectionColor: Color.black.opacity(0.2)) {
                                if info.name != SessionSettings.instance.displayNameOrId() {
                                    handleTap(info: info, interactiveCanvas: interactiveCanvas)
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: 360, height: 270)
            .background(Color(UIColor.darkGray))
            .cornerRadius(10)
            .clipped()
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

func handleTap(info: ClientInfo, interactiveCanvas: InteractiveCanvas) {
    let x = info.center % interactiveCanvas.cols
    let minX = max(x - 10, 0)
    let maxX = min(x + 10, interactiveCanvas.cols - 1)
    
    let y = info.center / interactiveCanvas.cols
    let minY = max(y - 10, 0)
    let maxY = min(y + 10, interactiveCanvas.rows - 1)
    
    let rx = Int.random(in: minX...maxX)
    let ry = Int.random(in: minY...maxY)
    
    interactiveCanvas.jumpToUnit(x: CGFloat(rx), y: CGFloat(ry))
}

struct ClickableModifier: ViewModifier {
    @State private var isPressed = false
    @State private var viewFrame = CGRect.zero
    
    var bgColor: Color
    var selectionColor: Color
    var onClick: () -> Void
    
    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .onTapGesture {
                onClick()
            }
    }
}

extension View {
    func clickable(bgColor: Color, selectionColor: Color, onClick: @escaping () -> Void) -> some View {
        self.modifier(ClickableModifier(bgColor: bgColor, selectionColor: selectionColor, onClick: onClick))
    }
}
