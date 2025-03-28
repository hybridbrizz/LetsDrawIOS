//
//  InteractiveCanvasView.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 2/10/21.
//  Copyright © 2021 Eric Versteeg. All rights reserved.
//

import UIKit

protocol PaintActionDelegate: AnyObject {
    func notifyPaintActionStarted()
}

protocol InteractiveCanvasPaintDelegate: AnyObject {
    func notifyPaintingStarted()
    func notifyPaintingEnded(accept: Bool)
    func notifyPaintColorUpdate()
}

protocol ObjectSelectionDelegate: AnyObject {
    func notifyObjectSelectionBoundsChanged(upperLeft: CGPoint, lowerRight: CGPoint)
    
    func notifyObjectSelectionEnded()
}

protocol InteractiveCanvasPalettesDelegate: AnyObject {
    func isPalettesViewControllerVisible() -> Bool
    func notifyClosePalettesViewController()
}

protocol InteractiveCanvasGestureDelegate: AnyObject {
    func notifyInteractiveCanvasPan()
    func notifyInteractiveCanvasScale()
    func notifyInteractiveCanvasDoubleTap()
}

protocol CanvasFrameDelegate: AnyObject {
    func notifyToggleCanvasFrameView(canvasX: Int, canvasY: Int, screenPoint: CGPoint)
    func notifyCloseCanvasFrameView()
}

protocol CanvasEdgeTouchDelegate: AnyObject {
    func onTouchCanvasEdge()
}

protocol InteractiveCanvasSelectedObjectViewDelegate: AnyObject {
    func showSelectedObjectYesAndNoButtons(screenPoint: CGPoint)
    func hideSelectedObjectYesAndNoButtons()
    
    func selectedObjectEnded()
}

protocol InteractiveCanvasSelectedObjectMoveViewDelegate: AnyObject {
    func showSelectedObjectMoveButtons(bounds: CGRect)
    func updateSelectedObjectMoveButtons(bounds: CGRect)
    
    func hideSelectedObjectMoveButtons()
    
    func selectedObjectMoveEnded()
}

class InteractiveCanvasView: UIView, InteractiveCanvasDrawCallback, InteractiveCanvasScaleCallback, InteractiveCanvasDeviceViewportResetDelegate, InteractiveCanvasSelectedObjectDelegate, UIGestureRecognizerDelegate, ObservableObject {

    enum Mode {
        case exploring
        case paintSelectionExploring
        case painting
        case paintSelectionPainting
        case exporting
        case objectMoveSelection
        case objectMoving
    }
    
    var mode: Mode = .exploring
    
    var scaleFactor = CGFloat(1.0)
    var oldScaleFactor: CGFloat!
    
    var oldPpu: Int!
    
    var undo = false
    
    var interactiveCanvas: InteractiveCanvas!
    
    var longPressGestureRecognizer: UILongPressGestureRecognizer!
    var panGestureRecognizer: UIPanGestureRecognizer!
    var tapGestureRecognizer: UITapGestureRecognizer!
    var paintSelectTapGestureRecognizer: UITapGestureRecognizer!
    var drawGestureRecognizer: UIDrawGestureRecognizer!
    var pinchGestureRecognizer: UIPinchGestureRecognizer!
    
    weak var paintActionDelegate: PaintActionDelegate?
    weak var paintDelegate: InteractiveCanvasPaintDelegate?
    weak var objectSelectionDelegate: ObjectSelectionDelegate?
    weak var palettesDelegate: InteractiveCanvasPalettesDelegate?
    weak var gestureDelegate: InteractiveCanvasGestureDelegate?
    weak var canvasFrameDelegate: CanvasFrameDelegate?
    weak var canvasEdgeTouchDelegate: CanvasEdgeTouchDelegate?
    weak var selectedObjectView: InteractiveCanvasSelectedObjectViewDelegate?
    weak var selectedObjectMoveView: InteractiveCanvasSelectedObjectMoveViewDelegate?
    
    var objectSelectionStartUnit: CGPoint!
    var objectSelectionStartPoint: CGPoint!
    
    var lastPanTranslationX: CGFloat = 0
    var lastPanTranslationY: CGFloat = 0
    
    var startScaleFactor: CGFloat = 0
    
    var touchedCanvasEdge = false
    
    @Published var redrawCount = 0
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        interactiveCanvas = InteractiveCanvas()
        interactiveCanvas.drawCallback = self
        interactiveCanvas.scaleCallback = self
        interactiveCanvas.deviceViewportResetDelegate = self
        interactiveCanvas.selectedObjectDelegate = self
        
        interactiveCanvas.drawCallback?.notifyCanvasRedraw()
        
        // gestures
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan(sender:)))
        self.panGestureRecognizer.maximumNumberOfTouches = 2
        addPan()
        
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap(sender:)))
        self.tapGestureRecognizer.numberOfTapsRequired = 2
        addTap()
        
        self.paintSelectTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapPaintSelection(sender:)))
        addTap()
        
        self.longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(sender:)))
        addLongPress()
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(didPinch(sender:)))
        self.addGestureRecognizer(pinchGestureRecognizer)
        self.pinchGestureRecognizer = pinchGestureRecognizer
        self.pinchGestureRecognizer.delegate = self
        
        self.drawGestureRecognizer = UIDrawGestureRecognizer(target: self, action: #selector(didDraw(sender:)))
        
        // additional gesture setup
        // Make the pinch recognizer more sensitive
        pinchGestureRecognizer.delaysTouchesBegan = false
        pinchGestureRecognizer.delaysTouchesEnded = false
        
        // Ensure the pinch can interrupt the pan
        panGestureRecognizer.cancelsTouchesInView = false
        
        /*Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { (tmr) in
            let rT = arc4random() % 20 + 1
            Timer.scheduledTimer(withTimeInterval: Double(rT), repeats: false) { (tmr) in
                self.simulateDraw()
            }
        }*/
    }
    
    /*func simulateDraw() {
        let smallAmt = Int(arc4random() % 20) + 2
        let bigAmt = Int(arc4random() % 100) + 50
        
        startPainting()
        
        let r = arc4random() % 10
        
        if r < 2 {
            for _ in 0...smallAmt - 1 {
                let rX = Int(arc4random() % UInt32(interactiveCanvas.cols))
                let rY = Int(arc4random() % UInt32(interactiveCanvas.rows))
                interactiveCanvas.paintUnitOrUndo(x: rX, y: rY, mode: 0)
            }
        }
        else {
            for _ in 0...bigAmt - 1 {
                let rX = Int(arc4random() % UInt32(interactiveCanvas.cols))
                let rY = Int(arc4random() % UInt32(interactiveCanvas.rows))
                interactiveCanvas.paintUnitOrUndo(x: rX, y: rY, mode: 0)
            }
        }
        
        endPainting(accept: true)
    }*/
    
    // draw
    @objc func didDraw(sender: UIDrawGestureRecognizer) {
        let location = sender.location(in: self)
        let view = sender.view!
        
        if sender.state == .began {
            if mode == .painting {
                if palettesDelegate != nil && palettesDelegate!.isPalettesViewControllerVisible() {
                    palettesDelegate?.notifyClosePalettesViewController()
                    return
                }
                
                //interactiveCanvas.drawCallback?.notifyCanvasRedraw()
                
                paintActionDelegate?.notifyPaintActionStarted()
                
                if (location.x > view.frame.size.width - 50 && !SessionSettings.instance.rightHanded) ||
                    (location.x < 50 && SessionSettings.instance.rightHanded || touchedCanvasEdge) {
                    canvasEdgeTouchDelegate?.onTouchCanvasEdge()
                    touchedCanvasEdge = true
                    return
                }
                
                let unitPoint = interactiveCanvas.unitForScreenPoint(x: location.x, y: location.y)
                interactiveCanvas.paintUnit(x: Int(unitPoint.x), y: Int(unitPoint.y))
                
                if interactiveCanvas.restorePoints.count == 1 {
                    paintDelegate?.notifyPaintingStarted()
                }
                else if interactiveCanvas.restorePoints.count == 0 {
                    paintDelegate?.notifyPaintingEnded(accept: false)
                }
            }
            else if mode == .paintSelectionExploring || mode == .paintSelectionPainting {
                let unitPoint = interactiveCanvas.unitForScreenPoint(x: location.x, y: location.y)
                let x = Int(unitPoint.x)
                let y = Int(unitPoint.y)
                
                if x >= 0 && x < interactiveCanvas.cols && y >= 0 && y < interactiveCanvas.rows {
                    var color = interactiveCanvas.arr[y][x]
                    if color == 0 {
                        color = UIColor.black.argb()
                    }
                    SessionSettings.instance.paintColor = color
                    paintDelegate?.notifyPaintColorUpdate()
                }
            }
            else if mode == .exporting || mode == .objectMoveSelection {
                let unitPoint = interactiveCanvas.unitForScreenPoint(x: location.x, y: location.y)
                
                if interactiveCanvas.isCanvas(unitPoint: unitPoint) {
                    objectSelectionStartUnit = unitPoint
                    objectSelectionStartPoint = location
                }
                
                // interactiveCanvas.exportSelection(unitPoint: unitPoint)
            }
        }
        else if sender.state == .changed {
            if mode == .painting {
                if touchedCanvasEdge {
                    return
                }
                
                let unitPoint = interactiveCanvas.unitForScreenPoint(x: location.x, y: location.y)
                interactiveCanvas.paintUnit(x: Int(unitPoint.x), y: Int(unitPoint.y))
                
                if interactiveCanvas.restorePoints.count == 1 {
                    paintDelegate?.notifyPaintingStarted()
                }
                else if interactiveCanvas.restorePoints.count == 0 {
                    paintDelegate?.notifyPaintingEnded(accept: false)
                }
            }
            else if mode == .exporting || mode == .objectMoveSelection {
                let unitPoint = interactiveCanvas.unitForScreenPoint(x: location.x, y: location.y)
                
                if interactiveCanvas.isCanvas(unitPoint: unitPoint) {
                    let minX = fmin(location.x, objectSelectionStartPoint.x)
                    let minY = fmin(location.y, objectSelectionStartPoint.y)
                    
                    let maxX = fmax(location.x, objectSelectionStartPoint.x)
                    let maxY = fmax(location.y, objectSelectionStartPoint.y)
                    
                    objectSelectionDelegate?.notifyObjectSelectionBoundsChanged(upperLeft: CGPoint(x: minX, y: minY), lowerRight: CGPoint(x: maxX, y: maxY))
                }
            }
        }
        else if sender.state == .ended {
            if mode == .exporting || mode == .objectMoveSelection {
                let unitPoint = interactiveCanvas.unitForScreenPoint(x: location.x, y: location.y)
                
                if interactiveCanvas.isCanvas(unitPoint: unitPoint) {
                    if unitPoint.x == objectSelectionStartUnit.x && unitPoint.y == objectSelectionStartUnit.y {
                        if mode == .exporting {
                            if interactiveCanvas.server.isAdmin {
                                interactiveCanvas.erasePixels(startUnit: unitPoint, endUnit: unitPoint)
                            }
                            else {
                                interactiveCanvas.exportSelection(unitPoint: unitPoint)
                            }
                        }
                        else if mode == .objectMoveSelection {
                            let valid = interactiveCanvas.startMoveSelection(unitPoint: unitPoint)
                            
                            if valid {
                                startObjectMove()
                            }
                        }
                    }
                    else {
                        let minX = fmin(unitPoint.x, objectSelectionStartUnit.x)
                        let minY = fmin(unitPoint.y, objectSelectionStartUnit.y)
                        
                        let maxX = fmax(unitPoint.x, objectSelectionStartUnit.x)
                        let maxY = fmax(unitPoint.y, objectSelectionStartUnit.y)
                        
                        let startUnit = CGPoint(x: minX, y: minY)
                        let endUnit = CGPoint(x: maxX, y: maxY)
                        
                        if mode == .exporting {
                            if interactiveCanvas.server.isAdmin {
                                interactiveCanvas.erasePixels(startUnit: startUnit, endUnit: endUnit)
                            }
                            else {
                                interactiveCanvas.exportSelection(startUnit: startUnit, endUnit: endUnit)
                            }
                        }
                        else if mode == .objectMoveSelection {
                            let valid = interactiveCanvas.startMoveSelection(startUnit: startUnit, endUnit: endUnit)
                            
                            if valid {
                                startObjectMove()
                            }
                        }
                    }
                    objectSelectionDelegate?.notifyObjectSelectionEnded()
                }
            }
            else if mode == .painting {
                touchedCanvasEdge = false
            }
        }
    }
    
    func setInitalPositionAndScale() {
        // scale
        if SessionSettings.instance.restoreCanvasScaleFactor == CGFloat(0) {
            self.scaleFactor = interactiveCanvas.startScaleFactor
        }
        else {
            self.scaleFactor = SessionSettings.instance.restoreCanvasScaleFactor
        }
        
        self.interactiveCanvas.scaleFactor = self.scaleFactor
        self.interactiveCanvas.ppu = Int(CGFloat(interactiveCanvas.basePpu) * self.scaleFactor)
        
        // position
        if SessionSettings.instance.restoreDeviceViewportCenterX == 0.0 {
            interactiveCanvas.updateDeviceViewport(screenSize: self.frame.size, canvasCenterX: CGFloat(SessionSettings.instance.canvasSize / 2), canvasCenterY: CGFloat(SessionSettings.instance.canvasSize / 2))
        }
        else {
            interactiveCanvas.updateDeviceViewport(screenSize: self.frame.size, canvasCenterX: SessionSettings.instance.restoreDeviceViewportCenterX, canvasCenterY: SessionSettings.instance.restoreDeviceViewportCenterY)
        }
    }
    
    func addPan() {
        if !hasGestureRecognizer(gestureRecognizer: self.panGestureRecognizer) {
            self.addGestureRecognizer(self.panGestureRecognizer)
            self.panGestureRecognizer.delegate = self
        }
    }
    
    func addTap() {
        if !hasGestureRecognizer(gestureRecognizer: self.tapGestureRecognizer) {
            self.addGestureRecognizer(self.tapGestureRecognizer)
        }
    }
    
    func addPaintSelectionTap() {
        if !hasGestureRecognizer(gestureRecognizer: self.paintSelectTapGestureRecognizer) {
            self.addGestureRecognizer(self.paintSelectTapGestureRecognizer)
        }
    }
    
    func addLongPress() {
        if !hasGestureRecognizer(gestureRecognizer: self.longPressGestureRecognizer) {
            self.addGestureRecognizer(self.longPressGestureRecognizer)
        }
    }
    
    func removePan() {
        self.removeGestureRecognizer(self.panGestureRecognizer)
    }
    
    func removeTap() {
        self.removeGestureRecognizer(self.tapGestureRecognizer)
    }
    
    func removePaintSelectionTap() {
        self.removeGestureRecognizer(self.paintSelectTapGestureRecognizer)
    }
    
    func removeLongPress() {
        self.removeGestureRecognizer(self.longPressGestureRecognizer)
    }
    
    func addDraw() {
        if !hasGestureRecognizer(gestureRecognizer: self.drawGestureRecognizer) {
            self.addGestureRecognizer(self.drawGestureRecognizer)
        }
    }
    
    func removeDraw() {
        self.removeGestureRecognizer(self.drawGestureRecognizer)
    }
    
    func hasGestureRecognizer(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizers == nil {
            return false
        }
        
        for gr in self.gestureRecognizers! {
            if gr == gestureRecognizer {
                return true
            }
        }
        
        return false
    }
    
    // pan
    @objc func didPan(sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            lastPanTranslationX = 0
            lastPanTranslationY = 0
        }
        else if sender.state == .changed {
            let translation = sender.translation(in: self)
            
            let translateX = lastPanTranslationX - translation.x
            let translateY = lastPanTranslationY - translation.y
            
            if mode == .exploring || mode == .paintSelectionExploring {
                interactiveCanvas.pixelHistoryDelegate?.notifyHidePixelHistory()
            }
            else if mode == .painting {
                
            }
            
            interactiveCanvas.translateBy(x: translateX, y: translateY)
            
            gestureDelegate?.notifyInteractiveCanvasPan()
            
            lastPanTranslationX = translation.x
            lastPanTranslationY = translation.y
        }
    }
    
    // tap
    @objc func didTap(sender: UITapGestureRecognizer) {
        let location = sender.location(in: self)
        
        if interactiveCanvas.world {
            gestureDelegate?.notifyInteractiveCanvasDoubleTap()
        }
        else {
            canvasFrameDelegate?.notifyCloseCanvasFrameView()
        }
    }
    
    // paint selection tap
    @objc func didTapPaintSelection(sender: UITapGestureRecognizer) {
        let location = sender.location(in: self)
        
        let unitPoint = interactiveCanvas.unitForScreenPoint(x: location.x, y: location.y)
        
        let x = Int(unitPoint.x)
        let y = Int(unitPoint.y)
        
        if x >= 0 && x < interactiveCanvas.cols && y >= 0 && y < interactiveCanvas.rows {
            var color = interactiveCanvas.arr[y][x]
            if color == 0 {
                color = UIColor.black.argb()
            }
            SessionSettings.instance.paintColor = color
            paintDelegate?.notifyPaintColorUpdate()
        }
    }
    
    // long press
    @objc func didLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let location = sender.location(in: self)
            
            let unitPoint = interactiveCanvas.unitForScreenPoint(x: location.x, y: location.y)
            
            if !interactiveCanvas.isBackground(unitPoint: unitPoint) {
                self.interactiveCanvas.getPixelHistoryForUnitPoint(unitPoint: unitPoint) { (success, data) in
                    self.interactiveCanvas.pixelHistoryDelegate?.notifyShowPixelHistory(data: data, screenPoint: location)
                }
            }
            
//            if !interactiveCanvas.world {
//                canvasFrameDelegate?.notifyToggleCanvasFrameView(canvasX: Int(unitPoint.x), canvasY: Int(unitPoint.y), screenPoint: location)
//            }
        }
    }
    
    // pinch
    @objc func didPinch(sender: UIPinchGestureRecognizer) {
        if sender.state == .began {
            startScaleFactor = scaleFactor
        }
        else if sender.state == .changed {
            let scale = sender.scale
            
            oldScaleFactor = scaleFactor
            scaleFactor = scale * startScaleFactor
            
            scaleFactor = CGFloat(max(interactiveCanvas.minScaleFactor, min(scaleFactor, interactiveCanvas.maxScaleFactor)))
            interactiveCanvas.scaleFactor = scaleFactor
            
            oldPpu = interactiveCanvas.ppu
            interactiveCanvas.ppu = Int((CGFloat(interactiveCanvas.basePpu) * scaleFactor))
            
            interactiveCanvas.updateDeviceViewport(screenSize: self.frame.size, fromScale: true)
            gestureDelegate?.notifyInteractiveCanvasScale()
            
            interactiveCanvas.drawCallback?.notifyCanvasRedraw()
        }
    }
    
    // scale callback
    func notifyScaleCancelled() {
        scaleFactor = oldScaleFactor
        interactiveCanvas.ppu = oldPpu
    }
    
    func startPainting() {
        if mode == .objectMoveSelection || mode == .objectMoving {
            interactiveCanvas.cancelMoveSelectedObject()
        }
        
        if mode == .exploring {
            mode = .painting
        }
        else if mode == .paintSelectionExploring {
            mode = .paintSelectionPainting
        }
        
        removePan()
        removeTap()
        removeLongPress()
        
        addDraw()
    }
    
    func endPainting(accept: Bool) {
        if !accept {
            if interactiveCanvas.restorePoints.count > 0 {
                interactiveCanvas.undoPendingPaint()
                SessionSettings.instance.dropsAmt += interactiveCanvas.restorePoints.count
                
                interactiveCanvas.drawCallback?.notifyCanvasRedraw()
            }
        }
        else {
            //interactiveCanvas.commitPixels()
        }
        
        paintDelegate?.notifyPaintingEnded(accept: accept)
        
        if mode == .painting {
            mode = .exploring
        }
        else if mode == .paintSelectionPainting {
            mode = .paintSelectionExploring
        }
        
        removeDraw()
        
        addPan()
        addTap()
        addLongPress()
    }
    
    func startPaintSelection() {
        if mode == .exploring {
            mode = .paintSelectionExploring
            removeTap()
        }
        else if mode == .painting {
            mode = .paintSelectionPainting
        }
        addPaintSelectionTap()
    }
    
    func endPaintSelection() {
        if mode == .paintSelectionExploring {
            mode = .exploring
            addTap()
        }
        else if mode == .paintSelectionPainting {
            mode = .painting
        }
        removePaintSelectionTap()
    }
    
    func startExporting() {
        self.mode = .exporting
        
        removePan()
        removeTap()
        removeLongPress()
        
        addDraw()
    }
    
    func endExporting() {
        self.mode = .exploring
        
        addPan()
        addTap()
        addLongPress()
        
        removeDraw()
    }
    
    func startObjectMoveSelection() {
        mode = .objectMoveSelection
        
        removePan()
        removeTap()
        removeLongPress()
        
        addDraw()
    }
    
    func startObjectMove() {
        mode = .objectMoving
        
        addPan()
        
        removeDraw()
    }
    
    func endObjectMove() {
        mode = .exploring
        
        addPan()
        addTap()
        addLongPress()
        
        removeDraw()
    }
    
    func isExporting() -> Bool {
        return mode == .exporting
    }
    
    func isObjectMoving() -> Bool {
        return mode == .objectMoving
    }
    
    func isObjectMoveSelection() -> Bool {
        return mode == .objectMoveSelection
    }
    
    func createCanvasFrame(centerX: Int, centerY: Int, width: Int, height: Int, color: Int32) {
        startPainting()
        
        let oldColor = SessionSettings.instance.paintColor
        SessionSettings.instance.paintColor = color
        
        var minX = centerX - width / 2
        var maxX = centerX + width / 2 + 1
        var minY = centerY - height / 2
        var maxY = centerY + height / 2 + 1
        
        if width % 2 != 0 {
            minX = centerX - (width + 1) / 2
            maxX = centerX + (width + 1) / 2
        }
        
        if height % 2 != 0 {
            minY = centerY - (height + 1) / 2
            maxY = centerY + (height + 1) / 2
        }
        
//        // left
//        for y in minY...maxY {
//            interactiveCanvas.paintUnitOrUndo(x: minX, y: y, redraw: false)
//        }
//        // right
//        for y in minY...maxY {
//            interactiveCanvas.paintUnitOrUndo(x: maxX, y: y, redraw: false)
//        }
//        // top
//        for x in minX...maxX {
//            interactiveCanvas.paintUnitOrUndo(x: x, y: minY, redraw: false)
//        }
//        // bottom
//        for x in minX...maxX {
//            interactiveCanvas.paintUnitOrUndo(x: x, y: maxY, redraw: false)
//        }
        
        SessionSettings.instance.paintColor = oldColor
        
        endPainting(accept: true)
        interactiveCanvas.drawCallback?.notifyCanvasRedraw()
    }
    
    func resetDeviceViewport() {
        SessionSettings.instance.restoreDeviceViewportCenterX = 0
        SessionSettings.instance.restoreCanvasScaleFactor = 0
        
        setInitalPositionAndScale()
    }
    
    private func screenBoundsForSelectedObject() -> CGRect {
        let selectedStartUnit = interactiveCanvas.cSelectedStartUnit!
        let selectedStartUnitScreen = interactiveCanvas.screenPointForUnit(unitPoint: selectedStartUnit)
        
        let selectedEndUnit = interactiveCanvas.cSelectedEndUnit!
        let selectedEndUnitScreen = interactiveCanvas.screenPointForUnit(unitPoint: selectedEndUnit)
        
        let width = selectedEndUnitScreen.x - selectedStartUnitScreen.x + CGFloat(interactiveCanvas.ppu)
        let height = selectedEndUnitScreen.y - selectedStartUnitScreen.y + CGFloat(interactiveCanvas.ppu)
        
        var bounds = CGRect(x: selectedStartUnitScreen.x, y: selectedStartUnitScreen.y, width: width, height: height)
        
        let minWidth: CGFloat = 60
        let minHeight: CGFloat = 60
        
        if width < minWidth {
            let diff = minWidth - width
            bounds = CGRect(x: bounds.origin.x - diff / 2, y: bounds.origin.y, width: 60, height: bounds.size.height)
        }
        
        if height < minHeight {
            let diff = minHeight - height
            bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y - diff / 2, width: bounds.width, height: 60)
        }
        
        return bounds
    }
    
    // selected object delegate
    func onObjectSelected() {
        
    }
    
    func onSelectedObjectMoveStart() {
        let bounds = screenBoundsForSelectedObject()
        selectedObjectMoveView?.showSelectedObjectMoveButtons(bounds: bounds)
    }
    
    func onSelectedObjectMoved() {
        let bounds = screenBoundsForSelectedObject()
        selectedObjectMoveView?.updateSelectedObjectMoveButtons(bounds: bounds)
        
        let cX = bounds.origin.x + bounds.size.width / 2
        let cY = bounds.origin.y + bounds.size.height / 2
        
        if interactiveCanvas.hasSelectedObjectMoved() {
            selectedObjectView?.showSelectedObjectYesAndNoButtons(screenPoint: CGPoint(x: cX, y: cY))
        }
        else {
            selectedObjectView?.hideSelectedObjectYesAndNoButtons()
        }
    }
    
    func onSelectedObjectMoveEnd() {
        endObjectMove()
        
        selectedObjectMoveView?.hideSelectedObjectMoveButtons()
        selectedObjectMoveView?.selectedObjectMoveEnded()
        
        selectedObjectView?.hideSelectedObjectYesAndNoButtons()
        selectedObjectView?.selectedObjectEnded()
    }
    
    private var redrawLoopTask: Task<(), any Error>? = nil
    
    // draw callback
    func notifyCanvasRedraw() {
        if self.interactiveCanvas.errorPixels.count > 0 && self.redrawLoopTask == nil {
            self.redrawLoopTask = Task {
                while self.interactiveCanvas.errorPixels.count > 0 && !Task.isCancelled {
                    self.setNeedsDisplay()
                    try await Task.sleep(for: .milliseconds(1000 / 30))
                }
                self.redrawLoopTask?.cancel()
                self.redrawLoopTask = nil
            }
        }
        else {
            self.setNeedsDisplay()
        }
    }
    
    // drawing
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            print("could not get graphics context")
            return
        }
        
        context.setShouldAntialias(false)
        
        drawInteractiveCanvas(ctx: context)
        redrawCount += 1
    }
    
    func drawInteractiveCanvas(ctx: CGContext) {
        let startTime = Date().timeIntervalSince1970
        let deviceViewport = interactiveCanvas.deviceViewport!
        let ppu = interactiveCanvas.ppu!
        
        drawUnits(ctx: ctx, deviceViewport: deviceViewport, ppu: ppu)
        drawErrorPixels(ctx: ctx)
        
        if interactiveCanvas.ppu >= interactiveCanvas.gridLineThreshold {
            drawGridLines(ctx: ctx, deviceViewport: deviceViewport, ppu: ppu)
        }
        print("redraw interactive canvas")
        //print("draw time (1 / " + String(1 / (Date().timeIntervalSince1970 - startTime)) + " secs)")
    }
    
    func drawGridLines(ctx: CGContext, deviceViewport: CGRect, ppu: Int) {
        if ppu > interactiveCanvas.gridLineThreshold && SessionSettings.instance.showGridLines {
            let gridLineColor = interactiveCanvas.getGridLineColor()
            ctx.setLineWidth(1.0)
            
            ctx.setStrokeColor(UIColor(argb: gridLineColor).withAlphaComponent(0.5).cgColor)
            
            let unitsWide = Int(self.frame.size.width) / ppu
            let unitsTall = Int(self.frame.size.height) / ppu
            
            let gridXOffsetPx = ((ceil(deviceViewport.origin.x)) - deviceViewport.origin.x) * CGFloat(ppu)
            let gridYOffsetPx = ((ceil(deviceViewport.origin.y)) - deviceViewport.origin.y) * CGFloat(ppu)
            
            for y in 0...unitsTall {
                let curY = CGFloat(y * ppu) + gridYOffsetPx
//                if Int(curY) % 10 != 0 {
//                    ctx.setStrokeColor(UIColor(argb: gridLineColor).withAlphaComponent(0.5).cgColor)
//                }
//                else {
//                    ctx.setStrokeColor(UIColor(argb: gridLineColor).cgColor)
//                }
//                print("\(curY)")
                drawLine(ctx: ctx, s: CGPoint(x: 0.0, y: curY), e: CGPoint(x: self.frame.size.width, y: curY))
                
                ctx.drawPath(using: .stroke)
            }
            
            for x in 0...unitsWide {
                let curX = CGFloat(x * ppu) + gridXOffsetPx
                drawLine(ctx: ctx, s: CGPoint(x: curX, y: 0.0), e: CGPoint(x: curX, y: self.frame.size.height))
                
                ctx.drawPath(using: .stroke)
            }
        }
    }
    
    func drawErrorPixels(ctx: CGContext) {
        var interactiveCanvas = self.interactiveCanvas!
        
        for pixel in interactiveCanvas.errorPixels {
            let rect = self.interactiveCanvas.getScreenSpaceForUnit(x: pixel.x, y: pixel.y)
            ctx.setFillColor(pixel.getColor())
            ctx.addRect(rect)
            ctx.drawPath(using: .fill)
        }
        
        var i = 0
        while i < interactiveCanvas.errorPixels.count {
            let pixel = interactiveCanvas.errorPixels[i]
            if !pixel.isActive {
                interactiveCanvas.errorPixels.remove(at: i)
                i -= 1
            }
            i += 1
        }
        print("Error pixel count: ic var \(self.interactiveCanvas.errorPixels.count)")
    }
    
    func drawUnits(ctx: CGContext, deviceViewport: CGRect, ppu: Int) {
        let startUnitIndexX = Int(floor(deviceViewport.origin.x))
        let startUnitIndexY = Int(floor(deviceViewport.origin.y))
        let endUnitIndexX = Int(ceil(deviceViewport.origin.x + deviceViewport.size.width))
        let endUnitIndexY = Int(ceil(deviceViewport.origin.y + deviceViewport.size.height))
        
        let rangeX = endUnitIndexX - startUnitIndexX
        let rangeY = endUnitIndexY - startUnitIndexY
        
        let isObjectSelected = interactiveCanvas.selectedPixels != nil
        
        let backgroundColors = interactiveCanvas.getBackgroundColors(index: SessionSettings.instance.backgroundColorIndex)!
        
        let primaryBackground = UIColor(argb: backgroundColors.primary).cgColor
        let secondaryBackground = UIColor(argb: backgroundColors.secondary).cgColor
        
        for x in 0...rangeX {
            for y in 0...rangeY {
                let unitX = x + startUnitIndexX
                let unitY = y + startUnitIndexY
                
                var fillColor: CGColor!
                
                if unitX >= 0 && unitX < interactiveCanvas.cols && unitY >= 0 && unitY < interactiveCanvas.rows {
                    let color = interactiveCanvas.arr[unitY][unitX]
                    
                    if color == 0 {
                        if ((unitX + unitY) % 2 == 0) {
                            fillColor = primaryBackground
                        }
                        else {
                            fillColor = secondaryBackground
                        }
                    }
                    else {
                        fillColor = UIColor(argb: color).cgColor
                    }
                }
                else {
                    fillColor = UIColor.darkGray.cgColor
                }
                
                if isObjectSelected {
                    let newColor = Utils.brightenColor(color: UIColor(cgColor: fillColor).argb(), by: -0.5)
                    fillColor = UIColor(argb: newColor).cgColor
                }
                
                ctx.setFillColor(fillColor)
                ctx.addRect(interactiveCanvas.getScreenSpaceForUnit(x: unitX, y: unitY))
                ctx.drawPath(using: .fill)
            }
        }
        
        // selected object
        if isObjectSelected {
            let selectedPixels = interactiveCanvas.selectedPixels!
            for pixel in selectedPixels {
                let x = pixel.x
                let y = pixel.y
                
                if x >= startUnitIndexX && x <= endUnitIndexX && y >= startUnitIndexY && y <= endUnitIndexY {
                    ctx.setFillColor(UIColor(argb: pixel.color).cgColor)
                    ctx.addRect(interactiveCanvas.getScreenSpaceForUnit(x: x, y: y))
                    ctx.drawPath(using: .fill)
                }
            }
        }
    }
    
    func drawLine(ctx: CGContext, s: CGPoint, e: CGPoint) {
        ctx.move(to: s)
        ctx.addLine(to: e)
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool { true }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool { true }
}
