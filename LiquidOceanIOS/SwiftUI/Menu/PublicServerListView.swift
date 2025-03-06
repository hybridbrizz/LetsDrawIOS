//
//  PublicServerListView.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 3/4/25.
//  Copyright © 2025 Eric Versteeg. All rights reserved.
//

import SwiftUI

struct PublicServerListView: View {
    @ObservedObject var viewModel: ServerListViewModel
    var selectionDelegate: ServerSelectionDelegate
    
    var body: some View {
        ZStack {
            if viewModel.isPublicLoading {
                HStack {
                    ProgressView()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                Text("Servers")
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
                        ForEach(viewModel.publicServers) { server in
                            ServerListItemView(viewModel: viewModel, server: server, selectionDelegate: selectionDelegate, isPrivate: false)
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
