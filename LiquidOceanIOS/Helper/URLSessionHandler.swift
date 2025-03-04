//
//  AlamofireManager.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 2/10/21.
//  Copyright © 2021 Eric Versteeg. All rights reserved.
//

import UIKit
import Foundation
import CFNetwork

class URLSessionHandler: NSObject, URLSessionTaskDelegate {

    //let baseUrl = "https://192.168.200.69:5000"
    let serversUrl = "https://matrixwarez.com:5050/"
    let key0 = "MYCEJUCNZ6AVZAVDZBHKJJYM6OIWQVDOC1OU7RZP"
    let key1 = "8AHI!VR7299G7cq3YsP359HDkKz682oNT3QHh?yyehuvkyzdm674w45o"
    
    static let instance = URLSessionHandler()
    
    func downloadCanvasPixels(server: Server, completionHandler: @escaping (Bool) -> Void) {
        
        var request = URLRequest(url: URL(string: "\(server.serviceUrl())api/v1/canvas/2/pixels")!)
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        request.httpMethod = "GET"

        // var params = ["username":"username", "password":"password"] as Dictionary<String, String>

        // request.HTTPBody = try? JSONSerialization.dataWithJSONObject(params, options: [])

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(key1, forHTTPHeaderField: "key1")

        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            if error != nil {
                DispatchQueue.main.async {
                    completionHandler(false)
                }
                return
            }
            
            SessionSettings.instance.userDefaults().set(String(data: data!, encoding: .utf8), forKey: "arr")
            
            DispatchQueue.main.async {
                completionHandler(true)
            }
        })

        task.resume()
    }
    
    func downloadCanvasChunkPixels(server: Server, chunk: Int, completionHandler: @escaping (Bool) -> Void) {
        
        var request = URLRequest(url: URL(string: "\(server.serviceUrl())api/v1/canvas/1/pixels/" + String(chunk))!)
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        request.httpMethod = "GET"

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(key1, forHTTPHeaderField: "key1")

        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            do {
                if error != nil {
                    DispatchQueue.main.async {
                        completionHandler(false)
                    }
                    return
                }
                
                let jsonArr = try JSONSerialization.jsonObject(with: data!, options: []) as! [[Int32]]
                
                var arr = [[Int32]]()
                
                for i in 0...jsonArr.count - 1 {
                    let innerJsonArr = jsonArr[i]
                    var innerArr = [Int32]()
                    for j in 0...innerJsonArr.count - 1 {
                        innerArr.append(innerJsonArr[j])
                    }
                    arr.append(innerArr)
                }
                
                if chunk == 1 {
                    SessionSettings.instance.chunk1 = arr
                }
                else if chunk == 2 {
                    SessionSettings.instance.chunk2 = arr
                }
                else if chunk == 3 {
                    SessionSettings.instance.chunk3 = arr
                }
                else if chunk == 4 {
                    SessionSettings.instance.chunk4 = arr
                }
            }
            catch {
                
            }
            
            DispatchQueue.main.async {
                completionHandler(true)
            }
        })

        task.resume()
    }
    
    func downloadTopContributors(server: Server, completionHandler: @escaping ([[String: Any]]?) -> Void) {
        
        var request = URLRequest(url: URL(string: "\(server.serviceUrl())api/v1/top/contributors")!)
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        request.httpMethod = "GET"

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(key1, forHTTPHeaderField: "key1")

        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            do {
                if error != nil {
                    DispatchQueue.main.async {
                        completionHandler(nil)
                    }
                    return
                }
                
                let jsonObj = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
                
                let jsonArr = jsonObj["data"] as! [[String: Any]]
                
                DispatchQueue.main.async {
                    completionHandler(jsonArr)
                }
            }
            catch {
                
            }
        })

        task.resume()
    }
    
    func pincodeAuth(server: Server, name: String, pincode: String, completionHandler: @escaping (Bool, [String: AnyObject]) -> Void) {
        
        var request = URLRequest(url: URL(string: "\(server.serviceUrl())api/v1/devices/pincode/auth")!)
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        request.httpMethod = "POST"

        let params = ["name": name, "pincode": pincode] as Dictionary<String, String>

        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(key1, forHTTPHeaderField: "key1")

        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            do {
                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
                
                if error != nil {
                    DispatchQueue.main.async {
                        completionHandler(false, jsonDict)
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    completionHandler(true, jsonDict)
                }
            }
            catch {
                
            }
        })

        task.resume()
    }
    
    func setPincode(server: Server, pincode: String, completionHandler: @escaping (Bool, [String: AnyObject]) -> Void) {
        
        var request = URLRequest(url: URL(string: "\(server.serviceUrl())api/v1/devices/" + SessionSettings.instance.uniqueId)!)
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        request.httpMethod = "POST"

        let params = ["pincode": pincode] as Dictionary<String, String>

        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(key1, forHTTPHeaderField: "key1")

        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            do {
                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
                
                if error != nil {
                    DispatchQueue.main.async {
                        completionHandler(false, jsonDict)
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    completionHandler(true, jsonDict)
                }
            }
            catch {
                
            }
        })

        task.resume()
    }
    
    func changePincode(server: Server, oldPincode: String, pincode: String, completionHandler: @escaping (Bool, [String: AnyObject]) -> Void) {
        
        var request = URLRequest(url: URL(string: "\(server.serviceUrl())api/v1/devices/" + SessionSettings.instance.uniqueId + "/pincode")!)
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        request.httpMethod = "POST"

        let params = ["old_pincode": oldPincode, "pincode": pincode] as Dictionary<String, String>

        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(key1, forHTTPHeaderField: "key1")

        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            do {
                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
                
                if error != nil {
                    DispatchQueue.main.async {
                        completionHandler(false, jsonDict)
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    completionHandler(true, jsonDict)
                }
            }
            catch {
                
            }
        })

        task.resume()
    }
    
    func sendDeviceId(server: Server, completionHandler: @escaping (Bool) -> (Void)) {
        var request = URLRequest(url: URL(string: "\(server.serviceUrl())api/v1/devices/register")!)
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        request.httpMethod = "POST"

        let params = ["uuid": server.uuid] as Dictionary<String, String>

        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(key1, forHTTPHeaderField: "key1")

        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            do {
                if error != nil {
                    DispatchQueue.main.async {
                        completionHandler(false)
                    }
                    return
                }
            
                SessionSettings.instance.saveServers()
                
                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
            
                SessionSettings.instance.deviceId = jsonDict["id"] as! Int
                SessionSettings.instance.dropsAmt = jsonDict["paint_qty"] as? Int
                //SessionSettings.instance.uniqueId = uniqueId
                SessionSettings.instance.sentUniqueId = true
                
                DispatchQueue.main.async {
                    completionHandler(true)
                }
            }
            catch {
                
            }
        })

        task.resume()
    }
    
    func sendDeviceStat(server: Server, eventType: StatTracker.EventType, amt: Int, completionHandler: @escaping (Bool) -> (Void)) {
        let uniqueId = SessionSettings.instance.uniqueId
        
        var request = URLRequest(url: URL(string: "\(server.serviceUrl())api/v1/devices/" + uniqueId)!)
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        request.httpMethod = "POST"

        var params = [String: Int]()

        var key = ""
        
        switch eventType {
            case .pixelPaintedWorld:
                key = "wt"
            case .pixelPaintedSingle:
                key = "st"
            case .paintReceived:
                key = "tp"
            case .pixelOverwriteIn:
                key = "oi"
            case .pixelOverwriteOut:
                key = "oo"
            default:
                key = ""
        }
        
        params[key] = amt
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(key1, forHTTPHeaderField: "key1")

        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            do {
                if error != nil {
                    DispatchQueue.main.async {
                        completionHandler(false)
                    }
                    return
                }
                
                let _ = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
                
                print(key + " updated.")
                
                DispatchQueue.main.async {
                    completionHandler(true)
                }
            }
            catch {
                
            }
        })

        task.resume()
    }
    
    func updateDisplayName(server: Server, name: String, completionHandler: @escaping (Bool) -> (Void)) {
        let uniqueId = SessionSettings.instance.uniqueId
        
        var request = URLRequest(url: URL(string: "\(server.serviceUrl())api/v1/devices/" + uniqueId)!)
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        request.httpMethod = "POST"

        var params = [String: String]()
        params["name"] = name
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(key1, forHTTPHeaderField: "key1")

        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            do {
                if error != nil || response == nil {
                    DispatchQueue.main.async {
                        completionHandler(false)
                        return
                    }
                }
                else {
                    DispatchQueue.main.async {
                        completionHandler(true)
                    }
                }
            }
            catch {
                
            }
        })

        task.resume()
    }
    
    func getDeviceInfo(server: Server, completionHandler: @escaping (Bool) -> (Void)) {
        let uniqueId = server.uuid
        
        var request = URLRequest(url: URL(string: "\(server.serviceUrl())api/v1/devices/" + uniqueId + "/info")!)
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        request.httpMethod = "GET"

        // let params = ["uuid": uniqueId] as Dictionary<String, String>

        // request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(key1, forHTTPHeaderField: "key1")

        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            do {
                if error != nil {
                    DispatchQueue.main.async {
                        completionHandler(false)
                    }
                    return
                }
                
                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
                
                SessionSettings.instance.deviceId = jsonDict["id"] as! Int
                SessionSettings.instance.dropsAmt = jsonDict["paint_qty"] as? Int
                SessionSettings.instance.xp = jsonDict["xp"] as! Int
                SessionSettings.instance.displayName = jsonDict["name"] as! String
                SessionSettings.instance.banned = (jsonDict["banned"] as! Int) != 0
                
                let pixelsWorld = jsonDict["wt"] as! Int
                let pixelsSingle = jsonDict["st"] as! Int
                let paintReceived = jsonDict["tp"] as! Int
                let overwritesIn = jsonDict["oi"] as! Int
                let overwritesOut = jsonDict["oo"] as! Int
                
                DispatchQueue.main.async {
                    StatTracker.instance.syncStatFromServer(eventType: .pixelPaintedWorld, total: pixelsWorld)
                    StatTracker.instance.syncStatFromServer(eventType: .pixelPaintedSingle, total: pixelsSingle)
                    StatTracker.instance.syncStatFromServer(eventType: .paintReceived, total: paintReceived)
                    StatTracker.instance.syncStatFromServer(eventType: .pixelOverwriteIn, total: overwritesIn)
                    StatTracker.instance.syncStatFromServer(eventType: .pixelOverwriteOut, total: overwritesOut)
                    
                    StatTracker.instance.save()
                    
                    completionHandler(true)
                }
            }
            catch {
                
            }
        })

        task.resume()
    }
    
    func sendApiStatusCheck(server: Server, completionHandler: @escaping (Bool) -> (Void)) {
        var request = URLRequest(url: URL(string: "\(server.serviceUrl())api/v1/status")!)
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 10
        
        let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
        request.httpMethod = "GET"

        // let params = ["uuid": uniqueId] as Dictionary<String, String>

        // request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(key1, forHTTPHeaderField: "key1")

        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            do {
                if error != nil || response == nil {
                    DispatchQueue.main.async {
                        completionHandler(false)
                        return
                    }
                }
                else {
                    DispatchQueue.main.async {
                        completionHandler(true)
                    }
                }
                
                // let jsonDict = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
                
                
            }
            catch {
                
            }
        })

        task.resume()
    }
    
    func sendNameCheck(server: Server, name: String, completionHandler: @escaping (Bool) -> (Void)) {
        var request = URLRequest(url: URL(string: "\(server.serviceUrl())api/v1/devices/checkname/" + name)!)
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 10
        
        let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
        request.httpMethod = "GET"

        // let params = ["uuid": uniqueId] as Dictionary<String, String>

        // request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(key1, forHTTPHeaderField: "key1")
        
        if name.count > 20 {
            DispatchQueue.main.async {
                completionHandler(false)
                return
            }
        }

        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            
            if error != nil || response == nil {
                DispatchQueue.main.async {
                    completionHandler(false)
                    return
                }
            }
            else {
                DispatchQueue.main.async {
                    do {
                        let jsonDict = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: Bool]
                        
                        DispatchQueue.main.async {
                            completionHandler(jsonDict["a"]!)
                        }
                    }
                    catch {
                        
                    }
                }
            }
        })

        task.resume()
    }
    
    func getPaintTimerInfo(server: Server, completionHandler: @escaping (Bool, Double) -> (Void)) {
        var request = URLRequest(url: URL(string: "\(server.serviceUrl())api/v1/paint/time/sync")!)
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 10
        
        let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
        request.httpMethod = "GET"

        // let params = ["uuid": uniqueId] as Dictionary<String, String>

        // request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(key1, forHTTPHeaderField: "key1")

        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            do {
                if error != nil || response == nil {
                    DispatchQueue.main.async {
                        completionHandler(false, 0)
                        return
                    }
                }
                else {
                    let jsonDict = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
                    
                    DispatchQueue.main.async {
                        completionHandler(true, jsonDict["s"] as! Double)
                    }
                }
                
            }
            catch {
                
            }
        })

        task.resume()
    }
    
    func sendGoogleToken(server: Server, token: String, completionHandler: @escaping (Bool) -> (Void)) {
        let uniqueId = SessionSettings.instance.uniqueId
        
        var request = URLRequest(url: URL(string: "\(server.serviceUrl())api/v1/devices/" + uniqueId + "/google/auth")!)
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        request.httpMethod = "POST"

        let params = ["token_id": token] as Dictionary<String, String>

        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(key1, forHTTPHeaderField: "key1")

        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            do {
                if error != nil {
                    DispatchQueue.main.async {
                        completionHandler(false)
                        return
                    }
                }
                
                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
                
                SessionSettings.instance.sentUniqueId = true
                
                SessionSettings.instance.dropsAmt = jsonDict["paint_qty"] as? Int
                SessionSettings.instance.xp = jsonDict["xp"] as! Int
                SessionSettings.instance.displayName = jsonDict["name"] as! String
                
                SessionSettings.instance.googleAuth = true
                SessionSettings.instance.uniqueId = token
                
                SessionSettings.instance.save()
                
                let pixelsWorld = jsonDict["wt"] as! Int
                let pixelsSingle = jsonDict["st"] as! Int
                let paintReceived = jsonDict["tp"] as! Int
                let overwritesIn = jsonDict["oi"] as! Int
                let overwritesOut = jsonDict["oo"] as! Int
                
                DispatchQueue.main.async {
                    StatTracker.instance.syncStatFromServer(eventType: .pixelPaintedWorld, total: pixelsWorld)
                    StatTracker.instance.syncStatFromServer(eventType: .pixelPaintedSingle, total: pixelsSingle)
                    StatTracker.instance.syncStatFromServer(eventType: .paintReceived, total: paintReceived)
                    StatTracker.instance.syncStatFromServer(eventType: .pixelOverwriteIn, total: overwritesIn)
                    StatTracker.instance.syncStatFromServer(eventType: .pixelOverwriteOut, total: overwritesOut)
                    
                    StatTracker.instance.save()
                    
                    completionHandler(true)
                }
            }
            catch {
                
            }
        })

        task.resume()
    }
    
    func downloadPixelHistory(server: Server, pixelId: Int, completionHandler: @escaping (Bool, [AnyObject]) -> Void) {
        
        var request = URLRequest(url: URL(string: "\(server.serviceAltUrl())api/v1/canvas/pixels/" + String(pixelId) + "/history")!)
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        request.httpMethod = "GET"

        // var params = ["username":"username", "password":"password"] as Dictionary<String, String>

        // request.HTTPBody = try? JSONSerialization.dataWithJSONObject(params, options: [])

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(key1, forHTTPHeaderField: "key1")

        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            do {
                if error != nil {
                    DispatchQueue.main.async {
                        completionHandler(false, [])
                    }
                    return
                }
                
                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
                
                DispatchQueue.main.async {
                    completionHandler(true, jsonDict["data"] as! [AnyObject])
                }
            }
            catch {
                
            }
        })

        task.resume()
    }
    
    func findServer(accessKey: String, completionHandler: @escaping (Bool, Int, Server?) -> Void) {
        
        var request = URLRequest(url: URL(string: serversUrl + "api/v1/find/server/" + accessKey)!)
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        request.httpMethod = "GET"

        // var params = ["username":"username", "password":"password"] as Dictionary<String, String>

        // request.HTTPBody = try? JSONSerialization.dataWithJSONObject(params, options: [])

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(key0, forHTTPHeaderField: "key0")

        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            do {
                if error != nil {
                    DispatchQueue.main.async {
                        completionHandler(false, 0, nil)
                    }
                    return
                }
                
                var code = 0
                if let httpReponse = response as? HTTPURLResponse {
                    code = httpReponse.statusCode
                    if code != 200 {
                        DispatchQueue.main.async {
                            completionHandler(true, code, nil)
                        }
                    }
                }
                
                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
                
                DispatchQueue.main.async {
                    let server = Server()
                    
                    server.uid = jsonDict["id"] as! Int
                    server.name = jsonDict["name"] as! String
                    server.color = jsonDict["color"] as! Int32
                    server.baseUrl = jsonDict["base_url"] as! String
                    server.iconUrl = jsonDict["icon_url"] as! String
                    server.iconLink = jsonDict["icon_link"] as! String
                    server.showBanner = jsonDict["show_banner"] as! Bool
                    server.bannerText = jsonDict["banner_text"] as! String
                    server.pixelInterval = jsonDict["pixel_interval"] as! Int
                    server.maxPixels = jsonDict["max_pixels"] as! Int
                    server.isAdmin = jsonDict["is_admin"] as! Bool
                    
                    if server.isAdmin {
                        server.adminKey = jsonDict["admin_key"] as! String
                    }
                    else {
                        server.accessKey = jsonDict["access_key"] as! String
                    }
                    
                    server.apiPort = jsonDict["api_port"] as! Int
                    server.altPort = jsonDict["alt_port"] as! Int
                    server.socketPort = jsonDict["socket_port"] as! Int
                    server.queuePort = jsonDict["queue_port"] as! Int
                    
                    server.size = jsonDict["size"] as! Int
                    server.maxSend = jsonDict["max_send"] as! Int
                    
                    completionHandler(true, code, server)
                }
            }
            catch {
                
            }
        })

        task.resume()
    }
    
    func getRecentPixels(server: Server, since: Double, completionHandler: @escaping ([String]?) -> Void) {
        
        var request = URLRequest(url: URL(string: server.serviceUrl() + "api/v1/recent/pixels/\(String(Int(since)))")!)
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        request.httpMethod = "GET"

        // var params = ["username":"username", "password":"password"] as Dictionary<String, String>

        // request.HTTPBody = try? JSONSerialization.dataWithJSONObject(params, options: [])

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(key1, forHTTPHeaderField: "key1")

        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            do {
                if error != nil {
                    DispatchQueue.main.async {
                        completionHandler(nil)
                    }
                    return
                }
                
                let jsonArray = try JSONSerialization.jsonObject(with: data!, options: []) as! [String]
                
                DispatchQueue.main.async {
                    completionHandler(jsonArray)
                }
            }
            catch {
                
            }
        })

        task.resume()
    }
    
    func getPaintQty(server: Server, uuid: String, completionHandler: @escaping ([String: AnyObject]?) -> Void) {
        
        var request = URLRequest(url: URL(string: server.serviceUrl() + "api/v1/device/paintqty/\(uuid)")!)
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        request.httpMethod = "GET"

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(key1, forHTTPHeaderField: "key1")

        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            do {
                if error != nil {
                    DispatchQueue.main.async {
                        completionHandler(nil)
                    }
                    return
                }
                
                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
                
                DispatchQueue.main.async {
                    completionHandler(jsonDict)
                }
            }
            catch {
                
            }
        })

        task.resume()
    }
    
    func logIp(server: Server, uuid: String, completionHandler: @escaping ([String: AnyObject]?) -> Void) {
        
        var request = URLRequest(url: URL(string: server.serviceAltUrl() + "api/v1/devices/\(uuid)/logip")!)
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        request.httpMethod = "GET"

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(key1, forHTTPHeaderField: "key1")

        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            do {
                if error != nil {
                    DispatchQueue.main.async {
                        completionHandler(nil)
                    }
                    return
                }
                
                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
                
                DispatchQueue.main.async {
                    completionHandler(jsonDict)
                }
            }
            catch {
                
            }
        })

        task.resume()
    }
    
    func banDeviceIps(server: Server, deviceId: Int, completionHandler: @escaping ([String: AnyObject]?) -> Void) {
        
        var request = URLRequest(url: URL(string: server.serviceAltUrl() + "api/v1/devices/\(deviceId)/ban")!)
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        request.httpMethod = "GET"

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(key1, forHTTPHeaderField: "key1")

        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            do {
                if error != nil {
                    DispatchQueue.main.async {
                        completionHandler(nil)
                    }
                    return
                }
                
                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
                
                DispatchQueue.main.async {
                    completionHandler(jsonDict)
                }
            }
            catch {
                
            }
        })

        task.resume()
    }
    
    func getPublicServers(completionHandler: @escaping ([Server]) -> Void) {
        var request = URLRequest(url: URL(string: serversUrl + "api/v1/serverlist")!)
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        
        request.httpMethod = "GET"

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            do {
                if error != nil {
                    DispatchQueue.main.async {
                        completionHandler([])
                    }
                    return
                }
                
                var code = 0
                if let httpReponse = response as? HTTPURLResponse {
                    code = httpReponse.statusCode
                    if code != 200 {
                        DispatchQueue.main.async {
                            completionHandler([])
                        }
                    }
                }
                
                let jsonArr = try JSONSerialization.jsonObject(with: data!, options: []) as! [[String: AnyObject]]
                
                DispatchQueue.main.async {
                    var servers = [Server]()
                    for jsonObj in jsonArr {
                        servers.append(Server(fromJson: jsonObj))
                    }
                    completionHandler(servers)
                }
            }
            catch {
                completionHandler([])
            }
        })

        task.resume()
    }
    
    /*func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }*/
}
