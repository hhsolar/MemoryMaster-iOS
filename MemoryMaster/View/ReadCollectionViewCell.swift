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
        bodyTextView.attributedText = NSAttributedString.prepareAttributeStringForRead(noteType: noteType, title: title, body: body, index: index)
        bodyTextView.backgroundColor = CustomColor.paperColor

        // make the TextView show form the top
        bodyTextView.scrollRangeToVisible(NSRange.init(location: 0, length: 1))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bodyTextView.isEditable = false
        bodyTextView.showsHorizontalScrollIndicator = false
        bodyTextView.showsVerticalScrollIndicator = true
        bodyTextView.textContainerInset = UIEdgeInsets(top: CustomDistance.midEdge, left: CustomDistance.midEdge, bottom: CustomDistance.midEdge, right: CustomDistance.midEdge)
    }
}
