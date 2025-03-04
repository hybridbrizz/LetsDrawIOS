//
//  ServerListViewModel.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 3/2/25.
//  Copyright © 2025 Eric Versteeg. All rights reserved.
//

import Foundation

class ServerListViewModel: ObservableObject {
    
    @Published var publicServers = [Server]()
    @Published var isPublicLoading = false
    
    private var lastPublicDownload = 0.0
    
    func getPublicServers() {
        let cTime = NSDate().timeIntervalSince1970
        if cTime - lastPublicDownload < 15 {
            return
        }
        
        isPublicLoading = true
        
        URLSessionHandler.instance.getPublicServers { servers in
            let publicServerUniqueIds = SessionSettings.instance.publicServerUniqueIds
            let publicServerLastVisited = SessionSettings.instance.publicServerLastVisitedTimes
            for server in servers {
                server.uuid = publicServerUniqueIds["\(server.uid)"] ?? ""
                server.lastVisited = publicServerLastVisited["\(server.uid)"] ?? 0.0
            }
            self.publicServers = servers.sorted(by: { server, other in
                server.lastVisited > other.lastVisited
            })
            
            self.isPublicLoading = false
            self.lastPublicDownload = NSDate().timeIntervalSince1970
        }
    }
}
