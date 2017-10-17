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
    
    private func setUI() {
        backView.layer.cornerRadius = 10
        backView.layer.masksToBounds = true
        backView.layer.borderWidth = 1
        backView.backgroundColor = CustomColor.weakGray
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        let circularlayoutAttributes = layoutAttributes as! CircularCollectionViewLayoutAttributes
        self.layer.anchorPoint = circularlayoutAttributes.anchorPoint
        self.center.y += (circularlayoutAttributes.anchorPoint.y - 0.5) * self.bounds.height
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUI()
    }
}
