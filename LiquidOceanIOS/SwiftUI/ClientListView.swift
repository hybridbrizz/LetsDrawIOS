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

    var body: some View {
        ZStack {
            Color(UIColor.darkGray)
            
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
                                Text(info.name)
                                    .foregroundStyle(.white)
                                    .font(.custom("Inter", size: 24))
                                    .fontWeight(.regular)
                                Spacer().frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
                        }
                        .clickable {
                            handleTap(info: info, interactiveCanvas: interactiveCanvas)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
    
    var onClick: () -> Void
    
    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .background(
                GeometryReader { geometry in
                    (isPressed ? Color.blue : Color.clear).onAppear {
                        self.viewFrame = geometry.frame(in: .local)
                    }
                }
            )
            // Thanks Claude!
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        // Touch down - finger is on the screen
                        withAnimation {
                            isPressed = true
                        }
                    }
                    .onEnded { gesture in
                        // Touch up - finger lifted from screen
                        withAnimation {
                            isPressed = false
                        }
                        
                        if viewFrame.contains(gesture.location) {
                            // Execute your action here
                            onClick()
                        }
                    }
            )
    }
}

extension View {
    func clickable(onClick: @escaping () -> Void) -> some View {
        self.modifier(ClickableModifier(onClick: onClick))
    }
}
