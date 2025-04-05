//
//  Server.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 8/6/22.
//  Copyright © 2022 Eric Versteeg. All rights reserved.
//

import Foundation
import UIKit

class Server: NSObject, Identifiable {
    
    var uid = 0
    var name = ""
    var color: Int32 = 0
    var baseUrl = ""
    var iconUrl = ""
    var iconLink = ""
    var showBanner = false
    var bannerText = ""
    var pixelInterval = 0
    var maxPixels = 0
    var accessKey = ""
    var adminKey = ""
    var isAdmin = false
    var uuid = ""
    var apiPort = 0
    var altPort = 0
    var socketPort = 0
    var queuePort = 0
    var size = 0
    var maxSend = 0
    var connectionCount = 0
    var maxConnections = 0
    var isOnline = false
    var isPublic = false
    var lastVisited = 0.0
    var canvasImgUrl = ""
    
    override init() {
        super.init()
    }
    
    init(fromJson: [String: AnyObject]) {
        uid = fromJson["id"] as? Int ?? 0
        name = fromJson["name"] as? String ?? ""
        color = fromJson["color"] as? Int32 ?? 0
        baseUrl = fromJson["base_url"] as? String ?? ""
        iconUrl = fromJson["icon_url"] as? String ?? ""
        iconLink = fromJson["icon_link"] as? String ?? ""
        showBanner = fromJson["show_banner"] as? Bool ?? false
        bannerText = fromJson["banner_text"] as? String ?? ""
        pixelInterval = fromJson["pixel_interval"] as? Int ?? 0
        maxPixels = fromJson["max_pixels"] as? Int ?? 0
        isAdmin = fromJson["is_admin"] as? Bool ?? false
        
        if isAdmin {
            adminKey = fromJson["admin_key"] as? String ?? ""
        }
        else {
            accessKey = fromJson["access_key"] as? String ?? ""
        }
        
        apiPort = fromJson["api_port"] as? Int ?? 0
        altPort = fromJson["alt_port"] as? Int ?? 0
        socketPort = fromJson["socket_port"] as? Int ?? 0
        queuePort = fromJson["queue_port"] as? Int ?? 0
        
        size = fromJson["size"] as? Int ?? 0
        maxSend = fromJson["max_send"] as? Int ?? 0
        
        connectionCount = fromJson["connection_count"] as? Int ?? 0
        maxConnections = fromJson["max_connections"] as? Int ?? 0
        
        isOnline = fromJson["online"] as? Bool ?? false
        isPublic = fromJson["public"] as? Bool ?? false
        lastVisited = fromJson["last_visited"] as? Double ?? 0.0
        
        canvasImgUrl = fromJson["canvas_img_url"] as? String ?? ""
    }
    
    func serviceUrl() -> String {
        return "\(baseUrl):\(apiPort)/"
    }
    
    func socketUrl() -> String {
        return "\(baseUrl):\(socketPort)/"
    }
    
    func queueSocketUrl() -> String {
        return "\(baseUrl):\(queuePort)/"
    }
    
    func serviceAltUrl() -> String {
        return "\(baseUrl):\(altPort)/"
    }
    
    func toDictionary() -> [String: Any] {
        var jsonObj = [String: Any]()
        
        jsonObj["id"] = uid
        jsonObj["name"] = name
        jsonObj["color"] = color
        jsonObj["base_url"] = baseUrl
        jsonObj["pixel_interval"] = pixelInterval
        jsonObj["max_pixels"] = maxPixels
        jsonObj["access_key"] = accessKey
        jsonObj["admin_key"] = adminKey
        jsonObj["is_admin"] = isAdmin
        jsonObj["uuid"] = uuid
        jsonObj["api_port"] = apiPort
        jsonObj["alt_port"] = altPort
        jsonObj["socket_port"] = socketPort
        jsonObj["queue_port"] = queuePort
        jsonObj["size"] = size
        jsonObj["max_send"] = maxSend
        jsonObj["connection_count"] = connectionCount
        jsonObj["max_connections"] = maxConnections
        jsonObj["online"] = isOnline
        jsonObj["public"] = isPublic
        jsonObj["last_visited"] = lastVisited
        jsonObj["canvas_img_url"] = canvasImgUrl
        
        return jsonObj
    }
    
    func statusImage() -> UIImage {
        let imageName = if isOnline {
            "green_circle.png"
        }
        else {
            "red_circle.png"
        }
        return UIImage(named: imageName)!
    }
}
