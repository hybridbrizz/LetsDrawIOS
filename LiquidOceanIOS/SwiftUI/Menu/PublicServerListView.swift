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
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ZStack {
            if viewModel.isPrivateLoadingOnce {
                HStack {
                    ProgressView()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            else {
                ScrollView {
                    LazyVGrid(columns: Array(repeating: .init(spacing: 20, alignment: .top), count: 2), spacing: 30) {
                        ForEach(viewModel.publicServers) { server in
                            ServerListItemView(viewModel: viewModel, server: server, selectionDelegate: selectionDelegate, showRemoveButton: false)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .refreshable {
                    viewModel.getPublicServers()
                }
            } 
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
