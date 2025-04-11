//
//  HelpMessagesViewController.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 3/22/25.
//  Copyright © 2025 Eric Versteeg. All rights reserved.
//

import Foundation
import UIKit

protocol HelpMessagesDelegate: AnyObject {
    func requestCloseHelpMessages()
}

class HelpMessagesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var closeLabel: UILabel!
    
    weak var delegate: HelpMessagesDelegate? = nil
    
    private let viewModel = HelpViewModel()
    
    private var helpMessages = [HelpMessage]()
    
    override func viewDidLoad() {
        helpMessages = viewModel.getHelpMessages()
        collectionView.reloadData()
        
        let closeTGR = UITapGestureRecognizer(target: self, action: #selector(didTapClose))
        closeLabel.addGestureRecognizer(closeTGR)
        
        collectionView.backgroundColor = UIColor.white
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return helpMessages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HelpMessageView", for: indexPath) as! HelpMessageViewCell
        
        cell.msg.text = "\(indexPath.item + 1).) \(helpMessages[indexPath.item].msg)"
        cell.msg.font = UIFont(name: "Inter-Medium", size: 14)!

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HelpHeaderView", for: indexPath) as! HelpHeaderView
        
        headerView.titleLabel.text = "A few tips to help you get started."
        
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 240, height: 80)
    }
    
    @objc func didTapClose() {
        delegate?.requestCloseHelpMessages()
    }
}
