//
//  ReadCollectionViewCell.swift
//  MemoryMaster
//
//  Created by apple on 3/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit

class ReadCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var bodyTextView: UITextView!
    
    func updateUI(noteType: String, title: NSAttributedString, body: NSAttributedString, index: Int) {
        let showString = NSMutableAttributedString(string: String(format: "%d. ", index), attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 16)])
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
        bodyTextView.attributedText = showString
        
        // make the TextView show form the top
        bodyTextView.scrollRangeToVisible(NSRange.init(location: 0, length: 1))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bodyTextView.isEditable = false
        bodyTextView.showsHorizontalScrollIndicator = false
        bodyTextView.showsVerticalScrollIndicator = false
    }
}
