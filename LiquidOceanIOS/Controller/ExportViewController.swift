//
//  ExportViewController.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 2/18/21.
//  Copyright © 2021 Eric Versteeg. All rights reserved.
//

import UIKit

protocol ExportViewControllerDelegate: AnyObject {
    func notifyExportViewControllerBackPressed()
}

class ExportViewController: UIViewController {

    @IBOutlet weak var saveButton: ButtonFrame!
    
    @IBOutlet weak var shareButton: ButtonFrame!
    
    @IBOutlet weak var artViewWidth: NSLayoutConstraint!
    @IBOutlet weak var artViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var screenSizeLabel: UILabel!
    @IBOutlet weak var actualSizeLabel: UILabel!
    @IBOutlet weak var artSizeSwitch: UISwitch!
    
    @IBOutlet weak var artSizeSwitchTop: NSLayoutConstraint!
    
    @IBOutlet weak var canvasImageView: UIImageView!
    
    @IBOutlet weak var canvasImageViewWidth: NSLayoutConstraint!
    @IBOutlet weak var canvasImageViewHeight: NSLayoutConstraint!
    
    private var canvasImage: UIImage?
    
    var _art: [InteractiveCanvas.RestorePoint]?
    var art: [InteractiveCanvas.RestorePoint]? {
        set {
            _art = newValue
            artView.showBackground = true
            artView.art = _art
            
            if let art = art {
                if art.count > 0 {
                    SessionSettings.instance.addToShowcase(art: art)
                    SessionSettings.instance.save()
                }
            }
            
            screenSizeLabel.isHidden = false
            actualSizeLabel.isHidden = false
            artSizeSwitch.isHidden = false
        }
        get {
            return _art
        }
    }
    
    var _canvas: InteractiveCanvas?
    var canvas: InteractiveCanvas? {
        set {
            _canvas = newValue
            
            if newValue == nil {
                canvasImage = nil
                canvasImageView.isHidden = true
                return
            }
            
            artView.showBackground = true
            canvasImage = createImageFromColorArray(newValue!.arr, width: newValue!.cols, height: newValue!.rows)
            if canvasImage != nil {
                canvasImageView.layer.magnificationFilter = .nearest
                canvasImageView.layer.minificationFilter = .nearest
                canvasImageView.contentMode = .scaleToFill
                canvasImageView.image = canvasImage!
                canvasImageView.isHidden = false
            }
            
            screenSizeLabel.isHidden = true
            actualSizeLabel.isHidden = true
            artSizeSwitch.isHidden = true
        }
        get {
            return _canvas
        }
    }
    
    var delegate: ExportViewControllerDelegate?
    
    @IBOutlet weak var backButton: ButtonFrame!
    
    @IBOutlet weak var backButtonLeading: NSLayoutConstraint!
    
    @IBOutlet weak var artView: ArtView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.setOnClickListener {
            self.delegate?.notifyExportViewControllerBackPressed()
        }
        
        saveButton.setOnClickListener {
            self.artView.saveArtToPhotos()
        }
        
        shareButton.setOnClickListener {
            // set up activity view controller
            var imageToShare: Data
            if self.art != nil {
                imageToShare = self.artView.getArtImage().pngData()!
            }
            else {
                imageToShare = self.canvasImage!.pngData()!
            }
            let activityViewController = UIActivityViewController(activityItems: [imageToShare], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view

            // exclude some activity types from the list (optional)
            // activityViewController.excludedActivityTypes = [ActivityType.airDrop, ActivityType.postToFacebook]

            // present the view controller
            self.present(activityViewController, animated: true, completion: nil)
        }
        
        screenSizeLabel.addGestureRecognizer(UITouchGestureRecognizer(target: self, action: #selector(touchedScreenSizeLabel(sender:))))
        
        actualSizeLabel.addGestureRecognizer(UITouchGestureRecognizer(target: self, action: #selector(touchedActualSizeLabel(sender:))))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.OrientationUtility.lockOrientation(UIInterfaceOrientationMask.landscape)
    }
    
    override func viewDidLayoutSubviews() {
        artViewWidth.constant = 500
        artViewHeight.constant = 300
        
        if artView.frame.origin.y < (saveButton.frame.origin.y + saveButton.frame.size.height) {
            artViewHeight.constant -= (saveButton.frame.origin.y + saveButton.frame.size.height) - artView.frame.origin.y + 10
        }
        
        let backX = self.backButton.frame.origin.x
        if backX < 0 {
            backButtonLeading.constant += 30
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            artViewWidth.constant = view.frame.size.width - 130
            artViewHeight.constant = view.frame.size.height - 200
            
            artSizeSwitchTop.constant = 45
        }
        
        let minSpan = min(view.window?.windowScene?.screen.bounds.width ?? 500, view.window?.windowScene!.screen.bounds.height ?? 300)
        let canvasPadding = if UIDevice.current.userInterfaceIdiom == .pad {
            160.0
        }
        else {
            120.0
        }
        
        canvasImageViewWidth.constant = minSpan - canvasPadding
        canvasImageViewHeight.constant = minSpan - canvasPadding
        
        artView.setNeedsDisplay()
    }
    
    @IBAction func artSizeValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            actualSize()
        }
        else {
            screenSize()
        }
    }

    @objc func touchedScreenSizeLabel(sender: UITouchGestureRecognizer) {
        if sender.state == .began {
            artSizeSwitch.isOn = true
            artSizeValueChanged(artSizeSwitch)
        }
    }
    
    @objc func touchedActualSizeLabel(sender: UITouchGestureRecognizer) {
        if sender.state == .began {
            artSizeSwitch.isOn = false
            artSizeValueChanged(artSizeSwitch)
        }
    }
    
    func screenSize() {
        screenSizeLabel.isHidden = false
        actualSizeLabel.isHidden = true
        
        artView.actualSize = false
    }
    
    func actualSize() {
        screenSizeLabel.isHidden = true
        actualSizeLabel.isHidden = false
        
        artView.actualSize = true
    }
    
    // Thanks Claude!
    func createImageFromColorArray(_ colorArray: [[Int32]], width: Int, height: Int) -> UIImage? {
        guard !colorArray.isEmpty, width > 0, height > 0 else { return nil }
        
        // Create a bitmap with raw, uncompressed data
        let bitsPerComponent = 8
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // Use BGRA format with no compression
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
        
        // Allocate memory for the bitmap data
        let dataSize = height * bytesPerRow
        let rawData = malloc(dataSize)
        defer { free(rawData) }
        
        guard let pixelData = rawData else { return nil }
        let pixelBuffer = pixelData.bindMemory(to: UInt32.self, capacity: width * height)
        
        // Fill the buffer with color data
        for y in 0..<min(colorArray.count, height) {
            let row = colorArray[y]
            for x in 0..<min(row.count, width) {
                let pixelIndex = y * width + x
                
                // Get the ARGB color from the array
                var argbColor = colorArray[y][x]
                if argbColor == 0 {
                    argbColor = Utils.int32FromColorHex(hex: "0xFF000000")
                }
                
                // Extract components
                let alpha = UInt8((argbColor >> 24) & 0xFF)
                let red = UInt8((argbColor >> 16) & 0xFF)
                let green = UInt8((argbColor >> 8) & 0xFF)
                let blue = UInt8(argbColor & 0xFF)
                
                // Repack as BGRA for iOS
                let rgbaColor = UInt32(alpha) << 24 | UInt32(red) << 16 | UInt32(green) << 8 | UInt32(blue)
                pixelBuffer[pixelIndex] = rgbaColor
            }
        }
        
        // Create context with our allocated memory
        guard let context = CGContext(data: pixelData,
                                     width: width,
                                     height: height,
                                     bitsPerComponent: bitsPerComponent,
                                     bytesPerRow: bytesPerRow,
                                     space: colorSpace,
                                     bitmapInfo: bitmapInfo.rawValue,
                                     releaseCallback: nil,
                                     releaseInfo: nil) else {
            return nil
        }
        
        // Create CGImage from context
        guard let cgImage = context.makeImage() else { return nil }
        
        // Create UIImage from CGImage with no scaling or interpolation
        let image = UIImage(cgImage: cgImage, scale: 1.0, orientation: .up)
        
        return image
    }
}
