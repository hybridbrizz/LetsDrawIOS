//
//  AddPrivateServerView.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 3/5/25.
//  Copyright © 2025 Eric Versteeg. All rights reserved.
//

import SwiftUI

struct AddPrivateServerView: View {
    @ObservedObject var viewModel: ServerListViewModel
    
    var onClose: () -> Void
    // Thanks Apple!
    @State private var key: String = ""
    @State private var addButtonActive = false
    @FocusState private var keyFieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField(
                    "Access Key",
                    text: $key
                )
                .focused($keyFieldFocused)
        //        .onSubmit {
        //
        //        }
                .onChange(of: key, perform: { key in
                    if key.count > 0 {
                        addButtonActive = true
                    }
                    else if key.count == 0 {
                        addButtonActive = false
                    }
                })
                .textInputAutocapitalization(.characters)
                .disableAutocorrection(true)
                .submitLabel(.done)
                .font(.custom("Inter", size: 24))
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 200, height: 50)
                
                Button(action: {
                    viewModel.addPrivateServer(accessKey: key)
                    
                    UIApplication.shared.endEditing()
                    key = ""
                    
                    onClose()
                }, label: {
                    Text("Add")
                        .foregroundStyle(.white)
                        .font(.custom("Inter", size: 14))
                        .fontWeight(.bold)
                })
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button(action: {
                    UIApplication.shared.endEditing()
                    key = ""
                    
                    onClose()
                }) {
                    Image(systemName: "xmark")
                        .resizable()
                        .foregroundStyle(.white)
                        .frame(width: 20, height: 20)
                }
            }
            ZStack {}
                .frame(maxWidth: .infinity, minHeight: 1 / UIScreen.main.scale, maxHeight: 1 / UIScreen.main.scale)
                .background(.white)
        }
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
}
