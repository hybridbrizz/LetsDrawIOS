//
//  CanvasMenuView.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 3/2/25.
//  Copyright © 2025 Eric Versteeg. All rights reserved.
//

import SwiftUI

struct CanvasMenuView: View {
    let delegate: InteractiveCanvasMenuDelegate
    
    let items = [
        ItemInfo(title: "Person List", icon: .serverPerson),
        ItemInfo(title: "Community", icon: .community),
        ItemInfo(title: "Options", icon: .options),
        ItemInfo(title: "Yank Canvas", icon: .camera),
        ItemInfo(title: "Help", icon: .help),
        ItemInfo(title: "Leave", icon: .leave)
    ]
    
    let columns = [GridItem(.fixed(100)), GridItem(.fixed(100)), GridItem(.fixed(100))]
    
    var body: some View {
        HStack {
            Spacer()
            
            VStack {
                Text(SessionSettings.instance.lastVisitedServer!.name)
                    .font(.custom("Inter", size: 14))
                    .fontWeight(.black)
                    .foregroundStyle(.white)

                Spacer().frame(height: 16)
                
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(items) { item in
                        CanvasMenuItemView(
                            title: item.title,
                            icon: item.icon
                        ) { title in
                            switch title {
                                case "Person List":
                                    delegate.notifyPersonListClicked()
                                    break
                                case "Community":
                                    delegate.notifyCommunityClicked()
                                    break
                                case "Options":
                                    delegate.notifyOptionsClicked()
                                    break
                                case "Yank Canvas":
                                    delegate.notifyYankCanvasClicked()
                                    break
                                case "Help":
                                    delegate.notifyHelpClicked()
                                    break
                                case "Leave":
                                    delegate.notifyLeaveClicked()
                                    break
                                default:
                                    break
                            }
                        }
                    }
                }
                .fixedSize()
            }
            .padding(16)
            .background(Color(UIColor.darkGray))
            .cornerRadius(10)
            
            Spacer()
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
    }
}

class ItemInfo: Identifiable {
    var title: String
    var icon: ImageResource
    
    init(title: String, icon: ImageResource) {
        self.title = title
        self.icon = icon
    }
}
