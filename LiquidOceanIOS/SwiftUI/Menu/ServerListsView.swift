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
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
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
        .task {
            viewModel.getPublicServers()
        }
    }
}
