//
//  MenuViewController.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 2/12/21.
//  Copyright © 2021 Eric Versteeg. All rights reserved.
//

import UIKit

protocol MenuButtonDelegate: AnyObject {
    func menuButtonPressed(menuButtonType: MenuButtonType)
}

protocol ServerSelectionDelegate: AnyObject {
    func onServerSelected(server: Server)
}

enum MenuButtonType {
    case options
    case howto
    case lefty
    case righty
}

class MenuViewController: UIViewController, AchievementListener, ServerSelectionDelegate, UICollectionViewDataSource,
                            UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {

    let showSinglePlay = "ShowSinglePlay"
    let showLoadingScreen = "ShowLoading"
    let showStats = "ShowStats"
    let showOptions = "ShowOptions"
    let showHowto = "ShowHowto"
    
    @IBOutlet weak var serverListsContainerPortrait: UIView?
    private var serverListViewForPortrait: ServerListsView? = nil
    
    @IBOutlet weak var serverListsContainerLandscape: UIView?
    private var serverListViewForLandscape: ServerListsView? = nil
    
    @IBOutlet weak var connectButton: ButtonFrame?
    @IBOutlet weak var optionsButton: ButtonFrame!
    @IBOutlet weak var howtoButton: ButtonFrame!
    
    @IBOutlet weak var singleButtonBottomLayer: ActionButtonView!
    @IBOutlet weak var singleButton: ActionButtonView!
    
    @IBOutlet weak var worldButtonBottomLayer: ActionButtonView!
    @IBOutlet weak var worldButton: ActionButtonView!
    
    @IBOutlet weak var devButtonBottomLayer: ActionButtonView!
    @IBOutlet weak var devButton: ActionButtonView!
    
    @IBOutlet weak var leftyButton: ButtonFrame!
    @IBOutlet weak var rightyButton: ButtonFrame!
    
    @IBOutlet weak var backButton: ButtonFrame?
    @IBOutlet weak var backActionLeading: NSLayoutConstraint!
    @IBOutlet weak var addButton: ButtonFrame?
    @IBOutlet weak var menuButton: ButtonFrame?
    
    @IBOutlet weak var achievementBanner: UIView!
    
    @IBOutlet weak var achievementIcon: AchievementIcon!
    @IBOutlet weak var achievementName: UILabel!
    @IBOutlet weak var achievementDesc: UILabel!
    
    @IBOutlet weak var artView: ArtView!
    @IBOutlet weak var menuContainer: UIView!
    
    @IBOutlet weak var menuContainerWidth: NSLayoutConstraint!
    @IBOutlet weak var menuContainerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var serversCollectionView: UICollectionView!
    
    @IBOutlet weak var addServerContainer: UIView!
    
    @IBOutlet weak var accessKeyTextField: UITextField!
    
    weak var menuButtonDelegate: MenuButtonDelegate?
    
    var lastViewFrameSize: CGSize!
    
    var realmId = 0
    
    var showcaseTimer: Timer!
    
    var pixels = [UIView]()
    
    let backgrounds: [(gradient1: Int32, gradient2: Int32)] = [
        (gradient1: Utils.int32FromColorHex(hex: "0xff290a59"), gradient2: Utils.int32FromColorHex(hex: "0xffff7c00")),
        (gradient1: Utils.int32FromColorHex(hex: "0xff942210"), gradient2: Utils.int32FromColorHex(hex: "0xff1f945e")),
        (gradient1: Utils.int32FromColorHex(hex: "0xff681a8a"), gradient2: Utils.int32FromColorHex(hex: "0xff0e877b")),
        (gradient1: Utils.int32FromColorHex(hex: "0xfffa8202"), gradient2: Utils.int32FromColorHex(hex: "0xff18bdfa")),
        (gradient1: Utils.int32FromColorHex(hex: "0xff3b943f"), gradient2: Utils.int32FromColorHex(hex: "0xff4f1fe0")),
        (gradient1: Utils.int32FromColorHex(hex: "0xff242e8f"), gradient2: Utils.int32FromColorHex(hex: "0xff8f3234")),
        (gradient1: Utils.int32FromColorHex(hex: "0xff898f1d"), gradient2: Utils.int32FromColorHex(hex: "0xff158f86"))]
    
    var rIndex = 0
    
    var cBackgroundGradientIndex = 0
    var insertedSublayer = false
    
    var menuLayer = 0
    
    var defaultLabelColor: Int32 = 0
    
    var fromInteractiveCanvas = false
    
    var selectedServer: Server!
    
    var keyboardHeight = CGFloat(0)
    var textFieldY: CGFloat?
    
    private var serverListViewModel = ServerListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
//        URLSessionHandler.instance.findServer(accessKey: "TEST1") { success, server in
//            if server != nil {
//                print(server!.name)
//                if !SessionSettings.instance.hasServer(accessKey: "TEST1") {
//                    SessionSettings.instance.addServer(server: server!)
//                }
//            }
//        }
        
        // self.view.backgroundColor = UIColor(argb: Utils.int32FromColorHex(hex: "0xFF333333"))
        
        //defaultLabelColor = drawLabel.textColor.argb()
        //defaultLabelColor = optionsLabel.textColor.argb()
        
        /*menuContainer.layer.cornerRadius = 10
        menuContainer.layer.borderWidth = 1
        menuContainer.layer.borderColor = Utils.UIColorFromColorHex(hex: "0xFF333333").cgColor*/
        
        rIndex = Int(arc4random() % UInt32(backgrounds.count))
        
        singleButtonBottomLayer.type = .single
        singleButtonBottomLayer.selectable = false
        
        singleButton.type = .single
        singleButton.topLayer = true
        
        worldButtonBottomLayer.type = .world
        worldButtonBottomLayer.selectable = false
        
        worldButton.type = .world
        worldButton.topLayer = true
        
        devButtonBottomLayer.type = .dev
        devButtonBottomLayer.selectable = false
        
        devButton.type = .dev
        devButton.topLayer = true
        
        self.backButton?.setOnClickListener {
            self.backButtonClicked()
        }
        
        if addButton != nil {
            self.addButton!.setOnClickListener {
                self.showAddServerView()
            }
        }
        
        if menuButton != nil {
            self.menuButton!.setOnClickListener {
                self.showConnectView()
            }
        }
        
        //var touchGr = UITouchGestureRecognizer(target: self, action: #selector(drawLabelTouched(sender:)))
        //drawLabel.addGestureRecognizer(touchGr)
        
        connectButton?.setOnClickListener {
            self.connectLabelTapped()
        }
        
        optionsButton?.setOnClickListener {
            self.optionsLabelTapped()
        }
        
        howtoButton?.setOnClickListener {
            self.howtoLabelTapped()
        }

        leftyButton?.setOnClickListener {
            self.leftyLabelTapped()
        }
        
        rightyButton?.setOnClickListener {
            self.rightyLabelTapped()
        }
        
        self.singleButton.setOnClickListener {
            self.realmId = 0
            if SessionSettings.instance.selectedHand {
                self.performSegue(withIdentifier: self.showSinglePlay, sender: nil)
            }
            else {
                self.showHandButtons()
            }
        }
        
        self.worldButton.setOnClickListener {
            self.realmId = 1
            if SessionSettings.instance.selectedHand {
                self.performSegue(withIdentifier: self.showLoadingScreen, sender: nil)
            }
            else {
                self.showHandButtons()
            }
        }
        
        self.devButton.setOnClickListener {
            self.realmId = 2
            if SessionSettings.instance.selectedHand {
                self.performSegue(withIdentifier: self.showLoadingScreen, sender: nil)
            }
            else {
                self.showHandButtons()
            }
        }
        
        StatTracker.instance.achievementListener = self
        
        startShowcase()
        
        lastViewFrameSize = CGSize(width: 0, height: 0)
    }
    
    func backButtonClicked() {
        if !self.addServerContainer.isHidden || !self.serversCollectionView.isHidden {
            self.addServerContainer.isHidden = true
            self.serversCollectionView.isHidden = true
            
            self.toggleMenuButtons(show: true, depth: 0)
            self.backButton!.isHidden = true
            self.addButton!.isHidden = true
            self.menuButton!.isHidden = false
        }
        else if self.menuLayer == 1 {
            self.toggleMenuButtons(show: true, depth: 0)
            self.toggleMenuButtons(show: false, depth: 1)
            
            if self.connectButton != nil {
                Animator.animateMenuButtons(views: [[self.connectButton!], [self.optionsButton], [self.howtoButton]], cascade: true, moveOut: false, inverse: false)
            }
            else {
                Animator.animateMenuButtons(views: [[self.optionsButton], [self.howtoButton]], cascade: true, moveOut: false, inverse: false)
            }
            
            self.backButton!.isHidden = true
        }
        else if self.menuLayer == 2 {
            self.toggleMenuButtons(show: true, depth: 1)
            self.toggleMenuButtons(show: false, depth: 2)
            
            Animator.animateMenuButtons(views: [[self.singleButtonBottomLayer, self.singleButton], [self.worldButtonBottomLayer, self.worldButton], [self.devButtonBottomLayer, self.devButton]], cascade: true, moveOut: false, inverse: false)
        }
        
        self.menuLayer -= 1
    }
    
    override func viewDidLayoutSubviews() {
        randomGradientBackground()
        
        let backX = self.backButton?.frame.origin.x
        
        if backX != nil && backX! < 0 {
            backActionLeading.constant += 30
        }
        
        startPixels()
        artView.setNeedsDisplay()
        
        // rotation
        if lastViewFrameSize.width != view!.frame.size.width || lastViewFrameSize.height != view!.frame.size.height {
            updateServerListsContraints()
            
            lastViewFrameSize = view!.frame.size
        }
    }
    
    /*override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Animator.animateMenuButtons(views: [[self.optionsLabel], [self.howtoLabel]], cascade: true, moveOut: false, inverse: false)
    }*/
    
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.OrientationUtility.lockOrientation(UIInterfaceOrientationMask.all)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /*if SessionSettings.instance.canvasOpen {
            self.performSegue(withIdentifier: self.showSinglePlay, sender: nil)
        }*/
        
        if !SessionSettings.instance.selectedHand {
            self.showHandButtons()
        }
        else {
            self.showMenuButtons()
        }
    }
    
    func updateServerListsContraints() {
        let orientation = UIDevice.current.orientation
        let isPortrait = orientation.isPortrait || orientation.isFlat
        print("Is portrait = \(isPortrait)")
        
        // Thanks Claude!
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let interfaceOrientation = windowScene.interfaceOrientation
            
            if interfaceOrientation.isPortrait {
                if serverListViewForPortrait == nil {
                    serverListViewForPortrait = ServerListsView(viewModel: serverListViewModel, serverSelectionDelegate: self, isPortrait: true)
                    if self.serverListsContainerPortrait != nil {
                        addSwiftUIViewToContainer(swiftUIView: serverListViewForPortrait!, containerView: self.serverListsContainerPortrait!)
                        self.serverListsContainerPortrait!.backgroundColor = UIColor.black
                    }
                }
                
                serverListsContainerPortrait?.isHidden = false
                serverListsContainerLandscape?.isHidden = true
            }
            else if interfaceOrientation.isLandscape {
                if serverListViewForLandscape == nil {
                    serverListViewForLandscape = ServerListsView(viewModel: serverListViewModel, serverSelectionDelegate: self, isPortrait: false)
                    if self.serverListsContainerLandscape != nil {
                        addSwiftUIViewToContainer(swiftUIView: serverListViewForLandscape!, containerView: self.serverListsContainerLandscape!)
                        self.serverListsContainerLandscape!.backgroundColor = UIColor.black
                    }
                }
                
                serverListsContainerPortrait?.isHidden = true
                serverListsContainerLandscape?.isHidden = false
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        StatTracker.instance.achievementListener = nil
        
        if segue.identifier == self.showSinglePlay {
            let vc = segue.destination as! InteractiveCanvasViewController
            vc.world = false
        }
        else if segue.identifier == self.showStats  {
            let _ = segue.destination as! StatsViewController
        }
        else if segue.identifier == self.showLoadingScreen {
            let vc = segue.destination as! LoadingViewController
            vc.realmId = realmId
            vc.server = selectedServer
            vc.lockToLandscape = true
        }
        
        showcaseTimer.invalidate()
        stopPixels()
    }
    
    func highlightLabel(label: UILabel) {
        label.textColor = UIColor(argb: ActionButtonView.altGreenColor)
    }
    
    func unhighlightLabel(label: UILabel) {
        label.textColor = UIColor(argb: defaultLabelColor)
    }
    
    // menu gestures
    func drawLabelTapped() {
        self.realmId = 0
        if SessionSettings.instance.selectedHand {
            self.performSegue(withIdentifier: self.showSinglePlay, sender: nil)
        }
        else {
            self.showHandButtons()
        }
    }
    
    /*@objc func drawLabelTouched(sender: UITouchGestureRecognizer) {
        if (sender.state == .began) {
            highlightLabel(label: drawLabel)
        }
        else if (sender.state == .ended) {
            unhighlightLabel(label: drawLabel)
            drawLabelTapped()
        }
    }*/
    
    func connectLabelTapped() {
//        let lastVisitedServer = SessionSettings.instance.lastVisitedServer
//        if lastVisitedServer != nil {
//            self.selectedServer = lastVisitedServer
//            self.performSegue(withIdentifier: showLoadingScreen, sender: nil)
//            return
//        }
        showConnectView()
    }
    
    func showConnectView() {
        toggleMenuButtons(show: false, depth: 0)
        addButton!.isHidden = false
        menuButton!.isHidden = true
        serversCollectionView.isHidden = true
        addServerContainer.isHidden = true
        
        backButton!.isHidden = false
        
        if SessionSettings.instance.servers.count == 0 {
            addButton?.isHidden = true
            addServerContainer.isHidden = false
        }
        else {
            addButton!.isHidden = false
            
            serversCollectionView.isHidden = false
            serversCollectionView.reloadData()
        }
    }
    
    func showAddServerView() {
        toggleMenuButtons(show: false, depth: 0)
        serversCollectionView.isHidden = true
        
        addButton!.isHidden = true
        backButton!.isHidden = false
        
        addServerContainer.isHidden = false
    }
    
    func optionsLabelTapped() {
        //self.performSegue(withIdentifier: self.showOptions, sender: nil)
        if fromInteractiveCanvas {
            menuButtonDelegate?.menuButtonPressed(menuButtonType: .options)
        }
        else {
            self.performSegue(withIdentifier: showOptions, sender: nil)
        }
    }
    
    func howtoLabelTapped() {
        //self.performSegue(withIdentifier: self.showHowto, sender: nil)
        if fromInteractiveCanvas {
            menuButtonDelegate?.menuButtonPressed(menuButtonType: .howto)
        }
        else {
            self.performSegue(withIdentifier: showHowto, sender: nil)
        }
    }
    
    func leftyLabelTapped() {
        SessionSettings.instance.rightHanded = false
        SessionSettings.instance.selectedHand = true
        
        self.showMenuButtons()
        
        //SessionSettings.instance.quickSave()
        
        /*if self.realmId == 0 {
            self.performSegue(withIdentifier: self.showSinglePlay, sender: nil)
        }
        else {
            self.performSegue(withIdentifier: self.showLoadingScreen, sender: nil)
        }*/
        //menuButtonDelegate?.menuButtonPressed(menuButtonType: .lefty)
    }
    
    func rightyLabelTapped() {
        SessionSettings.instance.rightHanded = true
        SessionSettings.instance.selectedHand = true
        
        self.showMenuButtons()
        
        //SessionSettings.instance.quickSave()
        
        /*if self.realmId == 0 {
            self.performSegue(withIdentifier: self.showSinglePlay, sender: nil)
        }
        else {
            self.performSegue(withIdentifier: self.showLoadingScreen, sender: nil)
        }*/
        //menuButtonDelegate?.menuButtonPressed(menuButtonType: .righty)
    }
    
    func randomGradientBackground() {
        if SessionSettings.instance.defaultBg {
            rIndex = 5
            
            SessionSettings.instance.defaultBg = false
            //SessionSettings.instance.quickSave()
        }
        
        cBackgroundGradientIndex = rIndex
        
        if fromInteractiveCanvas {
            setGradient(bounds: CGRect(x: 0, y: 0, width: 500, height: 300), index: rIndex)
        }
        else {
            if let screen = self.view.window?.windowScene?.screen {
                setGradient(bounds: CGRect(x: 0, y: 0, width: screen.bounds.width, height: screen.bounds.height), index: rIndex)
            }
        }
    }
    
    func setGradient(bounds: CGRect, index: Int) {
        let background = backgrounds[index]
        
        let gradient = CAGradientLayer()

        gradient.frame = bounds
        gradient.colors = [UIColor(argb: background.gradient1).cgColor, UIColor(argb: background.gradient2).cgColor]
        
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)

        if insertedSublayer {
            view.layer.sublayers![0].removeFromSuperlayer()
        }
        view.layer.insertSublayer(gradient, at: 0)
        insertedSublayer = true
    }
    
    func toggleMenuButtons(show: Bool, depth: Int) {
        if depth == 0 {
            //self.drawLabel.isHidden = !show
            
            self.connectButton?.isHidden = !show
            
            self.optionsButton.isHidden = !show
            
            self.howtoButton.isHidden = !show
        }
        else if depth == 1 {
            self.singleButtonBottomLayer.isHidden = !show
            self.singleButton.isHidden = !show
            
            self.worldButtonBottomLayer.isHidden = !show
            self.worldButton.isHidden = !show
            
            self.devButtonBottomLayer.isHidden = true
            self.devButton.isHidden = true
        }
        else if depth == 2 {
            leftyButton?.isHidden = !show
            rightyButton?.isHidden = !show
        }
    }
    
    func showMenuButtons() {
        toggleMenuButtons(show: true, depth: 0)
        toggleMenuButtons(show: false, depth: 2)
        
        Animator.animateMenuButtons(views: [[optionsButton], [howtoButton]], cascade: true, moveOut: false, inverse: false)
        
        menuLayer += 2
    }
    
    func showHandButtons() {
        menuButton?.isHidden = true
        
        toggleMenuButtons(show: false, depth: 0)
        toggleMenuButtons(show: true, depth: 2)
        
        Animator.animateMenuButtons(views: [[leftyButton], [rightyButton]], cascade: true, moveOut: false, inverse: false)
        
        menuLayer += 2
    }
    
    func startShowcase() {
        if (SessionSettings.instance.artShowcase == nil) {
            SessionSettings.instance.defaultArtShowcase()
        }
        
        showcaseTimer = Timer.scheduledTimer(withTimeInterval: 7, repeats: true, block: { (tmr) in
            DispatchQueue.main.async {
                if SessionSettings.instance.artShowcase != nil {
                    self.artView.alpha = 0
                    
                    self.artView.showBackground = false
                    self.artView.art = self.getNextArtShowcase()
                    
                    UIView.animate(withDuration: 2.5, animations: {
                        self.artView.alpha = 1
                    }) { (success) in
                        if success {
                            Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (tmr) in
                                UIView.animate(withDuration: 1.5, animations: {
                                    self.artView.alpha = 0
                                })
                            }
                        }
                    }
                }
            }
        })
        showcaseTimer.fire()
    }
    
    func startPixels() {
        Animator.context = self
        
        if self.pixels.count == 0 {
            for _ in 0...6 {
                let newView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
                self.pixels.append(newView)
                self.view.addSubview(newView)
            }
        }
        
        for i in 0...6 {
            Animator.animatePixelColorEffect(view:self.pixels[i], parent: self.view, safeViews: [artView, menuContainer])
        }
    }
    
    func stopPixels() {
        Animator.context = nil
    }
    
    // achievement listener
    func notifyDisplayAchievement(nextAchievement: [String : Any], displayInterval: Int) {
        achievementBanner.layer.borderWidth = 2
        achievementBanner.layer.borderColor = UIColor(argb: Utils.int32FromColorHex(hex: "0xFF7819")).cgColor
        
        let eventType = nextAchievement["event_type"] as! StatTracker.EventType
        let value = nextAchievement["threshold"] as! Int
        let thresholdsPassed = nextAchievement["thresholds_passed"] as! Int
        
        if eventType == .paintReceived {
            achievementName.text = "Total Paint Accrued"
        }
        else if eventType == .pixelOverwriteIn {
            achievementName.text = "Pixels Overwritten By Others"
        }
        else if eventType == .pixelOverwriteOut {
            achievementName.text = "Pixels Overwritten By Me"
        }
        else if eventType == .pixelPaintedWorld {
            achievementName.text = "Pixels Painted World"
        }
        else if eventType == .pixelPaintedSingle {
            achievementName.text = "Pixels Painted Single"
        }
        else if eventType == .worldXp {
            achievementName.text = "World XP"
        }
        
        if eventType != .worldXp {
            achievementDesc.text = "Passed the " + String(value) + " threshold"
        }
        else {
            achievementDesc.text = "Congrats on reaching level " + String(StatTracker.instance.getWorldLevel())
        }
        
        achievementBanner.isHidden = false
        achievementBanner.layer.borderWidth = 1
        achievementBanner.layer.borderColor = UIColor.black.cgColor
        
        achievementIcon.setType(achievementType: eventType, thresholds: thresholdsPassed)
        
        let timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { (tmr) in
            DispatchQueue.main.async {
                self.achievementBanner.isHidden = true
            }
        }
    }
    
    func getNextArtShowcase() -> [InteractiveCanvas.RestorePoint]? {
        if let artShowcase = SessionSettings.instance.artShowcase {
            if SessionSettings.instance.showcaseIndex == artShowcase.count {
                SessionSettings.instance.showcaseIndex = 0
            }
            
            if artShowcase.count > 0 {
                let nextArt = artShowcase[SessionSettings.instance.showcaseIndex]
                SessionSettings.instance.showcaseIndex += 1
                
                return nextArt
            }
        }
        
        return nil
    }
    
    func deviceName() -> String {

        var systemInfo = utsname()
        uname(&systemInfo)

        guard let iOSDeviceModelsPath = Bundle.main.path(forResource: "iOSDeviceModelMapping", ofType: "plist") else { return "" }
        guard let iOSDevices = NSDictionary(contentsOfFile: iOSDeviceModelsPath) else { return "" }

        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        return iOSDevices.value(forKey: identifier) as! String
    }
    
    // servers colleciton data source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SessionSettings.instance.servers.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ServerCell", for: indexPath) as! ServerCell
        
        let server = SessionSettings.instance.servers[indexPath.item]
        
        if server.isAdmin {
            cell.nameLabel.text = "\(server.name) (Mod)"
        }
        else {
            cell.nameLabel.text = server.name
        }
        
        let lgr = ServerLongPressGestureRecognizer(target: self, action: #selector(didLongPressCell))
        lgr.server = server
        
        cell.addGestureRecognizer(lgr)
        
//        if indexPath.item == 1 {
//            cell.backgroundColor = UIColor.blue
//        }
//        else {
//            cell.backgroundColor = UIColor.red
//        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = 260.0
        
        let server = SessionSettings.instance.servers[indexPath.item]
        var title = ""
        if server.isAdmin {
            title = "\(server.name) (Mod)"
        }
        else {
            title = server.name
        }
        
        let font = UIFont(name: "Inter-Medium", size: 24)!
        
        let attrTitle = NSAttributedString(string: title, attributes: [.font: font])
        let height = attrTitle.boundingRect(with: CGSize(width: width, height: 100000), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).height
        
        return CGSize(width: width, height: height + 20)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 0
//    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedServer = SessionSettings.instance.servers[indexPath.item]
        self.performSegue(withIdentifier: showLoadingScreen, sender: nil)
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(afterServerLoadStarted), userInfo: nil, repeats: false)
    }
    
    @objc func afterServerLoadStarted() {
        self.backButtonClicked()
    }
    
    @IBAction func addServer() {
        let accessKey = accessKeyTextField.text!
        
        if SessionSettings.instance.hasServer(accessKey: accessKey) {
            return
        }
    
        URLSessionHandler.instance.findServer(accessKey: accessKey) { success, code, server in
            if server != nil {
                print(server!.name)
                SessionSettings.instance.addServer(server: server!)
                
                self.accessKeyTextField.text = nil
                self.showConnectView()
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveInputFieldUpIfNeeded()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func didLongPressCell(sender: ServerLongPressGestureRecognizer) {
        if (sender.state == .began) {
            let server = sender.server!
            
            let alertController = UIAlertController(title: "Delete", message: "Delete \(server.name)?", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { action in
                SessionSettings.instance.removeServer(server: server)
                self.serversCollectionView.reloadData()
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                alertController.dismiss(animated: true, completion: nil)
            }))
            
            present(alertController, animated: true, completion: nil)
        }
    }
    
    class ServerLongPressGestureRecognizer: UILongPressGestureRecognizer {
        var server: Server!
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
            moveInputFieldUpIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        resetInputFieldPosition()
    }
    
    func moveInputFieldUpIfNeeded() {
        if keyboardHeight == 0 {
            return
        }
        
        let topKeyboardY = UIScreen.main.bounds.size.height - keyboardHeight
        
        let absOrigin = accessKeyTextField?.superview?.convert(accessKeyTextField.frame.origin, to: nil)
        if absOrigin == nil {
            return
        }
        
        let bottomY = absOrigin!.y + accessKeyTextField.frame.size.height
        
        if textFieldY == nil {
            textFieldY = accessKeyTextField.frame.origin.y
        }
        
        print("keyboard top = \(topKeyboardY)")
        print("access key input bottom = \(bottomY)")
        
        let yDiff = topKeyboardY - bottomY
        
        if yDiff < 0 {
            accessKeyTextField.frame = CGRect(x: accessKeyTextField.frame.origin.x, y: accessKeyTextField.frame.origin.y + yDiff, width: accessKeyTextField.frame.size.width, height: accessKeyTextField.frame.size.height)
        }
    }
    
    func resetInputFieldPosition() {
        if textFieldY == nil {
            return
        }
        
        accessKeyTextField.frame = CGRect(x: accessKeyTextField.frame.origin.x, y: textFieldY!, width: accessKeyTextField.frame.size.width, height: accessKeyTextField.frame.size.height)
    }
    
    func onServerSelected(server: Server) {
        self.selectedServer = server
        if self.selectedServer.isPublic {
            let uuid = SessionSettings.instance.publicServerUniqueIds["\(selectedServer.uid)"] ?? ""
            self.selectedServer.uuid = uuid
        }
        self.performSegue(withIdentifier: showLoadingScreen, sender: nil)
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(afterServerLoadStarted), userInfo: nil, repeats: false)
    }
}
