//
//  HelpListView.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 3/22/25.
//  Copyright © 2025 Eric Versteeg. All rights reserved.
//

import SwiftUI

struct HelpListView: View {
    @StateObject var viewModel = HelpViewModel()
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(viewModel.helpMessages) { message in
                    VStack {
                        ZStack {}
                            .frame(maxWidth: .infinity, minHeight: 1, maxHeight: 1)
                            .background(Color(UIColor(red: 255, green: 255, blue: 255, a: 50)))
                        HStack(alignment: .center) {
                            Text(message.msg)
                                .foregroundStyle(.white)
                                .font(.custom("Inter", size: 14))
                                .fontWeight(.regular)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer().frame(width: 10)
                            
                            ZStack {
                                Text("x")
                                    .foregroundStyle(.white)
                                    .font(.custom("Inter", size: 14))
                                    .fontWeight(.regular)
                                    .frame(alignment: .trailing)
                                    .contentShape(Rectangle())
                            }
                            .frame(width: 40, height: 50)
                            .background(.pink)
                            .onTapGesture {
                                
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .background(.blue)
                        .cornerRadius(10)
                        .clipped()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            viewModel.getHelpMessages()
        }
    }
}
