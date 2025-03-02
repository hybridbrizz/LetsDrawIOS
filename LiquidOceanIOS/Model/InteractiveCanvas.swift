//
//  InteractiveCanvas.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 2/10/21.
//  Copyright © 2021 Eric Versteeg. All rights reserved.
//

import UIKit
import SocketIO
import SwiftUI

protocol InteractiveCanvasDrawCallback: AnyObject {
    func notifyCanvasRedraw()
}

protocol InteractiveCanvasScaleCallback: AnyObject {
    func notifyScaleCancelled()
}

protocol InteractiveCanvasPixelHistoryDelegate: AnyObject {
    func notifyShowPixelHistory(data: [AnyObject], screenPoint: CGPoint)
    func notifyHidePixelHistory()
}

protocol InteractiveCanvasRecentColorsDelegate: AnyObject {
    func notifyNewRecentColors(recentColors: [Int32])
}

protocol InteractiveCanvasArtExportDelegate: AnyObject {
    func notifyArtExported(art: [InteractiveCanvas.RestorePoint])
}

protocol InteractiveCanvasSocketStatusDelegate: AnyObject {
    func notifySocketError()
}

protocol InteractiveCanvasDeviceViewportResetDelegate: AnyObject {
    func resetDeviceViewport()
}

protocol InteractiveCanvasSelectedObjectDelegate: AnyObject {
    func onObjectSelected()
    
    func onSelectedObjectMoveStart()
    func onSelectedObjectMoved()
    func onSelectedObjectMoveEnd()
}

protocol InteractiveCanvasEraseDelegate: AnyObject {
    func notifyErase(left: Int, top: Int, right: Int, bottom: Int)
}

protocol InteractiveCanvasSocketLatencyDelegate: AnyObject {
    func notifyLatency(latency: Int)
    func notifyConnectionCount(count: Int)
}

protocol InteractiveCanvasMenuDelegate: AnyObject {
    func notifyPersonListClicked()
    func notifyCommunityClicked()
    func notifyOptionsClicked()
    func notifyYankCanvasClicked()
    func notifyHelpClicked()
    func notifyLeaveClicked()
}

class InteractiveCanvas: NSObject, ObservableObject {
    var rows = 0
    var cols = 0
    
    var arr = [[Int32]]()
    var errorPixels = [ErrorPixel]()
    
    var basePpu = 100
    var ppu: Int!
    
    var gridLineThreshold = 9
    
    var deviceViewport: CGRect!
    
    var server: Server!
    
    private var _world: Bool = false
    var world: Bool {
        set {
            _world = newValue
            
            initType()
        }
        get {
            return _world
        }
    }
    
    var realmId = 0
    
    weak var drawCallback: InteractiveCanvasDrawCallback?
    weak var scaleCallback: InteractiveCanvasScaleCallback?
    weak var pixelHistoryDelegate: InteractiveCanvasPixelHistoryDelegate?
    weak var recentColorsDelegate: InteractiveCanvasRecentColorsDelegate?
    weak var artExportDelegate: InteractiveCanvasArtExportDelegate?
    weak var deviceViewportResetDelegate: InteractiveCanvasDeviceViewportResetDelegate?
    weak var selectedObjectDelegate: InteractiveCanvasSelectedObjectDelegate?
    weak var eraseDelegate: InteractiveCanvasEraseDelegate?
    weak var latencyDelegate: InteractiveCanvasSocketLatencyDelegate?
    
    var startScaleFactor = CGFloat(0.2)
    
    let minScaleFactor = CGFloat(0.07)
    let maxScaleFactor = CGFloat(7)
    
    var scaleFactor = CGFloat(0.2)
    
    var recentColors = [Int32]()
    
    static let backgroundBlack = 0
    static let backgroundWhite = 1
    static let backgroundGrayThirds = 2
    static let backgroundPhotoshop = 3
//    static let backgroundClassic = 4
//    static let backgroundChess = 5
    static let backgroundCustom = 4
    
    let numBackgrounds = 5
    
    var restorePoints =  [RestorePoint]()
    var pixelsOut: [RestorePoint]!
    
    var pendingUndos = [PendingUndo]()
    
    var receivedPaintRecently = false
    
    var summary = [RestorePoint]()
    
    var screenSpaceRect = CGRect()
    
    private var latencyTask: Task<(), any Error>? = nil
    var lastPingTime = 0.0
    
    var latency = -1
    var connectionCount = 0
    
    private var _selectedPixels: [RestorePoint]?
    var selectedPixels: [RestorePoint]? {
        set {
            _selectedPixels = newValue
            
            if newValue != nil {
                startSelectedPixels = copyPixels(pixels: _selectedPixels!)
            }
        }
        get {
            return _selectedPixels
        }
    }
    
    var startSelectedPixels: [RestorePoint]!
    
    var startSelectedStartUnit: CGPoint!
    var startSelectedEndUnit: CGPoint!
    
    var cSelectedStartUnit: CGPoint!
    var cSelectedEndUnit: CGPoint!
    
    private var mapMarkerModes = ["On", "Off", "Canvas Only", "Minimap Only"]
    
    @Published var clientsInfo = [ClientInfo]()
    @Published var mapMarkerMode = "On"
    
    @Published var showCanvasClientIndicators = true
    @Published var showSummaryClientIndicators = true
    
    enum Direction {
        case up
        case down
        case left
        case right
    }
    
    class ShortTermPixel {
        var restorePoint: RestorePoint
        var time: Double
        
        init(restorePoint: RestorePoint) {
            self.restorePoint = restorePoint
            self.time = Date().timeIntervalSince1970
        }
    }
    
    class RestorePoint {
        var x: Int
        var y: Int
        var color: Int32
        var newColor: Int32
        
        init(x: Int, y: Int, color: Int32, newColor: Int32) {
            self.x = x
            self.y = y
            self.color = color
            self.newColor = newColor
        }
    }
    
    static func importCanvasFromJson(jsonString: String) -> Bool {
        do {
            let jsonArray = try JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!, options: []) as! [[String: Any]]
            
            for i in 0...jsonArray.count - 1 {
                let jsonObject = jsonArray[i]
                
                let x = jsonObject["x"] as! Int
                let y = jsonObject["y"] as! Int
                
                let _ = jsonObject["color"] as! Int32
                
                if x < 0 || x > 1023 || y < 0 || y > 1023 {
                    return false
                }
            }
        }
        catch {
            return false
        }
        
        SessionSettings.instance.userDefaults().set(jsonString, forKey: "arr_canvas")
        return true
    }
    
    static func exportCanvasToJson(arr: [[Int32]]) -> String {
        if arr.count == 0 {
            return ""
        }
        
        let rows = arr.count
        let cols = arr[0].count
        
        var pixelList = [[String: Any]]()
        for y in 0...rows - 1 {
            for x in 0...cols - 1 {
                let color = arr[y][x]
                
                if color != 0 {
                    var dict = [String: Any]()
                    
                    dict["x"] = x
                    dict["y"] = y
                    dict["color"] = color
                    
                    pixelList.append(dict)
                }
            }
        }
        let data = try! JSONSerialization.data(withJSONObject: pixelList, options: [])
        
        return String(data: data, encoding: .utf8)!
    }
    
    override init() {
        super.init()
        
    }
    
    func initType() {
        if world {
            // world
            if realmId == 1 {
                rows = SessionSettings.instance.canvasSize
                cols = rows
                initChunkPixelsFromMemory()
            }
            // dev
            else {
                let dataJsonStr = SessionSettings.instance.userDefaults().object(forKey: "arr") as? String
                initPixels(arrJsonStr: dataJsonStr!)
            }
            
            registerForSocketEvents(socket: InteractiveCanvasSocket.instance.socket!)
        }
        // single play
        else {
            summary = [RestorePoint]()
            
            let dataJsonStr = SessionSettings.instance.userDefaults().object(forKey: "arr_canvas") as? String
            
            if dataJsonStr == nil {
                loadDefault()
            }
            else {
                initPixels(arrJsonStr: dataJsonStr!)
            }
        }
        
        // short term pixels
        for shortTermPixel in SessionSettings.instance.shortTermPixels {
            let x = shortTermPixel.restorePoint.x
            let y = shortTermPixel.restorePoint.y
            
            arr[y][x] = shortTermPixel.restorePoint.color
        }
        
        recentColors = [Int32]()
        
        let recentColorsJsonStr = SessionSettings.instance.userDefaultsString(forKey: "recent_colors", defaultVal: "")
        
        do {
            if recentColorsJsonStr != "" {
                let recentColorsArr = try JSONSerialization.jsonObject(with: recentColorsJsonStr.data(using: .utf8)!, options: []) as! [AnyObject]
                let sizeDiff = SessionSettings.instance.numRecentColors - recentColorsArr.count
                
                if sizeDiff < 0 {
                    for i in 0...SessionSettings.instance.numRecentColors - 1 {
                        self.recentColors.append(recentColorsArr[-sizeDiff + i] as! Int32)
                    }
                }
                else {
                    for i in 0...recentColorsArr.count - 1 {
                        self.recentColors.append(recentColorsArr[i] as! Int32)
                    }
                    
                    if sizeDiff > 0 {
                        let gridLineColor = self.getGridLineColor()
                        for _ in 0...sizeDiff - 1 {
                            self.recentColors.insert(gridLineColor, at: 0)
                        }
                    }
                }
            }
            else {
                let gridLineColor = self.getGridLineColor()
                for i in 0...SessionSettings.instance.numRecentColors - 1 {
                    // default to size - 1 of the grid line color
                    if i < SessionSettings.instance.numRecentColors - 1 {
                        if gridLineColor == ActionButtonView.blackColor {
                            self.recentColors.append(ActionButtonView.blackColor)
                        }
                        else {
                            self.recentColors.append(ActionButtonView.whiteColor)
                        }
                    }
                    // and 1 of the opposite color
                    else {
                        if gridLineColor == ActionButtonView.blackColor {
                            self.recentColors.append(ActionButtonView.whiteColor)
                        }
                        else {
                            self.recentColors.append(ActionButtonView.blackColor)
                        }
                    }
                }
            }
        }
        catch {
            
        }
    }
    
    func registerForSocketEvents(socket: SocketIOClient) {
        var shortTermPixels = [ShortTermPixel]()
        
        socket.on("pixels_commit") { (data, ack) in
//            let pixelsJsonArr = data[0] as! [[String: Any]]
//            
//            for pixelObj in pixelsJsonArr {
//                var sameRealm = false
//                
//                var unit1DIndex = (pixelObj["id"] as! Int) - 1
//                
//                if unit1DIndex < (512 * 512) && self.realmId == 2 {
//                    sameRealm = true
//                }
//                else if (unit1DIndex >= (512 * 512) && self.realmId == 1) {
//                    sameRealm = true
//                }
//                
//                if self.realmId == 1 {
//                    unit1DIndex -= (512 * 512)
//                }
//                
//                if (sameRealm) {
//                    let y = unit1DIndex / self.cols
//                    let x = unit1DIndex % self.cols
//                    
//                    let color = pixelObj["color"] as! Int32
//                    self.arr[y][x] = color
//                    
//                    shortTermPixels.append(ShortTermPixel(restorePoint: RestorePoint(x: x, y: y, color: color, newColor: color)))
//                }
//            }
//            
//            SessionSettings.instance.addShortTermPixels(pixels: shortTermPixels)
//            
//            self.drawCallback?.notifyCanvasRedraw()
        }
        
        socket.on("canvas_error") { (data, ack) in
            
        }
        
        socket.on("pixels_receive") { (data, ack) in
            self.receivePixels(pixelInfo: data[0] as! String)
        }
        
        socket.on("add_paint") { (data, ack) in
            let data = data[0] as! [String: Any]
            let amt = data["value"] as! Int
            SessionSettings.instance.dropsAmt += amt
            if SessionSettings.instance.dropsAmt > SessionSettings.instance.maxPaintAmt {
                SessionSettings.instance.dropsAmt = SessionSettings.instance.maxPaintAmt
            }
        }
        
        socket.on("res") { (data, ack) in
            let data = data[0] as! String
            let t = data[..<data.index(data.endIndex, offsetBy: -1)].components(separatedBy: "&")
            
            var connectionCount = 0
            
            var name = ""
            var center = -1
            
            var clientsInfo = [ClientInfo]()
            
            var i = 0
            for s in t {
                if i == 0 {
                    connectionCount = Int(s)!
                }
                else if i % 3 == 1 {
                    name = s
                }
                else if i % 3 == 2 {
                    center = Int(s)!
                }
                else {
                    clientsInfo.append(ClientInfo(name: name, color: Int32(exactly: Double(s)!)!, center: center))
                }
                
                i += 1
            }
            
            self.clientsInfo = clientsInfo
            
            let latency = Int(1000 * (NSDate().timeIntervalSince1970 - self.lastPingTime))
            self.latency = latency
            self.latencyDelegate?.notifyLatency(latency: latency)
            self.latencyDelegate?.notifyConnectionCount(count: connectionCount)
            
            print("latency check: got latency \(latency)")
        }
    }
    
    func receivePixels(pixelInfo: String) {
        var index = -1
        
        if self.pendingUndos.count >= 1 {
            for i in 0...self.pendingUndos.count - 1 {
                let pendingUndo = self.pendingUndos[i]
                if pendingUndo.message == pixelInfo {
                    index = i
                    break
                }
            }
            if index >= 0 {
                self.pendingUndos[index].cancel()
                self.pendingUndos.remove(at: index)
            }
        }
        
        let t = pixelInfo.components(separatedBy: "&")
        
        var pixelIds = [Int]()
        var colors = [Int32]()
        var deviceId = -1
        var key = ""
        
        for i in 0...t.count - 1 {
            if t.count % 2 == 0 && i == t.count - 1 {
                key = t[i]
                break
            }
            
            if i == 0 {
                deviceId = Int(t[i])!
            }
            else if i % 2 != 0 {
                pixelIds.append(Int(t[i])!)
            }
            else {
                colors.append(Int32(exactly: Int(t[i])!)!)
            }
        }
        
        if pixelIds.count != colors.count {
            return
        }
        
        for i in 0...pixelIds.count - 1 {
            let pixelId = pixelIds[i]
            let color = colors[i]
            
            let x = pixelId % cols
            let y = pixelId / cols
            
            print("Receive pixel: pixelId(\(pixelId)) = (\(x), \(y)")
            
            arr[y][x] = color
        }
        
        drawCallback?.notifyCanvasRedraw()
        
        print("Receive pixels: \(pixelInfo)")
    }
    
    func erasePixels(startUnit: CGPoint, endUnit: CGPoint) {
        let left = Int(startUnit.x)
        let top = Int(startUnit.y)
        let right = Int(endUnit.x)
        let bottom = Int(endUnit.y)
        
        eraseDelegate?.notifyErase(left: left, top: top, right: right, bottom: bottom)
    }
    
    func initPixels(arrJsonStr: String) {
        loadDefault()
        
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: arrJsonStr.data(using: .utf8)!, options: []) as? [[String: Any]] {
                
                if jsonArray.count > 0 {
                    for i in 0...jsonArray.count - 1 {
                        let jsonObject = jsonArray[i]
                        
                        let x = jsonObject["x"] as! Int
                        let y = jsonObject["y"] as! Int
                        
                        let color = jsonObject["color"] as! Int32
                        
                        arr[y][x] = color
                        
                        if color != 0 {
                            summary.append(RestorePoint(x: x, y: y, color: color, newColor: color))
                        }
                    }
                }
            }
        }
        catch {
            
        }
    }
    
    /*func initPixels(arrJsonStr: String) {
        do {
            if let outerArray = try JSONSerialization.jsonObject(with: arrJsonStr.data(using: .utf8)!, options: []) as? [Any] {
                
                for i in 0...outerArray.count - 1 {
                    let innerArr = outerArray[i] as! [Int32]
                    var arrRow = [Int32]()
                    var arrColorRow = [CGColor]()
                    for j in 0...innerArr.count - 1 {
                        let color = innerArr[j]
                        
                        if color != 0 {
                            summary.append(RestorePoint(x: j, y: i, color: color, newColor: color))
                        }
                        
                        arrRow.append(color)
                    }
                    arr.append(arrRow)
                }
            }
        }
        catch {
            
        }
    }*/
    
    func initChunkPixelsFromMemory() {
        var chunk = [[Int32]]()
        let chunkSize = cols / 4
        for i in 0...cols - 1 {
            var innerArr = [Int32]()
            if i < rows / 4 {
                chunk = SessionSettings.instance.chunk1
            }
            else if i < rows / 2 {
                chunk = SessionSettings.instance.chunk2
            }
            else if i < rows - (rows / 4) {
                chunk = SessionSettings.instance.chunk3
            }
            else {
                chunk = SessionSettings.instance.chunk4
            }
            
            for j in 0...rows - 1 {
                innerArr.append(chunk[i % chunkSize][j])
            }
            
            arr.append(innerArr)
        }
    }
    
    func loadDefault() {
        arr = [[Int32]]()
        for i in 0...rows - 1 {
            var innerArr = [Int32]()
            for j in 0...cols - 1 {
                innerArr.append(0)
            }
            
            arr.append(innerArr)
        }
    }
    
    func save() {
//        if world {
//            do {
//                SessionSettings.instance.userDefaults().set(try JSONSerialization.data(withJSONObject: arr, options: .fragmentsAllowed), forKey: "arr")
//            }
//            catch {
//                
//            }
//        }
//        else {
//            do {
//                SessionSettings.instance.userDefaults().set(InteractiveCanvas.exportCanvasToJson(arr: arr), forKey: "arr_canvas")
//            }
//            catch {
//                
//            }
//        }
    }
    
    func saveDeviceViewport() {
        SessionSettings.instance.restoreDeviceViewportCenterX = deviceViewport.origin.x + deviceViewport.width / 2
        SessionSettings.instance.restoreDeviceViewportCenterY = deviceViewport.origin.y + deviceViewport.height / 2
        
        SessionSettings.instance.restoreCanvasScaleFactor = scaleFactor
    }
    
    func isCanvas(unitPoint: CGPoint) -> Bool {
        return unitPoint.x >= 0 && unitPoint.y >= 0 && unitPoint.x < CGFloat(cols) && unitPoint.y < CGFloat(rows)
    }
    
    func isBackground(unitPoint: CGPoint) -> Bool {
        return unitPoint.x < 0 || unitPoint.y < 0 || unitPoint.x > CGFloat(cols - 1) || unitPoint.y > CGFloat(rows - 1) || arr[Int(unitPoint.y)][Int(unitPoint.x)] == 0
    }
    
    func paintUnitOrUndo(x: Int, y: Int, mode: Int = 0, redraw: Bool = true) {
        let restorePoint = unitInRestorePoints(x: x, y: y, restorePointsArr: self.restorePoints)
        
        if mode == 0 {
            if restorePoint == nil && (SessionSettings.instance.dropsAmt > 0 && restorePoints.count < SessionSettings.instance.maxSend || !world) {
                if x > -1 && x < cols && y > -1 && y < rows {
                    let unitColor = arr[y][x]
                    
                    if SessionSettings.instance.paintColor != unitColor {
                        // paint
                        restorePoints.append(RestorePoint(x: x, y: y, color: arr[y][x], newColor: SessionSettings.instance.paintColor!))
                        
                        arr[y][x] = SessionSettings.instance.paintColor
                        
                        SessionSettings.instance.dropsAmt -= 1
                    }
                }
                else {
                    self.addErrorPixel(x: x, y: y)
                }
            }
            else if SessionSettings.instance.dropsAmt == 0 || restorePoints.count >= SessionSettings.instance.maxSend {
                self.addErrorPixel(x: x, y: y)
            }
        }
        else if mode == 1 {
            if restorePoint != nil {
                let index = restorePoints.firstIndex{$0 === restorePoint}
                
                if index != nil {
                    restorePoints.remove(at: index!)
                    arr[y][x] = restorePoint!.color
                    
                    SessionSettings.instance.dropsAmt += 1
                }
            }
        }
        
        if redraw {
            drawCallback?.notifyCanvasRedraw()
        }
    }
    
    private func addErrorPixel(x: Int, y: Int) {
        if self.errorPixels.first(where: { pixel in
            pixel.x == x && pixel.y == y
        }) == nil {
            self.errorPixels.append(ErrorPixel(x: x, y: y, duration: 0.65))
        }
    }
    
    func commitPixels() {
        if world {
            var xs = [Int]()
            var ys = [Int]()
            var colors = [Int32]()
            
            for restorePoint in self.restorePoints {
                xs.append(restorePoint.x)
                ys.append(restorePoint.y)
                colors.append(restorePoint.newColor)
            }
            
            print("emit pixels")
            let sendStr = buildPixelsString(xs: xs, ys: ys, deviceId: SessionSettings.instance.deviceId, colors: colors)
            InteractiveCanvasSocket.instance.socket!.emit("pixels_send", sendStr, completion: nil)
            
            var rpCopy = [RestorePoint]()
            for restorePoint in self.restorePoints {
                rpCopy.append(restorePoint)
            }
            
            self.pendingUndos.append(PendingUndo(restorePoints: rpCopy, message: sendStr, onUndo: { rps in
                for rp in rps {
                    self.arr[rp.y][rp.x] = rp.color
                }
                self.drawCallback?.notifyCanvasRedraw()
            }))
            
            //StatTracker.instance.reportEvent(eventType: .pixelPaintedWorld, amt: restorePoints.count)
        }
        else {
            //StatTracker.instance.reportEvent(eventType: .pixelPaintedSingle, amt: restorePoints.count)
            for restorePoint in restorePoints {
                summary.append(RestorePoint(x: restorePoint.x, y: restorePoint.y, color: restorePoint.newColor, newColor: restorePoint.newColor))
            }
            
        }
        
        updateRecentColors()
        self.recentColorsDelegate?.notifyNewRecentColors(recentColors: self.recentColors)
    }
    
    func buildPixelsString(xs: [Int], ys: [Int], deviceId: Int, colors: [Int32]) -> String {
        var str = "\(deviceId)"
        
        for i in 0...colors.count - 1 {
            let x = xs[i]
            let y = ys[i]
            let color = colors[i]
            
            let pixelId = y * cols + x
            str += "&\(pixelId)&\(color)"
        }
        
        if server.isAdmin {
            str += "&\(server.adminKey)"
        }
        
        return str
    }
    
    func updateRecentColors() {
        var colorIndex = -1
        for restorePoint in self.restorePoints {
            var contains = false
            for i in 0...recentColors.count - 1 {
                if restorePoint.newColor == self.recentColors[i] {
                    contains = true
                    colorIndex = i
                }
            }
            if !contains {
                if self.recentColors.count == SessionSettings.instance.numRecentColors {
                    recentColors.remove(at: 0)
                }
                self.recentColors.append(restorePoint.newColor)
            }
            else {
                self.recentColors.remove(at: colorIndex)
                self.recentColors.append(restorePoint.newColor)
            }
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: self.recentColors, options: [])
            let str = String(data: data, encoding: .utf8)
            
            SessionSettings.instance.userDefaults().set(str, forKey: "recent_colors")
        }
        catch {
            
        }
    }
    
    func getGridLineColor() -> Int32 {
        if SessionSettings.instance.gridLineColor != 0 {
            return SessionSettings.instance.gridLineColor
        }
        else {
            let white = Utils.int32FromColorHex(hex: "0xFFFFFFFF")
            let black = Utils.int32FromColorHex(hex: "0xFF000000")
            switch SessionSettings.instance.backgroundColorIndex {
                case InteractiveCanvas.backgroundWhite:
                    return black
                case InteractiveCanvas.backgroundPhotoshop:
                    return black
                default:
                    return white
            }
        }
    }
    
    func getBackgroundColors(index: Int) -> (primary: Int32, secondary: Int32)? {
        switch index {
            case InteractiveCanvas.backgroundBlack:
                return (Utils.int32FromColorHex(hex: "0xFF000000"), Utils.int32FromColorHex(hex: "0xFF000000"))
            case InteractiveCanvas.backgroundWhite:
                return (Utils.int32FromColorHex(hex: "0xFFFFFFFF"), Utils.int32FromColorHex(hex: "0xFFFFFFFF"))
            case InteractiveCanvas.backgroundGrayThirds:
                return (Utils.int32FromColorHex(hex: "0xFFAAAAAA"), Utils.int32FromColorHex(hex: "0xFF555555"))
            case InteractiveCanvas.backgroundPhotoshop:
                return (Utils.int32FromColorHex(hex: "0xFFFFFFFF"), Utils.int32FromColorHex(hex: "0xFFCCCCCC"))
//            case InteractiveCanvas.backgroundClassic:
//                return (Utils.int32FromColorHex(hex: "0xFF666666"), Utils.int32FromColorHex(hex: "0xFF333333"))
//            case InteractiveCanvas.backgroundChess:
//                return (Utils.int32FromColorHex(hex: "0xFFB59870"), Utils.int32FromColorHex(hex: "0xFF000000"))
            case InteractiveCanvas.backgroundCustom:
            return (SessionSettings.instance.canvasBackgroundPrimaryColor, SessionSettings.instance.canvasBackgroundSecondaryColor)
            default:
                return nil
        }
    }
    
    func getPixelHistoryForUnitPoint(unitPoint: CGPoint, completionHandler: @escaping (Bool, [AnyObject]) -> Void) {
        let x = Int(unitPoint.x)
        let y = Int(unitPoint.y)
        
        var pixelId = y * cols + x
        
        URLSessionHandler.instance.downloadPixelHistory(server: server, pixelId: pixelId, completionHandler: completionHandler)
    }
    
    // restore points
    
    func undoPendingPaint() {
        for restorePoint: RestorePoint in restorePoints {
            arr[restorePoint.y][restorePoint.x] = restorePoint.color
        }
    }
    
    func clearRestorePoints() {
        self.restorePoints = [RestorePoint]()
    }
    
    func unitInRestorePoints(x: Int, y: Int, restorePointsArr: [RestorePoint]) -> RestorePoint? {
        for restorePoint in restorePointsArr {
            if restorePoint.x == x && restorePoint.y == y {
                return restorePoint
            }
        }
        
        return nil
    }
    
    // object move
    func startMoveSelection(startUnit: CGPoint, endUnit: CGPoint) -> Bool {
        if !isCanvas(unitPoint: startUnit) || !isCanvas(unitPoint: endUnit) {
            return false
        }
        
        let pixels = getPixels(startUnit: startUnit, endUnit: endUnit)
        if pixels.isEmpty {
            return false
        }
        
        selectedPixels = pixels
        
        let startAndEndUnits = getStartAndEndUnits(pixels: selectedPixels!)
        
        startSelectedStartUnit = startAndEndUnits.start
        cSelectedStartUnit = CGPoint(x: startSelectedStartUnit.x, y: startSelectedStartUnit.y)
        
        startSelectedEndUnit = startAndEndUnits.end
        cSelectedEndUnit = CGPoint(x: startSelectedEndUnit.x, y: startSelectedEndUnit.y)
        
        selectedObjectDelegate?.onObjectSelected()
        selectedObjectDelegate?.onSelectedObjectMoveStart()
        
        drawCallback?.notifyCanvasRedraw()
        
        return true
    }
    
    func startMoveSelection(unitPoint: CGPoint) -> Bool {
        if !isCanvas(unitPoint: unitPoint) {
            return false
        }
        
        let pixels = getPixelsInForm(unitPoint: unitPoint)
        if pixels.isEmpty {
            return false
        }
        
        selectedPixels = pixels
        
        let startAndEndUnits = getStartAndEndUnits(pixels: selectedPixels!)
        
        startSelectedStartUnit = startAndEndUnits.start
        cSelectedStartUnit = CGPoint(x: startSelectedStartUnit.x, y: startSelectedStartUnit.y)
        
        startSelectedEndUnit = startAndEndUnits.end
        cSelectedEndUnit = CGPoint(x: startSelectedEndUnit.x, y: startSelectedEndUnit.y)
        
        selectedObjectDelegate?.onObjectSelected()
        selectedObjectDelegate?.onSelectedObjectMoveStart()
        
        drawCallback?.notifyCanvasRedraw()
        
        return true
    }
    
    func moveSelection(direction: Direction) {
        if (selectedPixels != nil) {
            let selectedPixels = selectedPixels!
            let moved = movePixels(pixels: selectedPixels, direction: direction)
            
            if moved {
                selectedObjectDelegate?.onSelectedObjectMoved()
                drawCallback?.notifyCanvasRedraw()
            }
        }
    }
    
    func endMoveSelection(confirm: Bool) {
        if confirm {
            for pixel in startSelectedPixels {
                let x = pixel.x
                let y = pixel.y
                
                arr[y][x] = 0
            }
            
            if selectedPixels != nil {
                let selectedPixels = selectedPixels!
                for pixel in selectedPixels {
                    let x = pixel.x
                    let y = pixel.y
                    
                    arr[y][x] = pixel.color
                }
            }
        }
        
        selectedPixels = nil
        
        selectedObjectDelegate?.onSelectedObjectMoveEnd()
        drawCallback?.notifyCanvasRedraw()
    }
    
    func cancelMoveSelectedObject() {
        endMoveSelection(confirm: false)
    }
    
    func hasSelectedObjectMoved() -> Bool {
        return startSelectedStartUnit.x != cSelectedStartUnit.x || startSelectedStartUnit.y != cSelectedStartUnit.y
    }
    
    func movePixels(pixels: [RestorePoint], direction: Direction) -> Bool {
        // check bounds
        for pixel in pixels {
            let x = pixel.x
            let y = pixel.y
            
            switch direction {
                case .up:
                    if y < 1 {
                        return false
                    }
                case .down:
                    if y > rows - 2 {
                        return false
                    }
                case .left:
                    if x < 1 {
                        return false
                    }
                case .right:
                    if x > cols - 2 {
                        return false
                    }
            }
        }
        
        // move pixels
        for pixel in pixels {
            switch direction {
                case .up:
                    pixel.y -= 1
                    break
                case .down:
                    pixel.y += 1
                    break
                case .left:
                    pixel.x -= 1
                    break
                case .right:
                    pixel.x += 1
                    break
            }
        }
        
        switch direction {
            case .up:
                cSelectedStartUnit.y -= 1
                cSelectedEndUnit.y -= 1
                break
            case .down:
                cSelectedStartUnit.y += 1
                cSelectedEndUnit.y += 1
                break
            case .left:
                cSelectedStartUnit.x -= 1
                cSelectedEndUnit.x -= 1
                break
            case .right:
                cSelectedStartUnit.x += 1
                cSelectedEndUnit.x += 1
                break
        }
        
        return true
    }
    
    // export
    func exportSelection(startUnit: CGPoint, endUnit: CGPoint) {
        if !isCanvas(unitPoint: startUnit) || !isCanvas(unitPoint: endUnit) {
            return
        }
        
        artExportDelegate?.notifyArtExported(art: getPixels(startUnit: startUnit, endUnit: endUnit))
    }
    
    func exportSelection(unitPoint: CGPoint) {
        if !isCanvas(unitPoint: unitPoint) {
            return
        }
        
        self.artExportDelegate?.notifyArtExported(art: getPixelsInForm(unitPoint: unitPoint))
    }
    
    func getPixels(startUnit: CGPoint, endUnit: CGPoint) -> [RestorePoint] {
        var pixelsOut = [RestorePoint]()
        
        var numLeadingCols = 0
        var numTrailingCols = 0
        
        var numLeadingRows = 0
        var numTrailingRows = 0
        
        let startX = Int(startUnit.x)
        let startY = Int(startUnit.y)
        
        let endX  = Int(endUnit.x)
        let endY = Int(endUnit.y)
        
        var before = true
        for x in startX...endX {
            var clear = true
            for y in startY...endY {
                if arr[y][x] != 0 {
                    clear = false
                    before = false
                }
            }
            
            if clear && before {
                numLeadingCols += 1
            }
        }
        
        before = true
        for xi in startX...endX {
            let x = (endX - xi) + startX
            var clear = true
            for y in startY...endY {
                if arr[y][x] != 0 {
                    clear = false
                    before = false
                }
            }
            
            if clear && before {
                numTrailingCols += 1
            }
        }
        
        before = true
        for y in startY...endY {
            var clear = true
            for x in startX...endX {
                if arr[y][x] != 0 {
                    clear = false
                    before = false
                }
            }
            
            if clear && before {
                numLeadingRows += 1
            }
        }
        
        before = true
        for yi in startY...endY {
            let y = (endY - yi) + startY
            var clear = true
            for x in startX...endX {
                if arr[y][x] != 0 {
                    clear = false
                    before = false
                }
            }
            
            if clear && before {
                numTrailingRows += 1
            }
        }
        
        if (endX - numTrailingCols) < (startX + numLeadingCols) || (endY - numTrailingRows) < (startY + numLeadingRows) {
            return pixelsOut
        }
        
        for x in (startX + numLeadingCols)...(endX - numTrailingCols) {
            for y in (startY + numLeadingRows)...(endY - numTrailingRows) {
                pixelsOut.append(RestorePoint(x: x, y: y, color: arr[y][x], newColor: arr[y][x]))
            }
        }
        
        return pixelsOut
    }
    
    func getStartAndEndUnits(pixels: [RestorePoint]) -> (start: CGPoint, end: CGPoint) {
        var minX = CGFloat(cols)
        var maxX: CGFloat = -1
        var minY = CGFloat(rows)
        var maxY: CGFloat = -1
        
        for pixel in pixels {
            let x = CGFloat(pixel.x)
            let y = CGFloat(pixel.y)
            
            if x < minX {
                minX = x
            }
            if x > maxX {
                maxX = x
            }
            if y < minY {
                minY = y
            }
            if y > maxY {
                maxY = y
            }
        }
        
        return (CGPoint(x: minX, y: minY), CGPoint(x: maxX, y: maxY))
    }
    
    private func getPixelsInForm(unitPoint: CGPoint) -> [RestorePoint] {
        pixelsOut = [RestorePoint]()
        stepPixelsInForm(x: Int(unitPoint.x), y: Int(unitPoint.y), depth: 0)
        
        return pixelsOut
    }
    
    private func stepPixelsInForm(x: Int, y: Int, depth: Int) {
        // a background color
        // or already in list
        // or out of bounds
        if x < 0 || x > cols - 1 || y < 0 || y > rows - 1 || arr[y][x] == 0 || unitInRestorePoints(x: x, y: y, restorePointsArr: pixelsOut) != nil || depth > 10000 {
            return
        }
        else {
            pixelsOut.append(RestorePoint(x: x, y: y, color: arr[y][x], newColor: arr[y][x]))
        }
        
        // left
        stepPixelsInForm(x: x - 1, y: y, depth: depth + 1)
        // top
        stepPixelsInForm(x: x, y: y - 1, depth: depth + 1)
        // right
        stepPixelsInForm(x: x + 1, y: y, depth: depth + 1)
        // bottom
        stepPixelsInForm(x: x, y: y + 1, depth: depth + 1)
        // top-left
        stepPixelsInForm(x: x - 1, y: y - 1, depth: depth + 1)
        // top-right
        stepPixelsInForm(x: x + 1, y: y - 1, depth: depth + 1)
        // bottom-left
        stepPixelsInForm(x: x - 1, y: y + 1, depth: depth + 1)
        // bottom-right
        stepPixelsInForm(x: x + 1, y: y + 1, depth: depth + 1)
        
    }
    
    func copyPixels(pixels: [RestorePoint]) -> [RestorePoint] {
        var pixelsCopy = [RestorePoint]()
        
        for pixel in pixels {
            pixelsCopy.append(RestorePoint(x: pixel.x, y: pixel.y, color: pixel.color, newColor: pixel.newColor))
        }
        
        return pixelsCopy
    }
    
    func reload() {
        initType()
    }
    
    func notifyDeviceViewportUpdate() {
        if selectedPixels != nil {
            selectedObjectDelegate?.onSelectedObjectMoved()
        }
    }
    
    func updateDeviceViewport(screenSize: CGSize, fromScale: Bool = false) {
        updateDeviceViewport(screenSize: screenSize, canvasCenterX: deviceViewport.origin.x + deviceViewport.size.width / 2, canvasCenterY: deviceViewport.origin.y + deviceViewport.size.height / 2, fromScale: fromScale)
    }
    
    func updateDeviceViewport(screenSize: CGSize, canvasCenterX: CGFloat, canvasCenterY: CGFloat, fromScale: Bool = false) {
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        let canvasCenterXPx = Int((canvasCenterX * CGFloat(ppu)))
        let canvasCenterYPx = Int((canvasCenterY * CGFloat(ppu)))
        
        let canvasTop = canvasCenterYPx - Int(screenHeight) / 2
        let canvasBottom = canvasCenterYPx + Int(screenHeight) / 2
        let canvasLeft = canvasCenterXPx - Int(screenWidth) / 2
        let canvasRight = canvasCenterXPx + Int(screenWidth) / 2
        
        let top = CGFloat(canvasTop) / CGFloat(ppu)
        let bottom = CGFloat(canvasBottom) / CGFloat(ppu)
        let left = CGFloat(canvasLeft) / CGFloat(ppu)
        let right = CGFloat(canvasRight) / CGFloat(ppu)
        
        if (top < 0.0 || bottom > CGFloat(rows) || CGFloat(left) < 0.0 || right > CGFloat(cols)) {
            if (fromScale) {
                self.scaleCallback?.notifyScaleCancelled()
                return
            }
        }
        
        deviceViewport = CGRect(x: left, y: top, width: (right - left), height: (bottom - top))
        
        let w = right - left
        let h = bottom - top
        
        // error! reset the canvas viewport
        if w <= 0 || h <= 0 {
            deviceViewportResetDelegate?.resetDeviceViewport()
        }
        
        if fromScale {
            // selected object
            if selectedPixels != nil {
                selectedObjectDelegate?.onSelectedObjectMoved()
            }
        }
    }
    
    func getScreenSpaceForUnit(x: Int, y: Int) -> CGRect {
        let offsetX = (CGFloat(x) - deviceViewport.origin.x) * CGFloat(ppu)
        let offsetY = (CGFloat(y) - deviceViewport.origin.y) * CGFloat(ppu)
        
        screenSpaceRect.origin.x = round(offsetX)
        screenSpaceRect.origin.y = round(offsetY)
        screenSpaceRect.size.width = round(CGFloat(ppu)) + 1
        screenSpaceRect.size.height = round(CGFloat(ppu)) + 1
        
        return screenSpaceRect
    }
    
    func unitForScreenPoint(x: CGFloat, y: CGFloat) -> CGPoint {
        let topViewportPx = deviceViewport.origin.y * CGFloat(ppu)
        let leftViewportPx = deviceViewport.origin.x * CGFloat(ppu)
        
        let absXPx = leftViewportPx + x
        let absYPx = topViewportPx + y
        
        let absX = absXPx / CGFloat(ppu)
        let absY = absYPx / CGFloat(ppu)
        
        return CGPoint(x: floor(absX), y: floor(absY))
    }
    
    func screenPointForUnit(unitPoint: CGPoint) -> CGPoint {
        let topViewportPx = deviceViewport.origin.y * CGFloat(ppu)
        let leftViewportPx = deviceViewport.origin.x * CGFloat(ppu)
        
        let absXPx = unitPoint.x * CGFloat(ppu)
        let absYPx = unitPoint.y * CGFloat(ppu)
        
        return CGPoint(x: absXPx - leftViewportPx, y: absYPx - topViewportPx)
    }
    
//    fun jumpToUnit(context: Context, x: Int, y: Int) {
//            deviceViewport?.let {
//                val cvX = it.centerX()
//                val cvY = it.centerY()
//
//                translateBy(
//                    context = context,
//                    x = (x - cvX) * ppu,
//                    y = (y - cvY) * ppu
//                )
//            }
//        }
    
    func jumpToUnit(x: CGFloat, y: CGFloat) {
        let cMidX = deviceViewport.midX
        let cMidY = deviceViewport.midY
        
        translateBy(x: (x - cMidX) * CGFloat(ppu), y: (y - cMidY) * CGFloat(ppu))
    }
    
    func translateBy(x: CGFloat, y: CGFloat) {
        let margin = CGFloat(200) / CGFloat(ppu)
        
        var dX = x / CGFloat(ppu)
        var dY = y / CGFloat(ppu)
        
        var left = deviceViewport.origin.x
        var top = deviceViewport.origin.y
        var right = left + deviceViewport.size.width
        var bottom = top + deviceViewport.size.height
        
        left += dX
        right += dX
        top += dY
        bottom += dY
        
        var cX: CGFloat = 0
        var cY: CGFloat = 0
        
        let cw = CGFloat(cols)
        let ch = CGFloat(rows)
        
        // boundary check
        let leftBound = -margin
        let rightBound = cw + margin
        let topBound = -margin
        let bottomBound = ch + margin
        
        if left < leftBound {
            cX = leftBound - left
        }
        if top < topBound {
            cY = topBound - top
        }
        if right > rightBound  {
            cX = rightBound - right
        }
        if bottom > bottomBound {
            cY = bottomBound - bottom
        }
        
        deviceViewport = CGRect(x: left, y: top, width: right - left, height: bottom - top)
        
        if cX != CGFloat(0) {
            deviceViewport.origin.x += cX
        }
        
        if cY != CGFloat(0) {
            deviceViewport.origin.y += cY
        }
        
        let w = right - left
        let h = bottom - top
        
        // error! reset the canvas viewport
        if w <= 0 || h <= 0 {
            deviceViewportResetDelegate?.resetDeviceViewport()
        }
        
        // selected object
        if selectedPixels != nil {
            selectedObjectDelegate?.onSelectedObjectMoved()
        }
        
        drawCallback?.notifyCanvasRedraw()
    }
    
    func startLatencyTask() {
        if self.latencyTask != nil {
            return
        }
        
        self.latencyTask = Task {
            while !Task.isCancelled {
                print("Sending latency check")
                
                InteractiveCanvasSocket.instance.socket?.emit("lat", "\(SessionSettings.instance.displayNameOrId())&\(pixelId(x: self.deviceViewport.midX, y: deviceViewport.midY))")
                self.lastPingTime = NSDate().timeIntervalSince1970
                try await Task.sleep(for: .milliseconds(4200))
            }
        }
    }
    
    func cancelLatencyTask() {
        self.latencyTask?.cancel()
        self.latencyTask = nil
    }
    
    func pixelId(x: CGFloat, y: CGFloat) -> Int {
        return Int(y) * cols + Int(x)
    }
    
    func switchToNextMapMarkerMode() {
        var index = -1
        for i in 0..<mapMarkerMode.count {
            let mode = mapMarkerModes[i]
            if mode == mapMarkerMode {
                index = i
                break
            }
        }
        
        let nextIndex = (index + 1) % mapMarkerModes.count
        mapMarkerMode = mapMarkerModes[nextIndex]
        
        if nextIndex == 0 {
            showCanvasClientIndicators = true
            showSummaryClientIndicators = true
        }
        else if nextIndex == 1 {
            showCanvasClientIndicators = false
            showSummaryClientIndicators = false
        }
        else if nextIndex == 2 {
            showCanvasClientIndicators = true
            showSummaryClientIndicators = false
        }
        else if nextIndex == 3 {
            showCanvasClientIndicators = false
            showSummaryClientIndicators = true
        }
    }
}
