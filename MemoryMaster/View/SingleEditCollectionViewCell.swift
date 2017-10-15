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
    func singleNoteAddPhoto(for textView: UITextView, at index: Int, with range: NSRange, cellStatus: CellStatus)

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
        
        backView.addSubview(titleLabel)
        titleLabel.frame = CGRect(x: CustomDistance.viewToScreenEdgeDistance, y: CustomDistance.viewToScreenEdgeDistance * 2 + CustomSize.titleLabelHeight, width: 80, height: CustomSize.titleLabelHeight)
        titleLabel.text = "Title:"
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        titleLabel.textColor = CustomColor.medianBlue
        titleLabel.isHidden = true
        
        titleTextView.frame.origin.y += CustomSize.titleLabelHeight
        titleTextView.frame.size.height -= CustomSize.titleLabelHeight
        titleTextView.isHidden = true
        
        addPhotoButton.addTarget(self, action: #selector(addPhotoAction), for: .touchUpInside)
        addPhotoBtnWithKB.addTarget(self, action: #selector(addPhotoAction), for: .touchUpInside)
    }
    
    func updataCell(with cardContent: CardContent, at index: Int, total: Int, cellStatus: CellStatus) {
        super.cardIndex = index
        super.indexLabel.text = String.init(format: "%d / %d", index + 1, total)
        
        bodyTextView.attributedText = cardContent.body
        switch cellStatus {
        case .titleFront:
            titleTextView.attributedText = cardContent.title
            addTitle()
            titleTextView.isHidden = false
            bodyTextView.isHidden = true
            titleTextView.alpha = 1.0
            bodyTextView.alpha = 0.0
            titleLabel.isHidden = false
        case .bodyFrontWithTitle:
            titleTextView.attributedText = cardContent.title
            addTitle()
            titleTextView.isHidden = true
            bodyTextView.isHidden = false
            titleTextView.alpha = 0.0
            bodyTextView.alpha = 1.0
            titleLabel.isHidden = true
        default:
            removeTitle()
            titleTextView.isHidden = true
            bodyTextView.isHidden = false
            titleTextView.alpha = 0.0
            bodyTextView.alpha = 1.0
            titleLabel.isHidden = true
        }
    }
    
    func addTitle() {
        titleButtonText = "REMOVE TITLE"
        addTitleButton.setTitle(titleButtonText, for: .normal)
        
        titleLabel.isHidden = false
        
        filpButton.setImage(UIImage.init(named: "filp_icon"), for: .normal)
        filpButton.isEnabled = true
    }
    
    func removeTitle() {
        titleButtonText = "ADD TITLE"
        addTitleButton.setTitle(titleButtonText, for: .normal)
        
        titleLabel.isHidden = true
        titleTextView.attributedText = NSAttributedString()
        
        filpButton.setImage(UIImage.init(named: "flip_icon_disable"), for: .disabled)
        filpButton.isEnabled = false
    }
    
    @objc func addTitleAction(_ sender: UIButton) {
        singleCellDelegate?.singleNoteTitleEdit(for: self)
    }
    
    @objc func addPhotoAction(_ sender: UIButton) {
        if bodyTextView.isHidden {
            var range = titleTextView.selectedRange
            if range.location == NSNotFound {
                range.location = titleTextView.text.count
            }
            singleCellDelegate?.singleNoteAddPhoto(for: titleTextView, at: cardIndex!, with: range, cellStatus: CellStatus.titleFront)
        } else {
            var range = bodyTextView.selectedRange
            if range.location == NSNotFound {
                range.location = bodyTextView.text.count
            }
            if filpButton.isEnabled {
                singleCellDelegate?.singleNoteAddPhoto(for: bodyTextView, at: cardIndex!, with: range, cellStatus: CellStatus.bodyFrontWithTitle)
            } else {
                singleCellDelegate?.singleNoteAddPhoto(for: bodyTextView, at: cardIndex!, with: range, cellStatus: CellStatus.bodyFrontWithoutTitle)
            }
        }
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
