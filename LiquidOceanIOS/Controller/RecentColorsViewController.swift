//
//  RecentColorsViewController.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 2/18/21.
//  Copyright © 2021 Eric Versteeg. All rights reserved.
//

import UIKit

protocol RecentColorsDelegate: AnyObject {
    func notifyRecentColorSelected(color: Int32)
}

class RecentColorsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    var data: [Int32]?
    
    var itemMargin = CGFloat(10)
    
    var itemWidth = CGFloat(32)
    
    var isStatic = false
    
    weak var delegate: RecentColorsDelegate?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.OrientationUtility.lockOrientation(UIInterfaceOrientationMask.landscape)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if data != nil {
            if data!.count == 1 {
                return 2
            }
            else {
                return data!.count
            }
        }
        else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.itemWidth, height: self.itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecentColorCell", for: indexPath) as! RecentColorCollectionViewCell
        
        // fix for centered single cell
        if indexPath.item >= self.data!.count {
            cell.actionView.type = .none
        }
        else {
            cell.actionView.type = .recentColor
            cell.actionView.representingColor = self.data![indexPath.item]
        }
        
        cell.actionView.isStatic = isStatic
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return self.itemMargin
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return self.itemMargin
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item < self.data!.count {
            SessionSettings.instance.paintColor = self.data![indexPath.item]
            delegate?.notifyRecentColorSelected(color: self.data![indexPath.item])
        }
    }
}
