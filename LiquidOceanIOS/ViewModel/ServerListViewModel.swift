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
    
    @Published var isPublicLoadingOnce = false
    private var oncePublicLoading = true
    
    @Published var isPrivateLoadingOnce = false
    private var oncePrivateLoading = true
    
    private var lastPublicDownload = 0.0
    private var lastPrivateDownload = 0.0
    
    func getPublicServers() {
        if oncePublicLoading {
            isPublicLoadingOnce = true
        }
        
        URLSessionHandler.instance.getPublicServers { servers in
            let publicServerUniqueIds = SessionSettings.instance.publicServerUniqueIds
            let publicServerLastVisited = SessionSettings.instance.publicServerLastVisitedTimes
            for server in servers {
                server.uuid = publicServerUniqueIds["\(server.uid)"] ?? ""
                server.lastVisited = publicServerLastVisited["\(server.uid)"] ?? 0.0
            }
            self.publicServers = servers.sorted(by: { server, other in
                server.uid < other.uid
            })
            
            self.isPublicLoadingOnce = false
            self.oncePublicLoading = false
            
            self.lastPublicDownload = NSDate().timeIntervalSince1970
        }
    }
    
    func getPrivateServers() {
        if oncePrivateLoading {
            isPrivateLoadingOnce = true
        }
        
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
                self.isPrivateLoadingOnce = false
                self.oncePrivateLoading = false
                self.lastPrivateDownload = NSDate().timeIntervalSince1970
            }
        }
        
        URLSessionHandler.instance.getPrivateAdminServers(keys: adminKeys) { servers in
            SessionSettings.instance.syncServerStatus(remoteServers: servers, admin: true)
            
            downloadCount += 1
            
            var newPrivateServerList = [Server]()
            for server in SessionSettings.instance.servers {
                if server.isAdmin {
                    newPrivateServerList.append(server)
                }
            }
            
            self.adminServers = newPrivateServerList
            
            if downloadCount == 2 {
                self.isPrivateLoadingOnce = false
                self.oncePrivateLoading = false
                self.lastPrivateDownload = NSDate().timeIntervalSince1970
            }
        }
    }
    
    func addPrivateServer(accessKey: String) {
        URLSessionHandler.instance.findServer(accessKey: accessKey) { success, statusCode, server in
            if let server = server {
                let added = SessionSettings.instance.addServer(server: server)
                if added {
                    self.getPrivateServers()
                }
            }
        }
    }
    
    func removePrivateServer(server: Server) {
        SessionSettings.instance.removeServer(server: server)
        self.privateServers = SessionSettings.instance.privateServers()
        self.adminServers = SessionSettings.instance.adminServers()
    }
}
