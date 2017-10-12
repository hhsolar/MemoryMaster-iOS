//
//  MyNote.swift
//  Recite
//
//  Created by apple on 20/9/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import Foundation

struct MyBasicNoteInfo {
    var id: Int
    var time: Date
    var type: String
    var name: String
    var numberOfCard: Int
    
    static func nextNoteID() -> Int {
        let userDefaults = UserDefaults.standard
        let currentID = userDefaults.integer(forKey: "noteID")
        userDefaults.set(currentID + 1, forKey: "noteID")
        userDefaults.synchronize()
        return currentID
    }
}

struct CardContent {
    var title: NSAttributedString
    var body: NSAttributedString
    
    static func getCardContent(with noteName: String, at index: Int, in noteType: String) -> CardContent
    {
        let titleAtt = NSAttributedString.getTextFromFile(with: noteName, at: index, in: noteType, contentType: "title")
        let bodyAtt = NSAttributedString.getTextFromFile(with: noteName, at: index, in: noteType, contentType: "body")
        return CardContent(title: titleAtt, body: bodyAtt)
    }
}
