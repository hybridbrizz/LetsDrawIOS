//
//  ServerListItemView.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 3/3/25.
//  Copyright © 2025 Eric Versteeg. All rights reserved.
//

import SwiftUI

struct ServerListItemView: View {
    @ObservedObject var viewModel: ServerListViewModel
    var server: Server
    var selectionDelegate: ServerSelectionDelegate
    var isPrivate: Bool
    
    @State var showDeleteAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
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
            
            ZStack {}
                .frame(maxWidth: .infinity, minHeight: 1, maxHeight: 1)
                .background(Color(UIColor(argb: Utils.int32FromColorHex(hex: "0xFFFAD452"))).opacity(0.5))
        }
//        .clickable(bgColor: Color.clear, selectionColor: Color.black.opacity(0.2)) {
//            selectionDelegate.onServerSelected(server: server)
//        }
        // Thanks Jensie - https://stackoverflow.com/questions/58284994/swiftui-how-to-handle-both-tap-long-press-of-button
        .simultaneousGesture(
            LongPressGesture()
                .onEnded { _ in
                    showDeleteAlert = true
                }
        )
        .highPriorityGesture(
            TapGesture()
                .onEnded { _ in
                    selectionDelegate.onServerSelected(server: server)
                }
        )
        // Thanks Cluade!
        .alert("Remove", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            
            Button("Remove", role: .destructive) {
                viewModel.removePrivateServer(server: server)
            }
        } message: {
            Text("Are you sure you want to remove \(server.name)?")
        }
    }
}
