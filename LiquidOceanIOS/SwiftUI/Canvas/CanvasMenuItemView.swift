//
//  CanvasMenuItemView.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 3/2/25.
//  Copyright © 2025 Eric Versteeg. All rights reserved.
//

import SwiftUI

struct CanvasMenuItemView: View {
    var title: String
    var icon: ImageResource
    var onClick: (String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Text(title.uppercased())
                .font(.custom("Inter", size: 11))
                .fontWeight(.regular)
                .foregroundStyle(.white)
                .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
            ZStack {}
                .frame(width: 100, height: 1)
                .background(.white)
            ZStack(alignment: .center) {
                Image(icon)
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)
            }
            .frame(width: 100, height: 100)
            .clickable(bgColor: Color.clear, selectionColor: Color.black.opacity(0.5)) {
                onClick(title)
            }
        }
        .frame(width: 100)
        .background(Color(UIColor(argb: Utils.int32FromColorHex(hex: "0xFF1b1b1b"))))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.white, lineWidth: 2)
        )
    }
}
