//
//  Constant.swift
//  Resite
//
//  Created by apple on 13/9/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import Foundation
import UIKit

struct CustomColor {
    static let medianBlue = UIColor(red: 70/255.0, green: 110/255.0, blue: 210/255.0, alpha: 1.0)
    static let deepBlue = UIColor(red: 75/255.0, green: 95/255.0, blue: 195/255.0, alpha: 1.0)
    static let wordGray = UIColor(red: 140/255.0, green: 140/255.0, blue: 140/255.0, alpha: 1.0)
    static let weakGray = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
    static let lightBlue = UIColor(red: 213/255.0, green: 230/255.0, blue: 246/255.0, alpha: 1.0)
    static let lightGreen = UIColor(red: 224/255.0, green: 244/255.0, blue: 219/255.0, alpha: 1.0)
}

struct CustomFont {
    static let navigationTitleFontName = "Arial-BoldMT"
    static let navigationTitleFontSize: CGFloat = 17.0
    static let navigationSideFontName = "ArialMT"
    static let navigationSideFontSize: CGFloat = 16.0
}

struct CustomDistance {
    static let viewToScreenEdgeDistance: CGFloat = 12
}

struct CustomSize {
    static let statusBarHeight: CGFloat = 20
    static let buttonWidth: CGFloat = 30
    static let barHeight: CGFloat = 44
    static let titleLabelHeight: CGFloat = 22
}

struct LoginErrorCode {
    static let invalidEmail = "Invalid Email"
    static let wrongPassword = "Wrong Password"
    static let connectProblem = "Connect Problem"
    static let userNotFound = "User Not Found"
    static let emailAleadyInUse = "Email Aleady In Use"
    static let weakPassword = "Weak Password"
}

struct SystemSound {
    static let buttonClick = "button_click.caf"
}

class Constants {
    static let user = "user"
    static let email = "email"
    static let password = "passwrod"
    static let data = "data"
}


class UserInfo {
    private static var instance: UserInfo = UserInfo()
    static var shared: UserInfo {
        return instance
    }
    var uid: String = ""
    var userName = ""
}
