//
//  CanvasMenuView.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 3/2/25.
//  Copyright © 2025 Eric Versteeg. All rights reserved.
//

import SwiftUI

struct CanvasMenuView: View {
    @ObservedObject var interactiveCanvas: InteractiveCanvas
    let delegate: InteractiveCanvasMenuDelegate
    
    let items = [
        ItemInfo(title: "Server List", icon: .serverPerson),
        ItemInfo(title: "Community", icon: .community),
        ItemInfo(title: "Options", icon: .options),
        ItemInfo(title: "Yank Canvas", icon: .camera),
        ItemInfo(title: "Help", icon: .help),
        ItemInfo(title: "Leave", icon: .leave),
        ItemInfo(title: "Grid Lines", icon: .grid),
        ItemInfo(title: "Background", icon: .background),
        ItemInfo(title: "Minimap", icon: .map)
    ]
    
    let columns = [GridItem(.fixed(100)), GridItem(.fixed(100)), GridItem(.fixed(100))]
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                VStack {
                    ZStack(alignment: .trailing) {
                        Text(SessionSettings.instance.lastVisitedServer!.name)
                            .font(.custom("Inter", size: 14))
                            .fontWeight(.black)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        HStack {
                            Text(interactiveCanvas.latencyText)
                                .font(.custom("Inter", size: 14))
                                .fontWeight(.light)
                                .foregroundStyle(.white)
                            
                            let imageName = if interactiveCanvas.isConnected {
                                "green_circle.png"
                            }
                            else {
                                "red_circle.png"
                            }

                            Image(uiImage: UIImage(named: imageName)!)
                                .resizable()
                                .frame(width: 10, height: 10)
                            
                            Spacer()
                                .frame(width: 2)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    Spacer().frame(height: 16)
                    
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(items) { item in
                            CanvasMenuItemView(
                                title: item.title,
                                icon: item.icon
                            ) { title in
                                switch title {
                                    case "Server List":
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
                                    case "Grid Lines":
                                        delegate.notifyGridLinesClicked()
                                        break
                                    case "Background":
                                        delegate.notifyChangeBackgroundClicked()
                                        break
                                    case "Minimap":
                                        delegate.notifySummaryClicked()
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
                .background(Color(UIColor(argb: Utils.int32FromColorHex(hex: "0xFF1b1b1b"))))
                .cornerRadius(10)
                
                Spacer()
            }
            .frame(
                maxWidth: .infinity
            )
            .onTapGesture {
                delegate.notifyRequestClose()
            }
            
            Spacer()
        }
        .frame(
            maxHeight: .infinity
        )
        .onTapGesture {
            delegate.notifyRequestClose()
        }
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
