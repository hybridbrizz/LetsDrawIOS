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
    let sections = ["Mod", "Private"]
    
    @State var editingMod = false
    @State var editingPrivate = false
    
    var body: some View {
        ZStack {
            if viewModel.isPrivateLoadingOnce {
                HStack {
                    ProgressView()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            else {
                if viewModel.adminServers.isEmpty && viewModel.privateServers.isEmpty {
                    ZStack {
                        Text("No private servers yet.").font(.custom("Inter", size: 14)).foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                ScrollView {
                    LazyVGrid(columns: Array(repeating: .init(spacing: 20, alignment: .top), count: 2), spacing: 30) {
                        if !viewModel.adminServers.isEmpty {
                            Section(header: ZStack(alignment: .trailing) {
                                Text("Mod")
                                    .frame(maxWidth: .infinity)
                                
                                Button(action: {
                                    editingMod = !editingMod
                                }, label: {
                                    Image(systemName: "pencil")
                                        .resizable()
                                        .foregroundStyle(.white)
                                        .frame(width: 20, height: 20)
                                })
                            }) {
                                ForEach(viewModel.adminServers) { server in
                                    ServerListItemView(viewModel: viewModel, server: server, selectionDelegate: selectionDelegate, showRemoveButton: editingMod, onRemove: {
                                        editingMod = false
                                    })
                                }
                            }
                        }
                        if !viewModel.privateServers.isEmpty {
                            Section(header: ZStack(alignment: .trailing) {
                                Text("Private")
                                    .frame(maxWidth: .infinity)
                                
                                Button(action: {
                                    editingPrivate = !editingPrivate
                                }, label: {
                                    Image(systemName: "pencil")
                                        .resizable()
                                        .foregroundStyle(.white)
                                        .frame(width: 20, height: 20)
                                })
                            }) {
                                ForEach(viewModel.privateServers) { server in
                                    ServerListItemView(viewModel: viewModel, server: server, selectionDelegate: selectionDelegate, showRemoveButton: editingPrivate, onRemove: {
                                        editingPrivate = false
                                    })
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .refreshable {
                    viewModel.getPrivateServers()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
