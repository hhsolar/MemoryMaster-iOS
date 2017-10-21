//
//  UIView+Extension.swift
//  MemoryMaster
//
//  Created by apple on 20/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit
import SVProgressHUD

extension UIViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertWithAction(title: String, message: String, hasNo: Bool, yesHandler: ((UIAlertAction)->())? = nil,  noHandler: ((UIAlertAction)->())? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let yes = UIAlertAction(title: "YES", style: .default, handler: yesHandler)
        alert.addAction(yes)
        let cancel = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
        alert.addAction(cancel)
        
        if hasNo {
            let no = UIAlertAction(title: "NO", style: .default, handler: noHandler)
            alert.addAction(no)
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func showSavedPrompt() {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setFadeInAnimationDuration(0.2)
        SVProgressHUD.showSuccess(withStatus: "Saved!")
        SVProgressHUD.dismiss(withDelay: 0.4)
        SVProgressHUD.setFadeOutAnimationDuration(0.3)
    }
}
