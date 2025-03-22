//
//  HowtoViewController.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 3/1/21.
//  Copyright © 2021 Eric Versteeg. All rights reserved.
//

import UIKit

class HowtoViewController: UIViewController {

    @IBOutlet weak var backButton: ButtonFrame!
    
    @IBOutlet weak var howtoTitleLabel: UILabel!
    
    @IBOutlet weak var step1Text: UILabel!
    @IBOutlet weak var step2Text: UILabel!
    @IBOutlet weak var step3Text: UILabel!
    @IBOutlet weak var step4Text: UILabel!
    @IBOutlet weak var step5Text: UILabel!
    @IBOutlet weak var step6Text: UILabel!
    @IBOutlet weak var step7Text: UILabel!
    @IBOutlet weak var step8Text: UILabel!
    @IBOutlet weak var step9Text: UILabel!
    @IBOutlet weak var step10Text: UILabel!
    @IBOutlet weak var step11Text: UILabel!
    
    @IBOutlet weak var step1Height: NSLayoutConstraint!
    @IBOutlet weak var step2Height: NSLayoutConstraint!
    @IBOutlet weak var step3Height: NSLayoutConstraint!
    @IBOutlet weak var step4Height: NSLayoutConstraint!
    @IBOutlet weak var step5Height: NSLayoutConstraint!
    @IBOutlet weak var step6Height: NSLayoutConstraint!
    @IBOutlet weak var step7Height: NSLayoutConstraint!
    
    @IBOutlet weak var paintAction: UIImageView!
    @IBOutlet weak var exportAction: UIImageView!
    @IBOutlet weak var changeBackgroundAction: UIImageView!
    @IBOutlet weak var gridLineAction: UIImageView!
    @IBOutlet weak var summaryAction: UIImageView!
    @IBOutlet weak var dotAction1: UIImageView!
    @IBOutlet weak var dotAction2: UIImageView!
    @IBOutlet weak var frameAction: ActionButtonView!
    @IBOutlet weak var dotAction3: ActionButtonView!
    @IBOutlet weak var exportAction2: ActionButtonView!
    
    @IBOutlet weak var backActionLeading: NSLayoutConstraint!
    
    @IBOutlet weak var recentColorsContainerWidth: NSLayoutConstraint!
    @IBOutlet weak var recentColorsContainerHeight: NSLayoutConstraint!
    
    weak var recentColorsViewController: RecentColorsViewController!
    
    let unwindToCanvas = "UnwindToCanvas"
    
    var fromCanvas = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setGradientBackground()
        
        backButton.setOnClickListener {
            if self.fromCanvas {
                self.performSegue(withIdentifier: self.unwindToCanvas, sender: nil)
            }
            else {
                self.presentingViewController?.dismiss(animated: false, completion: nil)
            }
        }
        
        //paintAction.isStatic = true
        //exportAction.isStatic = true
        //changeBackgroundAction.isStatic = true
        //gridLineAction.isStatic = true
        //summaryAction.isStatic = true
        //dotAction1.isStatic = true
        //dotAction2.isStatic = true
        frameAction.isStatic = true
        dotAction3.isStatic = true
        exportAction2.isStatic = true
        
        paintAction.image = UIImage(named: "brush")
        paintAction.backgroundColor = UIColor.clear
        paintAction.tintColor = UIColor.white
        
        exportAction.image = UIImage(named: "export")
        exportAction.backgroundColor = UIColor.clear
        exportAction.tintColor = UIColor.white
        
        changeBackgroundAction.image = UIImage(named: "background")
        changeBackgroundAction.backgroundColor = UIColor.clear
        changeBackgroundAction.tintColor = UIColor.white
        
        gridLineAction.image = UIImage(named: "grid")
        gridLineAction.backgroundColor = UIColor.clear
        gridLineAction.tintColor = UIColor.white
        
        summaryAction.image = UIImage(named: "zoom_out")
        summaryAction.backgroundColor = UIColor.clear
        summaryAction.tintColor = UIColor.white
        
        dotAction1.image = UIImage(named: "widgets")
        dotAction1.backgroundColor = UIColor.clear
        dotAction1.tintColor = UIColor.white
        
        dotAction2.image = UIImage(named: "palette")
        dotAction2.backgroundColor = UIColor.clear
        dotAction2.tintColor = UIColor.white
        
        //paintAction.type = .paint
        //exportAction.type = .export
        //changeBackgroundAction.type = .changeBackground
        //gridLineAction.type = .gridLines
        //summaryAction.type = .summary
        //dotAction1.type = .dot
        //dotAction2.type = .dot
        frameAction.type = .frame
        dotAction3.type = .dot
        exportAction2.type = .export
        
        if view.frame.size.height <= 600 {
            howtoTitleLabel.isHidden = true
            
            step1Text.isHidden = true
            paintAction.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if view.frame.size.height <= 600 {
            Animator.animateTitleFromTop(titleView: howtoTitleLabel)
            
            Animator.animateHorizontalViewEnter(view: step1Text, left: true)
            Animator.animateHorizontalViewEnter(view: paintAction, left: true)
        }
        
        AppDelegate.OrientationUtility.lockOrientation(UIInterfaceOrientationMask.landscape)
    }

    func setGradientBackground() {
        let gradient = CAGradientLayer()

        gradient.frame = self.view.frame
        gradient.colors = [UIColor(argb: Utils.int32FromColorHex(hex: "0xff006787")).cgColor, UIColor(argb: Utils.int32FromColorHex(hex: "0xff07875f")).cgColor]
        
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)

        view.layer.insertSublayer(gradient, at: 0)
    }
    
    func setStepBackground(label: UILabel) {
        label.layer.cornerRadius = 10
        //label.layer.borderWidth = 1
        //label.layer.borderColor = UIColor(argb: Utils.int32FromColorHex(hex: "0x99FFFFFF")).cgColor
        
        label.backgroundColor = UIColor(argb: Utils.int32FromColorHex(hex: "0x33999999"))
    }
    
    override func viewDidLayoutSubviews() {
        let stepLabels = [step1Text, step2Text, step3Text, step4Text, step5Text,
                          step6Text, step7Text]
        
        let stepHeights = [step1Height, step2Height, step3Height, step4Height,
                           step5Height, step6Height, step7Height]
        
        for i in 0...stepLabels.count - 1 {
            let label = stepLabels[i]!
            let height = stepHeights[i]!
            
            setStepBackground(label: label)
            NSLog("width = \(label.frame.size.width)")
            //height.constant = label.sizeThatFits(CGSize(width: label.frame.size.width, height: CGFloat.greatestFiniteMagnitude)).height + 20
        }
        
        if step1Text.font.pointSize < step2Text.font.pointSize {
            step2Text.font = UIFont.systemFont(ofSize: step1Text.font.pointSize)
        }
        
        let backX = self.backButton.frame.origin.x
        
        if backX < 0 {
            backActionLeading.constant += 30
        }
        
        let colorStrs = ["000000", "222034", "45283C", "663931", "8F563B", "DF7126", "D9A066", "EEC39A",
                      "FBF236", "99E550", "6ABE30", "37946E", "4B692F", "524B24", "323C39", "3F3F74"]
        
        var colors = [Int32]()
        for colorStr in colorStrs {
            colors.append(Utils.int32FromColorHex(hex: "0xFF" + colorStr))
        }
        
        setupColorPalette(colors: colors.reversed())
    }
    
    func setupColorPalette(colors: [Int32]) {
//        let itemWidth = self.recentColorsViewController.itemWidth
//        let itemHeight = self.recentColorsViewController.itemWidth
//        let margin = self.recentColorsViewController.itemMargin
//        
//        self.recentColorsContainerWidth.constant = itemWidth * 4 + margin * 3
//        
//        let numRows = (colors.count - 1) / 4 + 1
//        self.recentColorsContainerHeight.constant = itemHeight * CGFloat(numRows) + margin * CGFloat(numRows - 1)
//        
//        self.recentColorsViewController.data = colors.reversed()
//        self.recentColorsViewController.collectionView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "RecentColorsEmbed" {
//            self.recentColorsViewController = segue.destination as? RecentColorsViewController
//            self.recentColorsViewController.isStatic = true
//        }
    }
}
