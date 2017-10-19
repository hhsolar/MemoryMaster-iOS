//
//  CircularCollectionViewCell.swift
//  MemoryMaster
//
//  Created by apple on 16/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit

class CircularCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        backView.layer.cornerRadius = 10
        backView.layer.masksToBounds = true
        backView.layer.borderWidth = 1
        backView.backgroundColor = CustomColor.weakGray
    }
    
    func updateUI(noteType: String, title: NSAttributedString, body: NSAttributedString, index: Int) {
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
        contentLabel.attributedText = showString
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        let circularlayoutAttributes = layoutAttributes as! CircularCollectionViewLayoutAttributes
        self.layer.anchorPoint = circularlayoutAttributes.anchorPoint
        self.center.y += (circularlayoutAttributes.anchorPoint.y - 0.5) * self.bounds.height
    }
}
