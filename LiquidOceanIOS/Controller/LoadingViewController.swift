//
//  LoadingViewController.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 2/10/21.
//  Copyright © 2021 Eric Versteeg. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher

class LoadingViewController: UIViewController, InteractiveCanvasSocketConnectionDelegate, QueueSocketDelegate {

    var server: Server!
    
    var showInteractiveCanvas = "ShowInteractiveCanvas"
    let showTermsOfService = "ShowTermsOfService"
    
    @IBOutlet var connectingLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    
    @IBOutlet weak var dotsLabel: UILabel!
    @IBOutlet weak var gameTipLabel: UILabel!
    
    @IBOutlet weak var queuePosLabel: UILabel!
    
    @IBOutlet weak var connectingLabelWidth: NSLayoutConstraint!
    
    @IBOutlet weak var artView: ArtView!
    
    @IBOutlet weak var canvasImage: UIImageView!
    @IBOutlet weak var iconImage: UIImageView!
    
    @IBOutlet weak var topContributorName1: UILabel!
    @IBOutlet weak var topContributorName2: UILabel!
    @IBOutlet weak var topContributorName3: UILabel!
    @IBOutlet weak var topContributorName4: UILabel!
    @IBOutlet weak var topContributorName5: UILabel!
    @IBOutlet weak var topContributorName6: UILabel!
    @IBOutlet weak var topContributorName7: UILabel!
    @IBOutlet weak var topContributorName8: UILabel!
    @IBOutlet weak var topContributorName9: UILabel!
    @IBOutlet weak var topContributorName10: UILabel!
    
    @IBOutlet weak var topContributorAmt1: UILabel!
    @IBOutlet weak var topContributorAmt2: UILabel!
    @IBOutlet weak var topContributorAmt3: UILabel!
    @IBOutlet weak var topContributorAmt4: UILabel!
    @IBOutlet weak var topContributorAmt5: UILabel!
    @IBOutlet weak var topContributorAmt6: UILabel!
    @IBOutlet weak var topContributorAmt7: UILabel!
    @IBOutlet weak var topContributorAmt8: UILabel!
    @IBOutlet weak var topContributorAmt9: UILabel!
    @IBOutlet weak var topContributorAmt10: UILabel!
    
    let gameTips = ["You can customize canvas background colors and other various things in Settings.",
                    "All drawings can be exported. Simply choose the export tool, tap on an object, then select share or save.",
                    "Anything you create on the canvas is shared in real time with others.",
                    "Tap on any pixel on the canvas to view a history of edits.",
                    "No harassment, racism, or hate symbols are allowed on the canvas.",
                    "Anyone can get pixels to draw on the canvas in 3 minutes or less! Simply wait for the next paint cycle.",
                    "Tap the palette icon to show and select from recently used colors."]
    
    var errorTypeServer = "server"
    var errorTypeSocket = "socket"
    var errorTypeQueue = "queue"
    var errorTypeAccessKey = "access-key"
    var errorTypeBan = "ban"
    
    var doneLoadingPixels = false
    var doneSyncDevice = false
    var doneLoadingTopContributors = false
    
    var doneLoadingChunk1 = false
    var doneLoadingChunk2 = false
    var doneLoadingChunk3 = false
    var doneLoadingChunk4 = false
    
    var doneConnectingSocket = false
    var doneConnectingQueue = false
    
    var doneCheckingIp = false
    
    var timer: Timer!
    var lastDotsStr = ""
    
    var realmId = 0
    
    var showingError = false
    
    var queuePos = 0
    var queuePosTimer: Timer? = nil
    
    var lockToLandscape = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if server!.isAdmin {
            self.connectingLabel.text = "Connecting to \(server!.name) (Mod)"
        }
        else {
            self.connectingLabel.text = "Connecting to \(server!.name)"
        }
        
        if server!.color != 0 {
            self.connectingLabel.textColor = UIColor(argb: server!.color)
        }
        
        realmId = 1
        
        setBackground()
        
        artView.showBackground = false
        
        var accessKey = ""
        if server.isAdmin {
            accessKey = server.adminKey
        }
        else {
            accessKey = server.accessKey
        }
        
        URLSessionHandler.instance.findServer(accessKey: accessKey) { success, code, server in
            let storeduuid = self.server.uuid
            let storedpublic = self.server.isPublic
            
            if server == nil && code >= 400 && code < 500 {
                SessionSettings.instance.removeServer(server: self.server)
                self.showError(type: self.errorTypeAccessKey)
                return
            }
            else if server == nil {
                self.showError(type: self.errorTypeServer)
                return
            }
            
            if !self.server.isPublic {
                SessionSettings.instance.removeServer(server: self.server)
            }
            
            self.canvasImage.alpha = 0
            self.canvasImage.kf.setImage(
                with: URL(string: "\(server!.serviceAltUrl())canvas"), options: [.forceRefresh]) { result in
                    UIView.animate(withDuration: 1, delay: 0, options: .curveEaseIn) {
                        self.canvasImage.alpha = 1
                    }
                }
            
            self.iconImage.alpha = 0
            self.iconImage.layer.cornerRadius = 50
//            self.iconImage.kf.setImage(
//                with: URL(string: server!.iconUrl)) { result in
//                    UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn) {
//                        self.iconImage.alpha = 1
//                    }
//                }
            
            //self.canvasImage.image = UIImage(named: "amb_2.png")
            
            if server!.isAdmin {
                self.connectingLabel.text = "Connecting to \(server!.name) (Mod)"
            }
            else {
                self.connectingLabel.text = "Connecting to \(server!.name)"
            }
            
            if server!.color != 0 {
                self.connectingLabel.textColor = UIColor(argb: server!.color)
            }
            
            server!.uuid = storeduuid
            server!.isPublic = storedpublic
            server!.lastVisited = NSDate().timeIntervalSince1970
            
            self.server = server!
            
            if self.server.isPublic {
                SessionSettings.instance.publicServerLastVisitedTimes["\(self.server.uid)"] = self.server.lastVisited
            }
            else {
                SessionSettings.instance.addServer(server: self.server)
            }
            
            SessionSettings.instance.uniqueId = self.server.uuid
            SessionSettings.instance.maxPaintAmt = server!.maxPixels
            SessionSettings.instance.maxSend = server!.maxSend
            SessionSettings.instance.canvasSize = server!.size
            
            SessionSettings.instance.lastVisitedServer = server!
            SessionSettings.instance.lastVisitedServerId = server!.uid
            
            QueueSocket.instance.startSocket(server: server!)
            QueueSocket.instance.queueSocketDelegate = self
            
            let rIndex = Int(arc4random() % UInt32(self.gameTips.count))
            self.gameTipLabel.text = self.gameTips[rIndex]
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { (tmr) in
                if self.lastDotsStr.count < 3 {
                    self.lastDotsStr = self.lastDotsStr + "."
                }
                else {
                    self.lastDotsStr = ""
                }
                self.dotsLabel.text = self.lastDotsStr
            }
            
            self.downloadFinished()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if lockToLandscape {
            AppDelegate.OrientationUtility.lockAndApplyOrientation(UIInterfaceOrientationMask.landscape)
            lockToLandscape = false
        }
    }
    
    func getCanvas() {
        //artView.jsonFile = "globe_json"
        
        SessionSettings.instance.maxPaintAmt = server.maxPixels
        
        downloadCanvasChunkPixels()

        if server.uuid == "" {
            sendDeviceId()
        }
        else {
            getDeviceInfo()
        }
        
        getTopContributors()
    }
    
    func downloadCanvasChunkPixels() {
        URLSessionHandler.instance.downloadCanvasChunkPixels(server: server, chunk: 1) { (success) in
            if success {
                self.doneLoadingChunk1 = true
                self.downloadFinished()
            }
            else {
                self.showError(type: self.errorTypeServer)
            }
        }
        URLSessionHandler.instance.downloadCanvasChunkPixels(server: server, chunk: 2) { (success) in
            if success {
                self.doneLoadingChunk2 = true
                self.downloadFinished()
            }
            else {
                self.showError(type: self.errorTypeServer)
            }
        }
        URLSessionHandler.instance.downloadCanvasChunkPixels(server: server, chunk: 3) { (success) in
            if success {
                self.doneLoadingChunk3 = true
                self.downloadFinished()
            }
            else {
                self.showError(type: self.errorTypeServer)
            }
        }
        URLSessionHandler.instance.downloadCanvasChunkPixels(server: server, chunk: 4) { (success) in
            if success {
                self.doneLoadingChunk4 = true
                self.downloadFinished()
            }
            else {
                self.showError(type: self.errorTypeServer)
            }
        }
    }

    func downloadCanvasPixels() {
        
        URLSessionHandler.instance.downloadCanvasPixels(server: server) { (success) in
            if success {
                self.doneLoadingPixels = true
                
                self.downloadFinished()
            }
            else {
                self.showError(type: self.errorTypeServer)
            }
        }
    }
    
    func getTopContributors() {
        URLSessionHandler.instance.downloadTopContributors(server: server) { (topContributors) in
            let topContributorNameViews1 = [self.topContributorName1, self.topContributorName2, self.topContributorName3, self.topContributorName4, self.topContributorName5]
            let topContributorNameViews2 = [self.topContributorName6, self.topContributorName7, self.topContributorName8, self.topContributorName9, self.topContributorName10]
            
            let topContributorAmtViews1 = [self.topContributorAmt1, self.topContributorAmt2, self.topContributorAmt3, self.topContributorAmt4, self.topContributorAmt5]
            let topContributorAmtViews2 = [self.topContributorAmt6, self.topContributorAmt7, self.topContributorAmt8, self.topContributorAmt9, self.topContributorAmt10]
            
            if topContributors != nil {
                for i in topContributors!.indices {
                    let topContributor = topContributors![i]
                    
                    var name = topContributor["name"] as! String
                    
                    if name.count > 10 {
                        name = String(name.prefix(7)) + "..."
                    }
                    
                    let amt = topContributor["amt"] as! Int
                    
                    if i == 0 {
                        SessionSettings.instance.firstContributorName = name
                        self.topContributorName1.textColor = Utils.UIColorFromColorHex(hex: "0xffdecb52")
                    }
                    else if i == 1 {
                        SessionSettings.instance.secondContributorName = name
                        self.topContributorName2.textColor = Utils.UIColorFromColorHex(hex: "0xffafb3b1")
                    }
                    else if i == 2 {
                        SessionSettings.instance.thirdContributorName = name
                        self.topContributorName3.textColor = Utils.UIColorFromColorHex(hex: "0xffbd927b")
                    }
                    
                    if i < 5 {
                        topContributorNameViews1[i]!.text = name
                        topContributorAmtViews1[i]!.text = String(amt)
                        
                        topContributorNameViews1[i]!.isHidden = false
                        topContributorAmtViews1[i]!.isHidden = false
                        
                        topContributorNameViews1[i]!.alpha = 0
                        topContributorAmtViews1[i]!.alpha = 0
                        
                        UIView.animate(withDuration: 0.5) {
                            topContributorNameViews1[i]!.alpha = 1
                            topContributorAmtViews1[i]!.alpha = 1
                        }
                    }
                    else {
                        topContributorNameViews2[i - 5]!.text = name
                        topContributorAmtViews2[i - 5]!.text = String(amt)
                        
                        topContributorNameViews2[i - 5]!.isHidden = false
                        topContributorAmtViews2[i - 5]!.isHidden = false
                        
                        topContributorNameViews2[i - 5]!.alpha = 0
                        topContributorAmtViews2[i - 5]!.alpha = 0
                        
                        UIView.animate(withDuration: 0.5) {
                            topContributorNameViews2[i - 5]!.alpha = 1
                            topContributorAmtViews2[i - 5]!.alpha = 1
                        }
                    }
                }
                
                self.doneLoadingTopContributors = true
                self.downloadFinished()
            }
            else {
                self.showError(type: self.errorTypeServer)
            }
        }
    }
    
    func getDeviceInfo() {
        URLSessionHandler.instance.getDeviceInfo(server: server) { (success) -> (Void) in
            if success {
                if SessionSettings.instance.banned {
                    self.showError(type: self.errorTypeBan)
                    return
                }
                else {
                    self.doneSyncDevice = true
                    self.downloadFinished()
                }
                
                if !self.server.isAdmin {
                    URLSessionHandler.instance.logIp(server: self.server, uuid: self.server.uuid) { response in
                        if response == nil {
                            self.showError(type: self.errorTypeServer)
                            return
                        }
                        else if !(response!["success"] as! Bool) {
                            self.showError(type: self.errorTypeBan)
                            return
                        }
                        
                        self.doneCheckingIp = true
                        self.downloadFinished()
                    }
                }
                else {
                    self.doneCheckingIp = true
                    self.downloadFinished()
                }
            }
            else {
                self.showError(type: self.errorTypeServer)
            }
        }
    }
    
    func sendDeviceId() {
        self.server.uuid = UUID().uuidString.lowercased()
        if self.server.isPublic {
            SessionSettings.instance.publicServerUniqueIds["\(self.server.uid)"] = self.server.uuid
            SessionSettings.instance.save()
        }
        
        URLSessionHandler.instance.sendDeviceId(server: server) { (success) -> (Void) in
            if success {
                SessionSettings.instance.saveServers()
                
                self.doneSyncDevice = true
                
                self.downloadFinished()
                
                if !self.server.isAdmin {
                    URLSessionHandler.instance.logIp(server: self.server, uuid: self.server.uuid) { response in
                        if response == nil {
                            self.showError(type: self.errorTypeServer)
                            return
                        }
                        else if !(response!["success"] as! Bool) {
                            self.showError(type: self.errorTypeBan)
                            return
                        }
                        
                        self.doneCheckingIp = true
                        self.downloadFinished()
                    }
                }
                else {
                    self.doneCheckingIp = true
                    self.downloadFinished()
                }
            }
            else {
                self.showError(type: self.errorTypeServer)
            }
        }
    }
    
    func downloadFinished() {
        if realmId == 1 {
            statusLabel.text = String(format: "Loading %d / 8", getNumLoaded())
        }
        else {
            statusLabel.text = String(format: "Loading %d / 4", getNumLoaded())
        }
        
        if loadingDone() {
            SessionSettings.instance.save()
            if !SessionSettings.instance.agreedToTermsOfService {
                self.performSegue(withIdentifier: self.showTermsOfService, sender: nil)
            }
            else {
                self.performSegue(withIdentifier: self.showInteractiveCanvas, sender: nil)
            }
        }
    }
    
    func getNumLoaded() -> Int {
        var num = 0
        
        if doneLoadingPixels {
            num += 1
        }
        
        if doneSyncDevice {
            num += 1
        }
        
        if doneLoadingTopContributors {
            num += 1
        }
        
        if doneLoadingChunk1 {
            num += 1
        }
        
        if doneLoadingChunk2 {
            num += 1
        }
        
        if doneLoadingChunk3 {
            num += 1
        }
        
        if doneLoadingChunk4 {
            num += 1
        }
        
        if doneConnectingSocket {
            num += 1
        }
        
        if doneConnectingQueue {
            num += 1
        }
        
        return num
    }
    
    func loadingDone() -> Bool {
        if realmId == 1 {
            return doneSyncDevice && doneLoadingTopContributors && doneLoadingChunk1 &&
                doneLoadingChunk2 && doneLoadingChunk3 && doneLoadingChunk4 &&
                doneConnectingSocket && doneConnectingQueue && doneCheckingIp
        }
        else {
            return doneLoadingPixels && doneSyncDevice && doneLoadingTopContributors &&
                doneConnectingSocket && doneConnectingQueue
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.showInteractiveCanvas {
            segue.destination.isModalInPresentation = true
            
            let vc = segue.destination as! InteractiveCanvasViewController
            vc.world = true
            vc.realmId = realmId
            vc.server = server
        }
        
        timer?.invalidate()
        queuePosTimer?.invalidate()
    }
    
    func setBackground() {
        let gradient = CAGradientLayer()

        gradient.frame = view.bounds
        gradient.colors = [UIColor(argb: Utils.int32FromColorHex(hex: "0xff000000")).cgColor, UIColor(argb: Utils.int32FromColorHex(hex: "0xff0e0417")).cgColor]
        
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)

        view.layer.insertSublayer(gradient, at: 0)
    }
    
    func showError(type: String) {
        if !showingError {
            var msg = ""
            
            if type == errorTypeServer {
                msg = "Server error."
            }
            else if type == errorTypeSocket {
                msg = "Socket error."
            }
            else if type == errorTypeQueue {
                msg = "Queue is not responding."
            }
            else if type == errorTypeAccessKey {
                msg = "Access key has changed."
            }
            else if type == errorTypeBan {
                msg = "You are banned."
            }
            
            // create the alert
            let alert = UIAlertController(title: nil, message: msg, preferredStyle: UIAlertController.Style.alert)
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                InteractiveCanvasSocket.instance.socketConnectionDelegate = nil
                
                self.presentingViewController?.dismiss(animated: false, completion: nil)
            }))
            // show the alert
            self.present(alert, animated: true, completion: nil)
            
            showingError = true
        }
    }
    
    // socket connection delegate
    func notifySocketConnect() {
        doneConnectingSocket = true
        InteractiveCanvasSocket.instance.socketConnectionDelegate = nil
        
        getCanvas()
    }
    
    func notifySocketDisconnect() {
        
    }
    
    func notifySocketConnectionError() {
        showError(type: errorTypeSocket)
    }
    
    // queue socket delegate
    func notifyQueueConnect() {
        doneConnectingQueue = true
        downloadFinished()
    }
    
    func notifyQueueConnectError() {
        doneConnectingQueue = false
        showError(type: errorTypeQueue)
    }
    
    func notifyCanvasSocketDownError() {
        doneConnectingQueue = false
        showError(type: errorTypeSocket)
    }
    
    func notifyAddedToQueue(pos: Int) {
        print("Queue pos = " + String(pos))
        queuePos = pos
        
        if (queuePos > 1) {
            updateQueuePos()
            queuePosLabel.isHidden = false
            queuePosTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(updateQueuePos), userInfo: nil, repeats: true)
        }
    }
    
    @objc func updateQueuePos() {
        queuePos -= 1
        queuePosLabel.text = "~\(queuePos) in queue"
        if queuePos == 0 {
            queuePosLabel.isHidden = true
        }
    }
    
    func notifyServiceReady() {
        QueueSocket.instance.queueSocketDelegate = nil
        QueueSocket.instance.disconnect()
            
        InteractiveCanvasSocket.instance.socketConnectionDelegate = self
        InteractiveCanvasSocket.instance.startSocket(server: server)
    }
    
    @IBAction func unwind( _ seg: UIStoryboardSegue) {
        self.presentingViewController?.dismiss(animated: false, completion: nil)
        AppDelegate.OrientationUtility.lockOrientation(UIInterfaceOrientationMask.all)
        if self.presentingViewController is MenuViewController {
            (self.presentingViewController as! MenuViewController).updateServerListsContraints()
            (self.presentingViewController as! MenuViewController).startShowcase()
        }
    }
    
    func processAgreedToTermsOfService() {
        self.performSegue(withIdentifier: self.showInteractiveCanvas, sender: nil)
    }
}
