//
//  String+Extension.swift
//  MemoryMaster
//
//  Created by apple on 20/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit

extension String {
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z.%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailText = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailText.evaluate(with: self)
    }
}
