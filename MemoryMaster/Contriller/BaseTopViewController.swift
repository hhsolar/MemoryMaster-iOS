//
//  BaseTopViewController.swift
//  MemoryMaster
//
//  Created by apple on 8/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit

private let screenWidth = UIScreen.main.bounds.width

class BaseTopViewController: UIViewController {

    let topView = UIView()
    let titleLabel = UILabel()
    let backButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setupUI() {
        topView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: CustomSize.barHeight + CustomSize.statusBarHeight)
        topView.backgroundColor = CustomColor.medianBlue
        view.addSubview(topView)
        
        let titleWidth = screenWidth - CustomSize.buttonHeight * 2 - CustomDistance.viewToScreenEdgeDistance * 4
        titleLabel.frame = CGRect(x: CustomDistance.viewToScreenEdgeDistance * 2 + CustomSize.buttonHeight,
                                  y: (CustomSize.barHeight - CustomSize.titleLabelHeight) / 2 + CustomSize.statusBarHeight,
                                  width: titleWidth, height: CustomSize.titleLabelHeight)
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        titleLabel.textColor = UIColor.white
        topView.addSubview(titleLabel)
        
        backButton.frame = CGRect(x: CustomDistance.viewToScreenEdgeDistance,
                                  y: (CustomSize.barHeight - CustomSize.buttonHeight) / 2 + CustomSize.statusBarHeight,
                                  width: CustomSize.buttonHeight, height: CustomSize.buttonHeight)
        backButton.setImage(UIImage(named: "exit_icon_white"), for: .normal)
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        topView.addSubview(backButton)
    }
    
    @objc func backAction() {
        dismiss(animated: true, completion: nil)
    }
}
