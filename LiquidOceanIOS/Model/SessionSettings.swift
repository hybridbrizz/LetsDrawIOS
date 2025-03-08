//
//  SessionSettings.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 2/10/21.
//  Copyright © 2021 Eric Versteeg. All rights reserved.
//

import Foundation
import UIKit

protocol PaintQtyDelegate {
    func notifyPaintQtyChanged(qty: Int)
}

protocol SceneDelegateDeleage {
    func sceneWillEnterForeground()
}

class SessionSettings: NSObject {

    static var instance = SessionSettings()
    
    var interactiveCanvas: InteractiveCanvas?
    var uniqueId: String = ""
    var deviceId: Int = 0
    
    var chunk1: [[Int32]]!
    var chunk2: [[Int32]]!
    var chunk3: [[Int32]]!
    var chunk4: [[Int32]]!
    
    var canvasSize: Int = 0
    var maxSend: Int = 0
    
    private var _dropsAmt: Int = 0
    var dropsAmt: Int! {
        get {
            return _dropsAmt
        }
        set {
            _dropsAmt = newValue
            for delegate in self.paintQtyDelegates {
                delegate.notifyPaintQtyChanged(qty: newValue)
            }
        }
    }
    
    var sentUniqueId: Bool!
    
    var paintColor: Int32!
    
    var maxPaintAmt = 1
    
    var darkIcons = false
    
    var backgroundColorIndex = 0
    
    var paintQtyDelegates = [PaintQtyDelegate]()
    
    var numRecentColors = 8
    
    var xp = 0
    
    var displayName = ""
    
    var artShowcase: [[InteractiveCanvas.RestorePoint]]?
    
    var showcaseIndex = 0
    
    var _googleAuth = false
    var googleAuth: Bool {
        set {
            changedGoogleAuth = true
            _googleAuth = newValue
        }
        get {
            return _googleAuth
        }
    }
    
    var changedGoogleAuth = false
    
    var nextPaintTime: Double!
    
    var timeSync: Double {
        set {
            nextPaintTime = Date().timeIntervalSince1970 + newValue
        }
        get {
            return 0
        }
    }
    
    var panelBackgroundName = ""
    
    var showGridLines = true
    
    var firstContributorName = ""
    var secondContributorName = ""
    var thirdContributorName = ""
    
    var paintIndicatorFill = false
    var paintIndicatorSquare = true
    var paintIndicatorOutline = true
    var paintIndicatorWidth = 4
    
    var gridLineColor: Int32 = Utils.int32FromColorHex(hex: "0xffffffff")
    
    var canvasBackgroundPrimaryColor: Int32 = Utils.int32FromColorHex(hex: "0xffffffff")
    var canvasBackgroundSecondaryColor: Int32 = Utils.int32FromColorHex(hex: "0xffffffff")
    
    var frameColor: Int32 = 0
    
    var paintPanelCloseButtonColor: Int32 = Utils.int32FromColorHex(hex: "0xffffffff")
    
    var promptBack = false
    
    var boldActionButtons = true
    
    var canvasLockBorder = false
    var canvasLockColor: Int32 = 0
    
    var showPaintBar = true
    var showPaintCircle = false
    
    var shortTermPixels = [InteractiveCanvas.ShortTermPixel]()
    
    var paintIndicatorColor: Int32 = -1
    
    var rightHanded = true
    var selectedHand = true
    
    var smallActionButtons = false
    
    var lockPaintPanel = true
    
    var pincodeSet = false
    
    var defaultBg = true
    
    var palettes = [Palette]()
    
    var restoreDeviceViewportCenterX: CGFloat = 0
    var restoreDeviceViewportCenterY: CGFloat = 0
    
    var restoreCanvasScaleFactor: CGFloat = 0
    
    private var _selectedPaletteIndex = 0
    var selectedPaletteIndex: Int {
        set {
            _selectedPaletteIndex = newValue
            palette = palettes[_selectedPaletteIndex]
        }
        get {
            return _selectedPaletteIndex
        }
    }
    
    var palette: Palette!
    
    var toolboxOpen = true
    var paintPanelOpen = false
    
    var canvasOpen = false
    
    var reloadCanvas = false
    var saveCanvas = false
    var replaceCanvas = false
    
    var colorPaletteSize = 4
    
    var servers: [Server] = []
    var lastVisitedServer: Server? = nil
    var lastVisitedServerId = -1
    
    var canvasPaused = false
    var canvasPauseTime = 0.0
    
    var banned = false
    
    var agreedToTermsOfService = false
    
    var sceneDelegateDelegate: SceneDelegateDeleage? = nil
    
    private var uniqueId2 = ""
    
    var publicServerUniqueIds = [String: String]()
    var publicServerLastVisitedTimes = [String: Double]()
    
    var onceResetColorSettings = true
    
    func save() {
        print("Save session settings")
        
        userDefaults().set(dropsAmt, forKey: "drops_amt")
        userDefaults().set(sentUniqueId, forKey: "sent_unique_id")
        userDefaults().set(paintColor, forKey: "paint_color")
        userDefaults().set(darkIcons, forKey: "dark_icons")
        userDefaults().set(backgroundColorIndex, forKey: "background_color")
        userDefaults().set(numRecentColors, forKey: "num_recent_colors")
        userDefaults().set(xp, forKey: "xp")
        userDefaults().set(displayName, forKey: "display_name")
        userDefaults().set(artShowcaseJsonString(), forKey: "art_showcase_json")
        userDefaults().set(googleAuth, forKey: "google_auth")
        userDefaults().set(panelBackgroundName, forKey: "panel_background")
        userDefaults().set(showGridLines, forKey: "show_grid_lines")
        userDefaults().set(paintIndicatorFill, forKey: "paint_indicator_fill")
        userDefaults().set(paintIndicatorSquare, forKey: "paint_indicator_square")
        userDefaults().set(paintIndicatorOutline, forKey: "paint_indicator_outline")
        userDefaults().set(paintIndicatorWidth, forKey: "paint_indicator_width")
        userDefaults().set(gridLineColor, forKey: "grid_line_color")
        userDefaults().set(canvasBackgroundPrimaryColor, forKey: "canvas_background_primary_color")
        userDefaults().set(canvasBackgroundSecondaryColor, forKey: "canvas_background_secondary_color")
        userDefaults().set(frameColor, forKey: "frame_color")
        userDefaults().set(paintPanelCloseButtonColor, forKey: "paint_panel_close_button_color")
        userDefaults().set(promptBack, forKey: "prompt_back")
        userDefaults().set(boldActionButtons, forKey: "bold_action_buttons")
        userDefaults().set(canvasLockBorder, forKey: "canvas_lock_border")
        userDefaults().set(canvasLockColor, forKey: "canvas_lock_color")
        userDefaults().set(showPaintBar, forKey: "show_paint_bar")
        userDefaults().set(showPaintCircle, forKey: "show_paint_circle")
        userDefaults().set(paintIndicatorColor, forKey: "paint_indicator_color")
        userDefaults().set(rightHanded, forKey: "right_handed")
        userDefaults().set(selectedHand, forKey: "selected_hand")
        userDefaults().set(smallActionButtons, forKey: "small_action_buttons")
        //userDefaults().set(lockPaintPanel, forKey: "lock_paint_panel")
        userDefaults().set(pincodeSet, forKey: "pincode_set")
        userDefaults().set(defaultBg, forKey: "default_bg")
        userDefaults().set(palettesJsonStr(), forKey: "palettes")
        userDefaults().set(selectedPaletteIndex, forKey: "selected_palette_index")
        userDefaults().set(toolboxOpen, forKey: "toolbox_open")
        userDefaults().set(paintPanelOpen, forKey: "paint_panel_open")
        userDefaults().set(canvasOpen, forKey: "canvas_open")
        userDefaults().set(colorPaletteSize, forKey: "palette_size")
        userDefaults().set(onceResetColorSettings, forKey: "once_reset_color_settings")
        
        let publicServerUniqueIdsStr = try! JSONSerialization.data(withJSONObject: publicServerUniqueIds, options: [])
        userDefaults().set(String(data: publicServerUniqueIdsStr, encoding: .utf8)!, forKey: "public_server_unique_ids")
        
        let publicServerLastVisitedStr = try! JSONSerialization.data(withJSONObject: publicServerLastVisitedTimes, options: [])
        userDefaults().set(String(data: publicServerLastVisitedStr, encoding: .utf8)!, forKey: "public_server_last_visited_times")
    }
    
    func quickSave() {
        userDefaults().set(sentUniqueId, forKey: "sent_unique_id")
        userDefaults().set(googleAuth, forKey: "google_auth")
        userDefaults().set(dropsAmt, forKey: "drops_amt")
        userDefaults().set(paintColor, forKey: "paint_color")
        userDefaults().set(backgroundColorIndex, forKey: "background_color")
        userDefaults().set(showGridLines, forKey: "show_grid_lines")
        userDefaults().set(rightHanded, forKey: "right_handed")
        userDefaults().set(selectedHand, forKey: "selected_hand")
        userDefaults().set(defaultBg, forKey: "default_bg")
    }
    
    func load() {
        sentUniqueId = userDefaultsBool(forKey: "sent_unique_id", defaultVal: false)
        
        paintColor = userDefaultsInt32(forKey: "paint_color", defaultVal: Utils.int32FromColorHex(hex: "0xFFFFFFFF"))
        
        darkIcons = userDefaultsBool(forKey: "dark_icons", defaultVal: false)
        
        backgroundColorIndex = userDefaultsInt(forKey: "background_color", defaultVal: 0)
        
        numRecentColors = userDefaultsInt(forKey: "num_recent_colors", defaultVal: 16)
        
        xp = userDefaultsInt(forKey: "xp", defaultVal: 0)
        
        displayName = userDefaultsString(forKey: "display_name", defaultVal: "")
        
        artShowcase = loadArtShowcase(jsonStr: userDefaultsString(forKey: "art_showcase_json", defaultVal: ""))
        
        googleAuth = userDefaultsBool(forKey: "google_auth", defaultVal: false)
        
        panelBackgroundName = userDefaultsString(forKey: "panel_background", defaultVal: "wood_texture_light.jpg")
        
        showGridLines = userDefaultsBool(forKey: "show_grid_lines", defaultVal: true)
        
        paintIndicatorFill = userDefaultsBool(forKey: "paint_indicator_fill", defaultVal: false)
        
        paintIndicatorSquare = userDefaultsBool(forKey: "paint_indicator_square", defaultVal: true)
        
        paintIndicatorOutline = userDefaultsBool(forKey: "paint_indicator_outline", defaultVal: false)
        
        paintIndicatorWidth = userDefaultsInt(forKey: "paint_indicator_width", defaultVal: 4)
        
        gridLineColor = userDefaultsInt32(forKey: "grid_line_color", defaultVal: 0)
        
        canvasBackgroundPrimaryColor = userDefaultsInt32(forKey: "canvas_background_primary_color", defaultVal: 0)
        
        canvasBackgroundSecondaryColor = userDefaultsInt32(forKey: "canvas_background_secondary_color", defaultVal: 0)
        
        frameColor = userDefaultsInt32(forKey: "frame_color", defaultVal: Utils.int32FromColorHex(hex: "0xFF999999"))
        
        paintPanelCloseButtonColor = userDefaultsInt32(forKey: "paint_panel_close_button_color", defaultVal: 0)
        
        promptBack = userDefaultsBool(forKey: "prompt_back", defaultVal: false)
        
        boldActionButtons = userDefaultsBool(forKey: "bold_action_buttons", defaultVal: true)
        
        canvasLockBorder = userDefaultsBool(forKey: "canvas_lock_border", defaultVal: false)
        
        canvasLockColor = userDefaultsInt32(forKey: "canvas_lock_color", defaultVal: Utils.int32FromColorHex(hex: "0x66FF0000"))
        
        showPaintBar = userDefaultsBool(forKey: "show_paint_bar", defaultVal: true)
        
        showPaintCircle = userDefaultsBool(forKey: "show_paint_circle", defaultVal: false)
        
        paintIndicatorColor = userDefaultsInt32(forKey: "paint_indicator_color", defaultVal: Utils.int32FromColorHex(hex: "0xffffffff"))
        
        rightHanded = userDefaultsBool(forKey: "right_handed", defaultVal: rightHanded)
        
        selectedHand = userDefaultsBool(forKey: "selected_hand", defaultVal: selectedHand)
        
        smallActionButtons = userDefaultsBool(forKey: "small_action_buttons", defaultVal: false)
        
        //lockPaintPanel = userDefaultsBool(forKey: "lock_paint_panel", defaultVal: false)
        
        pincodeSet = userDefaultsBool(forKey: "pincode_set", defaultVal: false)
        
        defaultBg = userDefaultsBool(forKey: "default_bg", defaultVal: true)
        
        palettes = palettesFromJsonString(jsonString: userDefaultsString(forKey: "palettes", defaultVal: "[]"))
        
        palettes.insert(Palette(name: "Recent Color"), at: 0)
        
        selectedPaletteIndex = userDefaultsInt(forKey: "selected_palette_index", defaultVal: 0)
        
        onceResetColorSettings = userDefaultsBool(forKey: "once_reset_color_settings", defaultVal: true)
        
        /*let palette = Palette(name: "Palette")
        palette.addColor(color: UIColor(hexString: "EACB6E").argb())
        palette.addColor(color: UIColor(hexString: "6385EA").argb())
        
        palettes.append(palette)*/
        
        toolboxOpen = userDefaultsBool(forKey: "toolbox_open", defaultVal: true)
        paintPanelOpen = userDefaultsBool(forKey: "paint_panel_open", defaultVal: false)
        
        canvasOpen = userDefaultsBool(forKey: "canvas_open", defaultVal: false)
        
        colorPaletteSize = userDefaultsInt(forKey: "palette_size", defaultVal: 4)
        
        agreedToTermsOfService = userDefaultsBool(forKey: "agreed_to_terms_of_service", defaultVal: false)
        
        initServerList()
        
        lastVisitedServerId = userDefaultsInt(forKey: "last_visited_server_id", defaultVal: -1)
        for server in servers {
            if server.uid == lastVisitedServerId {
                lastVisitedServer = server
                break
            }
        }
        
        let publicServerUniqueIdsStr = userDefaultsString(forKey: "public_server_unique_ids", defaultVal: "{}")
        publicServerUniqueIds = try! JSONSerialization.jsonObject(with: publicServerUniqueIdsStr.data(using: .utf8)!, options: []) as! [String: String]
        
        let publicServerLastVisitedStr = userDefaultsString(forKey: "public_server_last_visited_times", defaultVal: "{}")
        publicServerLastVisitedTimes = try! JSONSerialization.jsonObject(with: publicServerLastVisitedStr.data(using: .utf8)!, options: []) as! [String: Double]
    }
    
    func userDefaults() -> UserDefaults {
        return UserDefaults.standard
    }
    
    func userDefaultsHasKey(key: String) -> Bool {
        return userDefaults().object(forKey: key) != nil
    }
    
    func userDefaultsString(forKey: String, defaultVal: String) -> String {
        if userDefaultsHasKey(key: forKey) {
            return userDefaults().object(forKey: forKey) as! String
        }
        else {
            return defaultVal
        }
    }
    
    func userDefaultsBool(forKey: String, defaultVal: Bool) -> Bool {
        if userDefaultsHasKey(key: forKey) {
            return userDefaults().bool(forKey: forKey)
        }
        else {
            return defaultVal
        }
    }
    
    func userDefaultsInt(forKey: String, defaultVal: Int) -> Int {
        if userDefaultsHasKey(key: forKey) {
            return userDefaults().object(forKey: forKey) as! Int
        }
        else {
            return defaultVal
        }
    }
    
    func userDefaultsInt32(forKey: String, defaultVal: Int32) -> Int32 {
        if userDefaultsHasKey(key: forKey) {
            return userDefaults().object(forKey: forKey) as! Int32
        }
        else {
            return defaultVal
        }
    }
    
    func userDefaultsCGFloat(forKey: String, defaultVal: CGFloat) -> CGFloat {
        if userDefaultsHasKey(key: forKey) {
            return userDefaults().object(forKey: forKey) as! CGFloat
        }
        else {
            return defaultVal
        }
    }
    
    func addShortTermPixels(pixels: [InteractiveCanvas.ShortTermPixel]) {
        for pixel in pixels {
            shortTermPixels.append(pixel)
        }
    }
    
    func updateShortTermPixels() {
        shortTermPixels.removeAll(where: {
            Date().timeIntervalSince1970 - $0.time > 60 * 2
        })
    }
    
    // art showcase
    private func artShowcaseJsonString() -> String? {
        if let artShowcase = self.artShowcase {
            var ret = [[[String: Int32]]]()
            
            for i in artShowcase.indices {
                let art = artShowcase[i]
                
                var restorePoints = [[String: Int32]]()
                for j in art.indices {
                    let restorePoint = art[j]
                    var dict = [String: Int32]()
                    
                    dict["x"] = Int32(restorePoint.x)
                    dict["y"] = Int32(restorePoint.y)
                    dict["color"] = restorePoint.color
                    
                    restorePoints.append(dict)
                }
                
                ret.append(restorePoints)
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: ret, options: [])
                
                return String(data: jsonData, encoding: .utf8)
            }
            catch {
                
            }
        }
        
        return nil
    }
    
    func loadArtShowcase(jsonStr: String?) -> [[InteractiveCanvas.RestorePoint]]? {
        if let jsonStr = jsonStr {
            if jsonStr == "[null]" || jsonStr == "" {
                return nil
            }
            
            var showcase = [[InteractiveCanvas.RestorePoint]]()
            
            do {
                let jsonArray = try JSONSerialization.jsonObject(with: jsonStr.data(using: .utf8)!, options: []) as! [[[String: Int32]]]
                
                for i in jsonArray.indices {
                    let artJsonArray = jsonArray[i]
                    
                    var art = [InteractiveCanvas.RestorePoint]()
                    
                    for j in artJsonArray.indices {
                        let jsonObj = artJsonArray[j]
                        art.append(InteractiveCanvas.RestorePoint(x: Int(jsonObj["x"]!), y: Int(jsonObj["y"]!), color: jsonObj["color"]!, newColor: jsonObj["color"]!))
                    }
                    
                    showcase.append(art)
                }
                
                return showcase
            }
            catch {
                
            }
        }
        
        return nil
    }
    
    func addToShowcase(art: [InteractiveCanvas.RestorePoint]) {
        if artShowcase == nil {
            artShowcase = [[InteractiveCanvas.RestorePoint]]()
        }
        
        if artShowcase!.count < 10 {
            self.artShowcase!.append(art)
        }
        else {
            let rIndex = Int(arc4random() % UInt32(artShowcase!.count))
            artShowcase!.remove(at: rIndex)
            artShowcase!.insert(art, at: rIndex)
        }
    }
    
    func defaultArtShowcase() {
        SessionSettings.instance.addToShowcase(art: ArtView.artFromJsonFile(named: "leaf_json")!)
        SessionSettings.instance.addToShowcase(art: ArtView.artFromJsonFile(named: "doughnut_json")!)
        SessionSettings.instance.addToShowcase(art: ArtView.artFromJsonFile(named: "bird_json")!)
        SessionSettings.instance.addToShowcase(art: ArtView.artFromJsonFile(named: "hfs_json")!)
        SessionSettings.instance.addToShowcase(art: ArtView.artFromJsonFile(named: "paint_bucket_json")!)
        SessionSettings.instance.addToShowcase(art: ArtView.artFromJsonFile(named: "water_drop_json")!)
        //SessionSettings.instance.addToShowcase(art: ArtView.artFromJsonFile(named: "fire_badge_json")!)
        SessionSettings.instance.addToShowcase(art: ArtView.artFromJsonFile(named: "fries_json")!)
    }
    
    func addPalette(name: String) {
        palettes.append(Palette(name: name))
    }
    
    private func palettesJsonStr() -> String {
        var palettesArray = [[String: Any]]()
        
        var i = 0
        for palette in palettes {
            if i > 0 {
                palettesArray.append(palette.toDictionary())
            }
            
            i += 1
        }
        
        let jsonData = try! JSONSerialization.data(withJSONObject: palettesArray, options: [])
        
        return String(data: jsonData, encoding: .utf8)!
    }
    
    private func palettesFromJsonString(jsonString: String) -> [Palette] {
        var palettes = [Palette]()
        
        let jsonArray = try! JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!, options: []) as! [[String: Any]]
        
        for paletteJsonObj in jsonArray {
            let name = paletteJsonObj["name"] as! String
            let colors = paletteJsonObj["colors"] as! [Int32]
            
            let palette = Palette(name: name)
            
            for color in colors {
                palette.addColor(color: color)
            }
            
            palettes.append(palette)
        }
        
        return palettes
    }
    
    private func initServerList() {
        let jsonStr = userDefaultsString(forKey: "server_list_json", defaultVal: "[]")
        
        do {
            let jsonArray = try JSONSerialization.jsonObject(with: jsonStr.data(using: .utf8)!, options: []) as! [[String: AnyObject]]
            
            for jsonObj in jsonArray {
                let server = Server()
                
                server.uid = jsonObj["id"] as! Int
                server.name = jsonObj["name"] as! String
                server.color = jsonObj["color"] as! Int32
                server.baseUrl = jsonObj["base_url"] as! String
                server.pixelInterval = jsonObj["pixel_interval"] as! Int
                server.maxPixels = jsonObj["max_pixels"] as! Int
                server.isAdmin = jsonObj["is_admin"] as! Bool
                server.uuid = jsonObj["uuid"] as! String
                
                if server.isAdmin {
                    server.adminKey = jsonObj["admin_key"] as! String
                }
                else {
                    server.accessKey = jsonObj["access_key"] as! String
                }
                
                server.apiPort = jsonObj["api_port"] as! Int
                server.altPort = jsonObj["alt_port"] as! Int
                server.socketPort = jsonObj["socket_port"] as! Int
                server.queuePort = jsonObj["queue_port"] as! Int
                
                servers.append(server)
            }
        }
        catch {
            
        }
    }
    
    func addServer(server: Server) {
        servers.append(server)
        saveServers()
    }
    
    func removeServer(server: Server) {
        //let index = servers.firstIndex(of: server)!
        if lastVisitedServerId == server.uid {
            lastVisitedServerId = -1
            lastVisitedServer = nil
            userDefaults().set(-1, forKey: "last_visited_server_id")
        }
        servers.remove(at: servers.firstIndex(of: server)!)
        saveServers()
    }
    
    func hasServer(accessKey: String) -> Bool {
        for server in servers {
            if accessKey == server.adminKey || accessKey == server.accessKey {
                return true
            }
        }
        return false
    }
    
    func saveServers() {
        var jsonArray = [[String: Any]]()
        
        for server in servers {
            jsonArray.append(server.toDictionary())
        }
        
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonArray, options: [])
        
        userDefaults().set(String(data: jsonData, encoding: .utf8)!, forKey: "server_list_json")
    }
    
    func syncServerStatus(remoteServers: [Server]) {
        for server in servers {
            var remoteServer: Server? = nil
            for serverItem in remoteServers {
                if serverItem.uid == server.uid {
                    remoteServer = serverItem
                }
            }
            
            if remoteServer != nil {
                server.isOnline = remoteServer!.isOnline
                server.connectionCount = remoteServer!.connectionCount
                server.maxConnections = remoteServer!.maxConnections
                server.size = remoteServer!.size
            }
        }
        saveServers()
    }
    
    func adminServers() -> [Server] {
        var newList = [Server]()
        for server in servers {
            if server.isAdmin {
                newList.append(server)
            }
        }
        return newList
    }
    
    func privateServers() -> [Server] {
        var newList = [Server]()
        for server in servers {
            if !server.isAdmin {
                newList.append(server)
            }
        }
        return newList
    }
    
    func saveAgreedToTermsOfService() {
        userDefaults().set(agreedToTermsOfService, forKey: "agreed_to_terms_of_service")
    }
    
//    func saveDeviceViewport() {
//        userDefaults().set(restoreDeviceViewportCenterX, forKey: "restore_device_viewport_center_x")
//        userDefaults().set(restoreDeviceViewportCenterY, forKey: "restore_device_viewport_center_y")
//        userDefaults().set(restoreCanvasScaleFactor, forKey: "restore_canvas_scale_factor")
//    }
    
    func displayNameOrId() -> String {
        if displayName != "" {
            return displayName
        }
        else {
            return String(lastVisitedServer?.uuid.prefix(4) ?? UUID().uuidString.prefix(4))
        }
    }
}
