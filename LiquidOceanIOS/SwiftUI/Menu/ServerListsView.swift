//
//  ServerItemsView.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 3/2/25.
//  Copyright © 2025 Eric Versteeg. All rights reserved.
//

import SwiftUI

struct ServerListsView: View {
    @ObservedObject var viewModel: ServerListViewModel
    var serverSelectionDelegate: ServerSelectionDelegate
    var isPortrait: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            if !isPortrait {
                ZStack {}
                    .frame(minWidth: 1, maxWidth: 1, maxHeight: .infinity)
                    .background(Color(UIColor(argb: Utils.int32FromColorHex(hex: "0xFFFAD452"))).opacity(0.5))
                Spacer()
                    .frame(width: 10)
                ZStack {}
                    .frame(minWidth: 1, maxWidth: 1, maxHeight: .infinity)
                    .background(Color(UIColor(argb: Utils.int32FromColorHex(hex: "0xFFFAD452"))).opacity(0.5))
            }
            ZStack {
                VStack(spacing: 0) {
                    ZStack {
                        ZStack {
                            ZStack {
                                Text("PIXELS: TOGETHER")
                                    .foregroundStyle(.white)
                                    .font(.custom("Inter", size: 15))
                                    .fontWeight(.black)
                                    .padding(5)
                            }
                            .background(Color(UIColor(argb: Utils.int32FromColorHex(hex: "0xFFFF4D00"))))
                            .padding(5)
                        }
                        .border(.white, width: 1)
                        .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor(argb: Utils.int32FromColorHex(hex: "0xFF90D5FF"))))
                    
                    ZStack {}
                        .frame(maxWidth: .infinity, minHeight: 1, maxHeight: 1)
                        .background(Color(UIColor(argb: Utils.int32FromColorHex(hex: "0xFFFAD452"))).opacity(0.5))
                    
                    HStack(spacing: 0) {
                        ZStack {
                            Text("PUBLIC")
                                .foregroundStyle(.white)
                                .font(.custom("Inter", size: 13))
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
                        .clickable(bgColor: Color.clear, selectionColor: Color.black.opacity(0.2)) {
                            
                        }
                        ZStack {
                            Text("PRIVATE")
                                .foregroundStyle(.white)
                                .font(.custom("Inter", size: 13))
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
                        .clickable(bgColor: Color.clear, selectionColor: Color.black.opacity(0.2)) {
                            
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    ZStack {}
                        .frame(maxWidth: .infinity, minHeight: 1, maxHeight: 1)
                        .background(Color(UIColor(argb: Utils.int32FromColorHex(hex: "0xFFFAD452"))).opacity(0.5))
                    
                    HStack(spacing: 0) {
                        Spacer()
                        Button(action: {
                            viewModel.getPublicServers()
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .resizable()
                                .foregroundStyle(.white)
                                .frame(width: 24, height: 24)
                                .padding(10)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .background(.black.opacity(0.1))
                    
                    PublicServerListView(
                        viewModel: viewModel,
                        selectionDelegate: serverSelectionDelegate
                    )
                }
            }
            if !isPortrait {
                ZStack {}
                    .frame(minWidth: 1, maxWidth: 1, maxHeight: .infinity)
                    .background(Color(UIColor(argb: Utils.int32FromColorHex(hex: "0xFFFAD452"))).opacity(0.5))
                Spacer()
                    .frame(width: 10)
                ZStack {}
                    .frame(minWidth: 1, maxWidth: 1, maxHeight: .infinity)
                    .background(Color(UIColor(argb: Utils.int32FromColorHex(hex: "0xFFFAD452"))).opacity(0.5))
            }
        }
        .clipped()
        .task {
            viewModel.getPublicServers()
        }
    }
}
