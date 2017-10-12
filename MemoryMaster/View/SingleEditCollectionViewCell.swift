//
//  SingleEditCollectionViewCell.swift
//  MemoryMaster
//
//  Created by apple on 1/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit

protocol SingleEditCollectionViewCellDelegate: NoteEditCollectionViewCellDelegate {
    func singleNoteTitleEdit(for cell: SingleEditCollectionViewCell)
    func filpSingleNoteCard(for cell: SingleEditCollectionViewCell)
}

class SingleEditCollectionViewCell: NoteEditCollectionViewCell {

    let addTitleButton = UIButton()
    let filpButton = UIButton()
    let titleLabel = UILabel()
    
    var titleButtonText = "ADD TITLE"

    weak var singleCellDelegate: SingleEditCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func setupUI()
    {
        super.setupUI()
        let containerWidth = UIScreen.main.bounds.width - CustomDistance.viewToScreenEdgeDistance * 2
        
        addTitleButton.frame = CGRect(x: (containerWidth - 150) / 2, y: CustomDistance.viewToScreenEdgeDistance, width: 150, height: CustomSize.titleLabelHeight)
        addTitleButton.backgroundColor = CustomColor.medianBlue
        addTitleButton.setTitle(titleButtonText, for: .normal)
        addTitleButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 16)
        addTitleButton.setTitleColor(UIColor.white, for: .normal)
        addTitleButton.layer.cornerRadius = 11
        addTitleButton.layer.masksToBounds = true
        addTitleButton.addTarget(self, action: #selector(addTitleAction), for: .touchUpInside)
        backView.addSubview(addTitleButton)
        
        filpButton.frame = CGRect(x: containerWidth - 28 - CustomDistance.viewToScreenEdgeDistance, y: CustomDistance.viewToScreenEdgeDistance - 2, width: 28, height: 28)
        filpButton.addTarget(self, action: #selector(filpCardAction), for: .touchUpInside)
        backView.addSubview(filpButton)

        filpButton.setImage(UIImage.init(named: "flip_icon_disable"), for: .disabled)
        filpButton.isEnabled = false
        
        titleLabel.frame = CGRect(x: CustomDistance.viewToScreenEdgeDistance, y: CustomDistance.viewToScreenEdgeDistance * 2 + indexLabel.bounds.height, width: 80, height: CustomSize.titleLabelHeight)
        titleLabel.text = "Title:"
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        titleLabel.textColor = CustomColor.medianBlue
        backView.addSubview(titleLabel)
        titleLabel.isHidden = true
        
        titleTextView.frame.origin.y += CustomSize.titleLabelHeight
        titleTextView.frame.size.height -= CustomSize.titleLabelHeight
        
        titleTextView.isHidden = true
    }
    
    func updataCell(with cardContent: CardContent, at index: Int, total: Int) {
        super.cardIndex = index
        super.indexLabel.text = String.init(format: "%d / %d", index + 1, total)
        
        bodyTextView.attributedText = cardContent.body
        if cardContent.title != NSAttributedString.init() {
            addTitle()
            titleTextView.attributedText = cardContent.title
        } else {
            removeTitle()
        }
    }
    
    @objc func addTitleAction(_ sender: UIButton) {
        singleCellDelegate?.singleNoteTitleEdit(for: self)
    }
    
    func addTitle() {
        titleButtonText = "REMOVE TITLE"
        addTitleButton.setTitle(titleButtonText, for: .normal)
        
        titlePresent()
        titleLabel.isHidden = false
        
        filpButton.setImage(UIImage.init(named: "filp_icon"), for: .normal)
        filpButton.isEnabled = true
    }
    
    func removeTitle() {
        titleButtonText = "ADD TITLE"
        addTitleButton.setTitle(titleButtonText, for: .normal)
        
        bodyPresent()
        titleLabel.isHidden = true
        titleTextView.attributedText = NSAttributedString()
        
        filpButton.setImage(UIImage.init(named: "flip_icon_disable"), for: .disabled)
        filpButton.isEnabled = false
    }
    
    @objc func filpCardAction(_ sender: UIButton) {
        singleCellDelegate?.filpSingleNoteCard(for: self)
    }
    
    func changeFilpButtonText() {
        if titleTextView.isHidden {
            titlePresent()
            titleLabel.isHidden = false
        } else {
            bodyPresent()
            titleLabel.isHidden = true
        }
    }
}
