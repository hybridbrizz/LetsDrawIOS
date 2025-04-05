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
    var showRemoveButton: Bool
    var onRemove: (() -> Void)? = nil
    
    @State var showDeleteAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                AsyncImage(url: URL(string: server.canvasImgUrl)) { img in
                    img.resizable()
                } placeholder: {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .border(Color(UIColor(argb: Utils.int32FromColorHex(hex: "0xFFFFFFFF"))), width: 1 / UIScreen.main.scale)
                
//                Text(verbatim: "(\(server.size)x\(server.size))")
//                    .foregroundStyle(.gray)
//                    .font(.custom("Inter", size: 16))
//                    .fontWeight(.regular)
//                    .background(.white)
            }
            
            HStack(alignment: .center) {
                Text(server.name)
                    .foregroundStyle(.white)
                    .font(.custom("Inter", size: 14))
                    .fontWeight(.regular)
                
                Spacer().frame(width: 5)
                
                Image(uiImage: server.statusImage())
                    .resizable()
                    .frame(width: 10, height: 10)
            }
            .frame(maxWidth: .infinity)
            .padding(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
            
            if showRemoveButton {
                Button(role: .destructive, action: {
                    showDeleteAlert = true
                }, label: {
                    Text("Remove")
                        .frame(minWidth: 50)
                        .foregroundStyle(.white)
                        .font(.custom("Inter", size: 12))
                        .fontWeight(.regular)
                })
                .buttonStyle(.bordered)
                .tint(.red)
            }
            else {
                Button(action: {
                    selectionDelegate.onServerSelected(server: server)
                }, label: {
                    Text("Connect")
                        .frame(minWidth: 50)
                        .foregroundStyle(.white)
                        .font(.custom("Inter", size: 12))
                        .fontWeight(.regular)
                })
                .buttonStyle(.bordered)
            }
        }
        .alert("", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            
            Button("Remove", role: .destructive) {
                viewModel.removePrivateServer(server: server)
                onRemove?()
            }
        } message: {
            Text("Remove \(server.name)?")
        }
    }
}
