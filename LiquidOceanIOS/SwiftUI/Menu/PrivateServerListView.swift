//
//  PrivateServerListView.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 3/5/25.
//  Copyright © 2025 Eric Versteeg. All rights reserved.
//

import SwiftUI

struct PrivateServerListView: View {
    @ObservedObject var viewModel: ServerListViewModel
    var selectionDelegate: ServerSelectionDelegate
    
    var body: some View {
        ZStack {
            if viewModel.isPrivateLoading {
                HStack {
                    ProgressView()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            else {
                if viewModel.adminServers.isEmpty && viewModel.privateServers.isEmpty {
                    ZStack {
                        Text("Enter an access key to add canvas.").font(.custom("Inter", size: 12)).foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        if viewModel.adminServers.count > 0 && viewModel.privateServers.count > 0 {
                            VStack(spacing: 0) {
                                HStack(spacing: 0) {
                                    Text("Mod")
                                        .foregroundStyle(.white)
                                        .font(.custom("Inter", size: 13))
                                        .fontWeight(.bold)
                                        .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                    Spacer()
                                }
                                ZStack {}
                                    .frame(maxWidth: .infinity, minHeight: 1, maxHeight: 1)
                                    .background(Color(UIColor(argb: Utils.int32FromColorHex(hex: "0xFFFAD452"))).opacity(0.5))
                            }
                            .frame(maxWidth: .infinity)
                        }
                        ForEach(viewModel.adminServers) { server in
                            ServerListItemView(viewModel: viewModel, server: server, selectionDelegate: selectionDelegate, isPrivate: true)
                        }
                        if viewModel.adminServers.count > 0 && viewModel.privateServers.count > 0 {
                            VStack(spacing: 0) {
                                HStack(spacing: 0) {
                                    Text("Private")
                                        .foregroundStyle(.white)
                                        .font(.custom("Inter", size: 13))
                                        .fontWeight(.bold)
                                        .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                    Spacer()
                                }
                                ZStack {}
                                    .frame(maxWidth: .infinity, minHeight: 1, maxHeight: 1)
                                    .background(Color(UIColor(argb: Utils.int32FromColorHex(hex: "0xFFFAD452"))).opacity(0.5))
                            }
                            .frame(maxWidth: .infinity)
                        }
                        ForEach(viewModel.privateServers) { server in
                            ServerListItemView(viewModel: viewModel, server: server, selectionDelegate: selectionDelegate, isPrivate: true)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
