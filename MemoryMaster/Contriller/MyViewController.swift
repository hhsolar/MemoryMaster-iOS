//
//  MyViewController.swift
//  MemoryMaster
//
//  Created by apple on 16/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit

class MyViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationBar.appearance().tintColor = CustomColor.medianBlue
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    

}
