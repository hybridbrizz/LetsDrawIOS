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
    
    @State var showPublicServers = true
    @State var showAddPrivateServerInput = false
    
    var body: some View {
        HStack(spacing: 0) {
            if !isPortrait {
                ZStack {}
                    .frame(minWidth: 1, maxWidth: 1, maxHeight: .infinity)
                    .background(Color(UIColor(argb: Utils.int32FromColorHex(hex: "0xFFFF4D00"))))
                Spacer()
                    .frame(width: 10)
                ZStack {}
                    .frame(minWidth: 1, maxWidth: 1, maxHeight: .infinity)
                    .background(Color(UIColor(argb: Utils.int32FromColorHex(hex: "0xFFFF4D00"))))
            }
            ZStack {
                VStack(spacing: 0) {
                    ZStack(alignment: .trailing) {
                        ZStack {
                            ZStack {
                                ZStack {
                                    Text("PIXELS: TOGETHER")
                                        .foregroundStyle(.white)
                                        .font(.custom("Inter", size: 20))
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
                        
                        if !showPublicServers && !showAddPrivateServerInput {
                            Button(action: {
                                showAddPrivateServerInput = true
                            }, label: {
                                Text("Add")
                            })
                            .tint(Color(UIColor(argb: Utils.int32FromColorHex(hex: "0xFFFAD452"))))
                            .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .clickable(bgColor: Color.clear, selectionColor: Color.clear) {
                        UIApplication.shared.endEditing()
                    }
                    
                    Spacer().frame(height: 10)
                    
                    HStack(spacing: 0) {
                        let publicTextColor = showPublicServers ? Color.black : Color.white
                        let publicBackground = showPublicServers ? Color.white : Color(red: 0.1, green: 0.1, blue: 0.1)
                        
                        ZStack {
                            Button(action: {
                                showPublicServers = true
                            }, label: {
                                Text("Global")
                                    .foregroundStyle(publicTextColor)
                                    .font(.custom("Inter", size: 11))
                                    .fontWeight(.regular)
                            })
                            .padding(10)
                        }
                        .frame(maxWidth: .infinity)
                        .background(publicBackground)
                        
                        Spacer().frame(width: 1, height: 32).background(.white)
                        
                        let privateTextColor = !showPublicServers ? Color.black : Color.white
                        let privateBackground = !showPublicServers ? Color.white : Color(red: 0.1, green: 0.1, blue: 0.1)
                        
                        ZStack {
                            Button(action: {
                                showPublicServers = false
                            }, label: {
                                Text("Group")
                                    .foregroundStyle(privateTextColor)
                                    .font(.custom("Inter", size: 11))
                                    .fontWeight(.regular)
                            })
                            .padding(10)
                        }
                        .frame(maxWidth: .infinity)
                        .background(privateBackground)
                    }
                    .frame(width: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 200))
                    .overlay {
                        RoundedRectangle(cornerRadius: 200).stroke(.white, lineWidth: 1)
                    }
                    
                    Spacer().frame(height: 10)
                    
                    if showAddPrivateServerInput && !showPublicServers {
                        AddPrivateServerView(viewModel: viewModel) {
                            showAddPrivateServerInput = false
                        }
                    }
                    
                    if showPublicServers {
                        PublicServerListView(
                            viewModel: viewModel,
                            selectionDelegate: serverSelectionDelegate
                        )
                    }
                    else {
                        PrivateServerListView(
                            viewModel: viewModel,
                            selectionDelegate: serverSelectionDelegate
                        )
                    }
                }
            }
            if !isPortrait {
                ZStack {}
                    .frame(minWidth: 1, maxWidth: 1, maxHeight: .infinity)
                    .background(Color(UIColor(argb: Utils.int32FromColorHex(hex: "0xFFFF4D00"))))
                Spacer()
                    .frame(width: 10)
                ZStack {}
                    .frame(minWidth: 1, maxWidth: 1, maxHeight: .infinity)
                    .background(Color(UIColor(argb: Utils.int32FromColorHex(hex: "0xFFFF4D00"))))
            }
        }
        .clipped()
        .task {
            viewModel.getPublicServers()
            viewModel.getPrivateServers()
        }
    }
}
