//
//  NSAttributedString+Extension.swift
//  MemoryMaster
//
//  Created by apple on 10/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import Foundation

let applicationDocumentsDirectory: URL = {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}()

extension NSAttributedString {
    class func getTextFromFile(with noteName: String, at index: Int, in noteType: String, contentType: String) -> NSAttributedString {
        let fileName = "\(noteType)-\(noteName)-\(index)-\(contentType)"
        let url = applicationDocumentsDirectory.appendingPathComponent(fileName)
        let data = try? Data(contentsOf: url)
        if let data = data {
            let att = try? NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtfd], documentAttributes: nil)
            if let att = att {
                return att
            }
        }
        return NSAttributedString.init()
    }
    
    func saveTextToFile(with noteName: String, at index: Int, in noteType: String, contentType: String) {
        let data = try? self.data(from: NSRange(location: 0, length: self.length), documentAttributes: [NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.rtfd])
        let fileName = "\(noteType)-\(noteName)-\(index)-\(contentType)"
        let url = applicationDocumentsDirectory.appendingPathComponent(fileName)
        do {
            try data?.write(to: url, options: .atomic)
        } catch {
            print("Error writing file: \(error)")
        }
    }
    
    class func prepareAttributeStringForRead(noteType: String, title: NSAttributedString, body: NSAttributedString, index: Int) -> NSAttributedString {
        let showString = NSMutableAttributedString(string: String(format: "%d. ", index + 1), attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 16)])
        if noteType == NoteType.single.rawValue {
            if title != NSAttributedString() {
                showString.append(title)
                let returnAtt = NSAttributedString(string: "\n\n")
                showString.append(returnAtt)
            }
            showString.append(body)
        } else {
            let questionString = NSAttributedString(string: "Question: ", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 16)])
            showString.append(questionString)
            showString.append(title)
            let returnAtt = NSAttributedString(string: "\n\n")
            showString.append(returnAtt)
            let answerString = NSAttributedString(string: "Answer: ", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 16)])
            showString.append(answerString)
            showString.append(body)
        }
        return showString
    }
}