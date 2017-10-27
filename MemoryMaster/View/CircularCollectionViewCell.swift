//
//  CircularCollectionViewCell.swift
//  MemoryMaster
//
//  Created by apple on 16/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit

class CircularCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var contentTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        contentTextView.layer.cornerRadius = 10
        contentTextView.layer.masksToBounds = true
        contentTextView.layer.borderWidth = 1
        contentTextView.backgroundColor = CustomColor.weakGray
        contentTextView.textContainerInset = UIEdgeInsets(top: CustomDistance.midEdge, left: CustomDistance.midEdge, bottom: CustomDistance.midEdge, right: CustomDistance.midEdge)
        contentTextView.isEditable = false
        contentTextView.isScrollEnabled = false
    }
    
    func updateUI(noteType: String, title: NSAttributedString, body: NSAttributedString, index: Int)
    {
        self.layoutIfNeeded()
        let containerWidth = contentTextView.bounds.width - contentTextView.textContainerInset.left * 2 - contentTextView.textContainer.lineFragmentPadding * 2
        let titleRange = NSRange.init(location: 0, length: title.length)
        var newTitle = title
        if title.containsAttachments(in: titleRange) {
            newTitle = title.changeAttachmentImageToFitContainer(containerWidth: containerWidth, in: titleRange)
        }
        let bodyRange = NSRange.init(location: 0, length: body.length)
        var newBody = body
        if body.containsAttachments(in: bodyRange) {
            newBody = body.changeAttachmentImageToFitContainer(containerWidth: containerWidth, in: bodyRange)
        }
        contentTextView.attributedText = NSAttributedString.prepareAttributeStringForRead(noteType: noteType, title: newTitle, body: newBody, index: index)
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        let circularlayoutAttributes = layoutAttributes as! CircularCollectionViewLayoutAttributes
        self.layer.anchorPoint = circularlayoutAttributes.anchorPoint
        self.center.y += (circularlayoutAttributes.anchorPoint.y - 0.5) * self.bounds.height
    }
}
