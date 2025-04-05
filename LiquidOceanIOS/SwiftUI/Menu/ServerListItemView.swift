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
        // Thanks Jensie - https://stackoverflow.com/questions/58284994/swiftui-how-to-handle-both-tap-long-press-of-button
//        .simultaneousGesture(
//            LongPressGesture()
//                .onEnded { _ in
//                    if isPrivate {
//                        showDeleteAlert = true
//                    }
//                }
//        )
//        .clickable(bgColor: Color.clear, selectionColor: Color.black.opacity(0.2)) {
//            
//        }
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
