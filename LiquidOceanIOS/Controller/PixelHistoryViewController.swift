//
//  PixelHistoryViewController.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 2/16/21.
//  Copyright © 2021 Eric Versteeg. All rights reserved.
//

import UIKit

class PixelHistoryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    var server: Server!
    
    var data: [AnyObject]?
    
    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var noDataLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.OrientationUtility.lockOrientation(UIInterfaceOrientationMask.landscape)
    }
    
    var selectedIndices = [IndexPath]()
    
    func clearSelections() {
        self.selectedIndices = [IndexPath]()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        if data != nil {
            if data!.count == 0 {
                self.noDataLabel.isHidden = false
            }
            else {
                self.noDataLabel.isHidden = true
            }
            
            count = data!.count
        }
        else {
            self.noDataLabel.isHidden = false
        }
        
        return count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PixelHistoryItemCell", for: indexPath) as! PixelHistoryCollectionViewCell
        
        let dataObj = data![indexPath.row] as! [String: AnyObject]
        
        let color = dataObj["color"] as! Int32
        var name = dataObj["name"] as! String
        let level = dataObj["level"] as! Int
        let timestamp = dataObj["timestamp"] as! Int
        
        let date = Date(timeIntervalSince1970: Double(timestamp))
        let now = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        
        dateFormatter.dateFormat = "MM-dd-yy"
        
        if self.selectedIndices.contains(indexPath) {
            cell.nameLabel.isHidden = true
            cell.colorView.isHidden = true
            cell.fullDateLabel.isHidden = false
            
            dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
            cell.fullDateLabel.text = dateFormatter.string(from: date)
        }
        else {
            cell.nameLabel.isHidden = false
            cell.colorView.isHidden = false
            cell.fullDateLabel.isHidden = true
            
            cell.colorView.backgroundColor = UIColor(argb: color)
            
            if name.count > 10 {
                name = String(name.prefix(7)) + "..."
            }
            
            cell.nameLabel.text = name
            //cell.nameLabelWidth.constant = name.size(withAttributes: [.font: UIFont.boldSystemFont(ofSize: 24.0)]).width + 5
            
            if name == SessionSettings.instance.firstContributorName {
                cell.nameLabel.textColor = Utils.UIColorFromColorHex(hex: "0xffdecb52")
            }
            else if name == SessionSettings.instance.secondContributorName {
                cell.nameLabel.textColor = Utils.UIColorFromColorHex(hex: "0xffafb3b1")
            }
            else if name == SessionSettings.instance.thirdContributorName {
                cell.nameLabel.textColor = Utils.UIColorFromColorHex(hex: "0xffbd927b")
            }
            else {
                cell.nameLabel.textColor = UIColor.white
            }
            
            //cell.levelLabel.text = " (" + String(level) + ")"
            
//            let days = Calendar.current.ordinality(of: .day, in: .year, for: now)! - Calendar.current.ordinality(of: .day, in: .year, for: date)!
//            let sameYaer = Calendar.current.component(.year, from: date) == Calendar.current.component(.year, from: now)
//            
//            if days == 0 && sameYaer {
//                dateFormatter.dateFormat = "hh:mm a"
//                cell.dateLabel.text = dateFormatter.string(from: date).lowercased()
//            }
//            else if days == 1 && sameYaer {
//                cell.dateLabel.text = "Yesterday"
//            }
//            else if days > 1 && days < 7 {
//                dateFormatter.dateFormat = "EEEE"
//                cell.dateLabel.text = dateFormatter.string(from: date)
//            }
//            else if days < 14 {
//                cell.dateLabel.text = "Week ago"
//            }
//            else if days < 21 {
//                cell.dateLabel.text = "Two weeks ago"
//            }
//            else if days < 28 {
//                cell.dateLabel.text = "Three weeks ago"
//            }
//            else if days <= 31 {
//                cell.dateLabel.text = "Four weeks ago"
//            }
//            else if sameYaer {
//                dateFormatter.dateFormat = "MMMM"
//                cell.dateLabel.text = dateFormatter.string(from: date)
//            }
//            else {
//                dateFormatter.dateFormat = "MM-dd-yy"
//                cell.dateLabel.text = dateFormatter.string(from: date)
//            }
        }
        
        if server.isAdmin {
            let ltgr = JsonObjLongPressGestureRecognizer(target: self, action: #selector(longTappedName))
            ltgr.jsonObj = dataObj
            cell.addGestureRecognizer(ltgr)
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 240, height: 45)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.selectedIndices.contains(indexPath) {
            if let selectedIndexPathIndex = self.selectedIndices.firstIndex(of: indexPath) {
                self.selectedIndices.remove(at: selectedIndexPathIndex)
            }
        }
        else {
            self.selectedIndices.append(indexPath)
        }
        
        collectionView.reloadData()
    }
    
    class JsonObjLongPressGestureRecognizer: UILongPressGestureRecognizer {
        var jsonObj: [String: AnyObject]!
    }
    
    @objc func longTappedName(sender: JsonObjLongPressGestureRecognizer) {
        if (sender.state != .began) {
            return
        }
        
        let jsonObj = sender.jsonObj!
        
        let alertController = UIAlertController(title: nil, message: "Ban \(jsonObj["name"] as! String)?", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { action in
            let alertController2 = UIAlertController(title: nil, message: "Confirm ban on \(jsonObj["name"] as! String)?", preferredStyle: .alert)
            
            alertController2.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { action in
                URLSessionHandler.instance.banDeviceIps(server: self.server, deviceId: jsonObj["device_id"] as! Int) { response in
                    if response == nil {
                        let alertController3 = UIAlertController(title: nil, message: "Ban failed (server error).", preferredStyle: .alert)
                        
                        alertController3.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                            alertController3.dismiss(animated: true, completion: nil)
                        }))
                        
                        self.present(alertController3, animated: true, completion: nil)
                        
                        return
                    }
                    
                    let alertController3 = UIAlertController(title: nil, message: "Banned \(jsonObj["name"] as! String) (\(response!["ips"] as! Int) IPs).", preferredStyle: .alert)
                    
                    alertController3.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                        alertController3.dismiss(animated: true, completion: nil)
                    }))
                    
                    self.present(alertController3, animated: true, completion: nil)
                }
            }))
            alertController2.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                alertController2.dismiss(animated: true, completion: nil)
            }))
            
            self.present(alertController2, animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            alertController.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
}
