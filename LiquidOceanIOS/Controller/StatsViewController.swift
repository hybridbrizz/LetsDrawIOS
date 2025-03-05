//
//  StatsViewController.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 2/22/21.
//  Copyright © 2021 Eric Versteeg. All rights reserved.
//

import UIKit

class StatsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var backAction: ActionButtonView!
    @IBOutlet weak var backActionLeading: NSLayoutConstraint!
    
    @IBOutlet weak var iconContainer: UIView!
    @IBOutlet weak var iconBackground: UIView!
    
    @IBOutlet weak var iconContainerHeight: NSLayoutConstraint!
    
    var initial = true
    
    var data: [[String: String]]?
    
    let statKeys = ["Pixels Single", "Pixels World", "Pixel Overwrites In", "Pixel Overwrites Out", "Paint Accrued", "World Level"]
    
    let achKeys = ["Pixels Single", "Pixels World", "Pixel Overwrites In", "Pixel Overwrites Out", "Paint Accrued"]
    
    let eventTypes = [StatTracker.EventType.pixelPaintedSingle, StatTracker.EventType.pixelPaintedWorld,
    StatTracker.EventType.pixelOverwriteIn, StatTracker.EventType.pixelOverwriteOut, StatTracker.EventType.paintReceived]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackground()
        
        backAction.type = .backSolid
        
        backAction.setOnClickListener {
            self.performSegue(withIdentifier: "UnwindToMenu", sender: nil)
        }
        
        data = [[String: String]]()
        
        data!.append([String: String]())
        
        data![0]["Pixels Single"] = String(StatTracker.instance.numPixelsPaintedSingle)
        data![0]["Pixels World"] = String(StatTracker.instance.numPixelsPaintedWorld)
        data![0]["Pixel Overwrites In"] = String(StatTracker.instance.numPixelOverwritesIn)
        data![0]["Pixel Overwrites Out"] = String(StatTracker.instance.numPixelOverwritesOut)
        data![0]["Paint Accrued"] = String(StatTracker.instance.totalPaintAccrued)
        data![0]["World Level"] = String(StatTracker.instance.getWorldLevel())
        
        data!.append([String: String]())
        
        data![1]["Pixels Single"] = StatTracker.instance.getAchievementProgressString(eventType: .pixelPaintedSingle)
        data![1]["Pixels World"] = StatTracker.instance.getAchievementProgressString(eventType: .pixelPaintedWorld)
        data![1]["Pixel Overwrites In"] = StatTracker.instance.getAchievementProgressString(eventType: .pixelOverwriteIn)
        data![1]["Pixel Overwrites Out"] = StatTracker.instance.getAchievementProgressString(eventType: .pixelOverwriteOut)
        data![1]["Paint Accrued"] = StatTracker.instance.getAchievementProgressString(eventType: .paintReceived)
        
        self.collectionView.reloadData()
        
        let tgr = UITapGestureRecognizer(target: self, action: #selector(didTapIconBackground))
        iconBackground.addGestureRecognizer(tgr)
    }
    
    override func viewDidLayoutSubviews() {
        if backAction.frame.origin.x < 0 {
            backActionLeading.constant += 20
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if view.frame.size.height <= 600 {
            let headerView = collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader)[0]
            Animator.animateTitleFromTop(titleView: headerView)
            
            var i = 0
            for visibleCell in collectionView.visibleCells {
                Animator.animateHorizontalViewEnter(view: visibleCell, left: i % 2 == 0)
                i += 1
            }
        }
        
        initial = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.OrientationUtility.lockOrientation(UIInterfaceOrientationMask.landscape)
    }
    
    @objc func didTapIconBackground() {
        for v in iconContainer.subviews {
            v.removeFromSuperview()
        }
        
        iconBackground.isHidden = true
        
        if iconContainer.layer.sublayers != nil && iconContainer.layer.sublayers!.count > 0 {
            iconContainer.layer.sublayers![0].removeFromSuperlayer()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        if data != nil {
            count = data![section].count
        }
        
        return count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatAchievementCell", for: indexPath) as! StatAchievementCollectionViewCell
        
        var key = ""
        if indexPath.section == 0 {
            key = statKeys[indexPath.item]
        }
        else if indexPath.section == 1 {
            key = achKeys[indexPath.item]
        }
        
        cell.statName.text = key
        
        cell.statAmt.text = data![indexPath.section][key]
        
        if indexPath.section == 0 {
            let val = Int(data![indexPath.section][key]!)!
            let formatted = String(format: "%ld", locale: Locale.current, val)
            
            cell.statAmt.text = formatted
        }
        
        if indexPath.item < 6 && initial && view.frame.size.height <= 600 {
            cell.isHidden = true
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let eventType = eventTypes[indexPath.item]
            let thresholdsPassed = StatTracker.instance.thresholdsPassed(eventType: eventType)
            
            let cHeight = (thresholdsPassed / 8 * 55) + 60
            
            iconContainerHeight.constant = CGFloat(cHeight)
            
            if thresholdsPassed > 0 {
                for t in 0...thresholdsPassed - 1 {
                    let margin = 5
                    let size = 50
                    
                    let x = (t % 8) * size + (t % 8) * margin + margin
                    let y = (t / 8) * size + (t / 8) * margin + margin
                    
                    let icon = AchievementIcon(frame: CGRect(x: x, y: y, width: size, height: size))
                    icon.setType(achievementType: eventType, thresholds: t + 1)
                    
                    iconContainer.addSubview(icon)
                }
                
                setIconContainerBackground(frame: CGRect(x: 0, y: 0, width: iconContainer.frame.size.width, height: CGFloat(cHeight)))
            }
            
            iconBackground.isHidden = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "StatHeaderView", for: indexPath) as! ActionViewReusableView
        
        if indexPath.section == 0 {
            if initial && self.view.frame.size.height <= 600 {
                view.isHidden = true
            }
            
            view.actionView.selectable = false
            view.actionView.type = .stats
            view.actionViewWidth.constant = 160
        }
        else {
            view.actionView.selectable = false
            view.actionView.type = .achievements
            view.actionViewWidth.constant = 408
        }
        
        return view
    }
    
    func setBackground() {
        let gradient = CAGradientLayer()

        gradient.frame = view.bounds
        gradient.colors = [UIColor(argb: Utils.int32FromColorHex(hex: "0xff000000")).cgColor, UIColor(argb: Utils.int32FromColorHex(hex: "0xff333333")).cgColor]
        
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)

        view.layer.insertSublayer(gradient, at: 0)
    }
    
    func setIconContainerBackground(frame: CGRect) {
        let gradient = CAGradientLayer()

        gradient.frame = frame
        gradient.colors = [UIColor(argb: Utils.int32FromColorHex(hex: "0xff242e8f")).cgColor, UIColor(argb: Utils.int32FromColorHex(hex: "0xff8f3234")).cgColor]
        
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)

        iconContainer.layer.insertSublayer(gradient, at: 0)
    }
}
