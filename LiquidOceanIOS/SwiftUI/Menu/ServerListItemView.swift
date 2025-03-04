//
//  ServerListItemView.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 3/3/25.
//  Copyright © 2025 Eric Versteeg. All rights reserved.
//

import SwiftUI

struct ServerListItemView: View {
    var server: Server
    var selectionDelegate: ServerSelectionDelegate
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {}
                .frame(maxWidth: .infinity, minHeight: 1, maxHeight: 1)
                .background(Color(UIColor(argb: Utils.int32FromColorHex(hex: "0xFFFAD452"))).opacity(0.5))
            HStack(alignment: .center) {
                Image(uiImage: server.statusImage())
                    .resizable()
                    .frame(width: 20, height: 20)
                
                Spacer().frame(width: 10)
                
                Text(server.name)
                    .foregroundStyle(.white)
                    .font(.custom("Inter", size: 16))
                    .fontWeight(.regular)
                
                Spacer()
                
                Text("[\(server.size)]")
                    .foregroundStyle(.white.opacity(0.3))
                    .font(.custom("Inter", size: 16))
                    .fontWeight(.regular)
                
                Spacer().frame(width: 10)
                
                Text("\(server.connectionCount) / \(server.maxConnections)")
                    .foregroundStyle(.white)
                    .font(.custom("Inter", size: 16))
                    .fontWeight(.regular)
            }
            .frame(maxWidth: .infinity)
            .padding(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
        }
        .clickable(bgColor: Color.clear, selectionColor: Color.black.opacity(0.2)) {
            selectionDelegate.onServerSelected(server: server)
        }
    }
}
