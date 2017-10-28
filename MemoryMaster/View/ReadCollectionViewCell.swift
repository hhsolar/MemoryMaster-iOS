//
//  ReadCollectionViewCell.swift
//  MemoryMaster
//
//  Created by apple on 3/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit

class ReadCollectionViewCell: UICollectionViewCell, UITextViewDelegate {

    @IBOutlet weak var bodyTextView: UITextView!
    
    weak var delegate: EnlargeImageCellDelegate?
    
    func updateUI(noteType: String, title: NSAttributedString, body: NSAttributedString, index: Int) {
        bodyTextView.attributedText = NSAttributedString.prepareAttributeStringForRead(noteType: noteType, title: title, body: body, index: index)
        bodyTextView.backgroundColor = CustomColor.paperColor

        // make the TextView show form the top
        bodyTextView.scrollRangeToVisible(NSRange.init(location: 0, length: 1))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bodyTextView.delegate = self
        bodyTextView.isEditable = false
        bodyTextView.showsHorizontalScrollIndicator = false
        bodyTextView.showsVerticalScrollIndicator = true
        bodyTextView.textContainerInset = UIEdgeInsets(top: 0, left: CustomDistance.wideEdge, bottom: 0, right: CustomDistance.wideEdge)
    }
    
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        var image: UIImage? = nil
        if textAttachment.image != nil {
            image = textAttachment.image
        } else {
            image = textAttachment.image(forBounds: textAttachment.bounds, textContainer: nil, characterIndex: characterRange.location)
        }
        
        if let image = image {
            delegate?.enlargeTapedImage(image: image)
        }
        return true
    }
}
