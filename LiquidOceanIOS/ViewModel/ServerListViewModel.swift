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
    @Published var privateServers = [Server]()
    @Published var adminServers = [Server]()
    
    @Published var isPublicLoading = false
    @Published var isPrivateLoading = false
    
    private var lastPublicDownload = 0.0
    private var lastPrivateDownload = 0.0
    
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
    
    func getPrivateServers() {
        let cTime = NSDate().timeIntervalSince1970
        if cTime - lastPrivateDownload < 15 {
            return
        }
        
        isPrivateLoading = true
        
        let servers = SessionSettings.instance.servers
        var accessKeys = [String]()
        var adminKeys = [String]()
        
        for server in servers {
            if server.isAdmin {
                adminKeys.append(server.adminKey)
            }
            else {
                accessKeys.append(server.accessKey)
            }
        }
        
        var downloadCount = 0
        
        URLSessionHandler.instance.getPrivateServers(keys: accessKeys) { servers in
            SessionSettings.instance.syncServerStatus(remoteServers: servers, admin: false)
            
            downloadCount += 1
            
            var newPrivateServerList = [Server]()
            for server in SessionSettings.instance.servers {
                if !server.isAdmin {
                    newPrivateServerList.append(server)
                }
            }
            
            self.privateServers = newPrivateServerList
            
            if downloadCount == 2 {
                self.isPrivateLoading = false
                self.lastPrivateDownload = NSDate().timeIntervalSince1970
            }
        }
        
        URLSessionHandler.instance.getPrivateAdminServers(keys: adminKeys) { servers in
            SessionSettings.instance.syncServerStatus(remoteServers: servers, admin: true)
            
            downloadCount += 1
            
            var newPrivateServerList = [Server]()
            for server in SessionSettings.instance.servers {
                if server.isAdmin {
                    server.name = "\(server.name) (Mod)"
                    newPrivateServerList.append(server)
                }
            }
            
            self.adminServers = newPrivateServerList
            
            if downloadCount == 2 {
                self.isPrivateLoading = false
                self.lastPrivateDownload = NSDate().timeIntervalSince1970
            }
        }
    }
    
    func addPrivateServer(accessKey: String) {
        isPrivateLoading = true
        privateServers = []
        adminServers = []
        
        URLSessionHandler.instance.findServer(accessKey: accessKey) { success, statusCode, server in
            if let server = server {
                SessionSettings.instance.addServer(server: server)
            }
            
            self.privateServers = SessionSettings.instance.privateServers()
            self.adminServers = SessionSettings.instance.adminServers()
            
            self.isPrivateLoading = false
        }
    }
    
    func removePrivateServer(server: Server) {
        SessionSettings.instance.removeServer(server: server)
        self.privateServers = SessionSettings.instance.privateServers()
        self.adminServers = SessionSettings.instance.adminServers()
    }
}
