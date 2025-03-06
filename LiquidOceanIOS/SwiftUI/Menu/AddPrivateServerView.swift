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
            ZStack {}
                .frame(maxWidth: .infinity, minHeight: 1, maxHeight: 1)
                .background(Color(UIColor(argb: Utils.int32FromColorHex(hex: "0xFFFAD452"))).opacity(0.5))
            HStack {
                Spacer().frame(width: 16)
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
                .border(.secondary)
                .submitLabel(.done)
                .font(.custom("Inter", size: 24))
                .fontWeight(.black)
                .foregroundStyle(.blue)
                .frame(width: 200, height: 50)
                
                let color = self.addButtonActive ? .blue : Color(UIColor.lightGray)
                
                ZStack {
                    Text("Add")
                        .foregroundStyle(.white)
                        .font(.custom("Inter", size: 14))
                        .fontWeight(.bold)
                }
                .frame(width: 50, height: 34)
                .background(color)
                .clickable(bgColor: Color.clear, selectionColor: Color.black.opacity(0.3)) {
                    UIApplication.shared.endEditing()
                    viewModel.addPrivateServer(accessKey: key)
                }
                Spacer()
                Button(action: {
                    UIApplication.shared.endEditing()
                    onClose()
                }) {
                    Image(systemName: "xmark")
                        .resizable()
                        .foregroundStyle(.white)
                        .frame(width: 20, height: 20)
                        .padding(10)
                }
            }
        }
    }
}
