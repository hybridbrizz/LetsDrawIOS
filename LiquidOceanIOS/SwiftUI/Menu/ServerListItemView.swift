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
        VStack {
            ZStack {}
                .frame(maxWidth: .infinity, minHeight: 1, maxHeight: 1)
                .background(Color(UIColor(red: 255, green: 255, blue: 255, a: 50)))
            HStack(alignment: .center) {
                Image(uiImage: server.statusImage())
                    .resizable()
                    .frame(width: 20, height: 20)
                
                Spacer().frame(width: 10)
                
                Text(server.name)
                    .foregroundStyle(.white)
                    .font(.custom("Inter", size: 18))
                    .fontWeight(.regular)
                
                Spacer()
                
                Text("[\(server.size)]")
                    .foregroundStyle(.white.opacity(0.3))
                    .font(.custom("Inter", size: 18))
                    .fontWeight(.regular)
                
                Spacer().frame(width: 10)
                
                Text("\(server.connectionCount) / \(server.maxConnections)")
                    .foregroundStyle(.white)
                    .font(.custom("Inter", size: 18))
                    .fontWeight(.regular)
                Spacer().frame(width: 20)
            }
            .frame(maxWidth: .infinity)
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 10, trailing: 16))
        }
        .clickable(bgColor: Color.clear, selectionColor: Color.black.opacity(0.2)) {
            selectionDelegate.onServerSelected(server: server)
        }
    }
}
