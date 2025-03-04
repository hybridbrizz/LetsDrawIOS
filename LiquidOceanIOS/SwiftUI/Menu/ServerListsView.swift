//
//  ServerItemsView.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 3/2/25.
//  Copyright © 2025 Eric Versteeg. All rights reserved.
//

import SwiftUI

struct ServerListsView: View {
    @StateObject var viewModel = ServerListViewModel()
    var serverSelectionDelegate: ServerSelectionDelegate
    
    var body: some View {
        ZStack {
            if viewModel.isPublicLoading {
                ProgressView()
            }
            else {
                VStack(spacing: 0) {
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
                    .ignoresSafeArea()
                    .frame(maxWidth: .infinity)
                    
                    HStack(spacing: 0) {
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            VStack(spacing: 0) {
                                ZStack {}
                                    .frame(maxWidth: .infinity, minHeight: 1, maxHeight: 1)
                                    .background(Color(UIColor(argb: Utils.int32FromColorHex(hex: "0xFFFAD452"))).opacity(0.5))
                                HStack(spacing: 0) {
                                    Text("Servers")
                                        .foregroundStyle(.white)
                                        .font(.custom("Inter", size: 13))
                                        .fontWeight(.bold)
                                        .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                    Spacer()
                                }
                            }
                            .frame(maxWidth: .infinity)
                            ForEach(viewModel.publicServers) { server in
                                ServerListItemView(server: server, selectionDelegate: serverSelectionDelegate)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .ignoresSafeArea()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .task {
            viewModel.getPublicServers()
        }
    }
}
