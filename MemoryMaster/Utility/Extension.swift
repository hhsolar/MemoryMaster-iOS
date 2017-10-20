//
//  Extension.swift
//  Resite
//
//  Created by apple on 13/9/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit
import SVProgressHUD

extension String {
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z.%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailText = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailText.evaluate(with: self)
    }
}

extension UIViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showSavedPrompt() {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setFadeInAnimationDuration(0.2)
        SVProgressHUD.showSuccess(withStatus: "Saved!")
        SVProgressHUD.dismiss(withDelay: 0.5)
        SVProgressHUD.setFadeOutAnimationDuration(0.3)
    }
}

