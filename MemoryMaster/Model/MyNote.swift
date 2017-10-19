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
    
    static func convertToMyBasicNoteInfo(basicNoteInfo: BasicNoteInfo) -> MyBasicNoteInfo {
        return MyBasicNoteInfo(id: Int(basicNoteInfo.id), time: basicNoteInfo.createTime as Date, type: basicNoteInfo.type, name: basicNoteInfo.name, numberOfCard: Int(basicNoteInfo.numberOfCard))
    }
}

struct MyBookmark {
    var name: String
    var id: Int
    var time: Date
    var readType: String
    var readPage: Int
    var readPageStatus: String?
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
    
    static func removeCardContent(with noteName: String, at index: Int, in noteType: String) {
        CardContent.removeTextFile(with: noteName, at: index, in: noteType, contentType: "title")
        CardContent.removeTextFile(with: noteName, at: index, in: noteType, contentType: "body")
    }
    
    static func removeTextFile(with noteName: String, at index: Int, in noteType: String, contentType: String) {
        let fileName = "\(noteType)-\(noteName)-\(index)-\(contentType)"
        let url = applicationDocumentsDirectory.appendingPathComponent(fileName)
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Error removing file: \(error)")
        }
    }    
}
