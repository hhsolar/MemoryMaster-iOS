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
        contentTextView.isUserInteractionEnabled = false
    }
    
    func updateUI(content: NSAttributedString)
    {
        contentTextView.attributedText = content
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        let circularlayoutAttributes = layoutAttributes as! CircularCollectionViewLayoutAttributes
        self.layer.anchorPoint = circularlayoutAttributes.anchorPoint
        self.center.y += (circularlayoutAttributes.anchorPoint.y - 0.5) * self.bounds.height
    }
}
