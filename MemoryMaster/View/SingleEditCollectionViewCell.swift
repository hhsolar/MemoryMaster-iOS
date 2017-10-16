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
        addTitleButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 16)
        addTitleButton.setTitleColor(UIColor.white, for: .normal)
        addTitleButton.layer.cornerRadius = 11
        addTitleButton.layer.masksToBounds = true
        addTitleButton.addTarget(self, action: #selector(addTitleAction), for: .touchUpInside)
        backView.addSubview(addTitleButton)
        
        filpButton.frame = CGRect(x: containerWidth - 28 - CustomDistance.viewToScreenEdgeDistance, y: CustomDistance.viewToScreenEdgeDistance - 2, width: 28, height: 28)
        filpButton.addTarget(self, action: #selector(filpCardAction), for: .touchUpInside)
        backView.addSubview(filpButton)
        
        backView.addSubview(titleLabel)
        titleLabel.frame = CGRect(x: CustomDistance.viewToScreenEdgeDistance, y: CustomDistance.viewToScreenEdgeDistance * 2 + CustomSize.titleLabelHeight, width: 80, height: CustomSize.titleLabelHeight)
        titleLabel.text = "Title:"
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        titleLabel.textColor = CustomColor.medianBlue
        
        titleTextView.frame.origin.y += CustomSize.titleLabelHeight
        titleTextView.frame.size.height -= CustomSize.titleLabelHeight
        
        addPhotoButton.addTarget(self, action: #selector(addPhotoAction), for: .touchUpInside)
        titleKeyboardAddPhotoButton.addTarget(self, action: #selector(addPhotoAction), for: .touchUpInside)
        bodyKeyboardAddPhotoButton.addTarget(self, action: #selector(addPhotoAction), for: .touchUpInside)
    }
    
    func updataCell(with cardContent: CardContent, at index: Int, total: Int, cellStatus: CellStatus) {
        super.cardIndex = index
        super.indexLabel.text = String.init(format: "%d / %d", index + 1, total)
        
        bodyTextView.attributedText = cardContent.body
        switch cellStatus {
        case .titleFront:
            titleTextView.attributedText = cardContent.title
            addTitle()
        case .bodyFrontWithTitle:
            titleTextView.attributedText = cardContent.title
            addTitle()
            titleLabel.isHidden = true
            titleTextView.isHidden = true
            bodyTextView.isHidden = false
            titleLabel.alpha = 0.0
            titleTextView.alpha = 0.0
            bodyTextView.alpha = 1.0
        default:
            removeTitle()
        }
    }
    
    func addTitle() {
        UIView.animateKeyframes(withDuration: 0.5, delay: 0.3, options: [], animations: { [weak self] in
            self?.addTitleButton.setTitle("REMOVE TITLE", for: .normal)
            self?.filpButton.setImage(UIImage.init(named: "filp_icon"), for: .normal)
            self?.titleLabel.alpha = 1.0
            self?.titleTextView.alpha = 1.0
            self?.bodyTextView.alpha = 0.0
        }, completion: nil)
        titleLabel.isHidden = false
        filpButton.isEnabled = true
        titleTextView.isHidden = false
        bodyTextView.isHidden = true
    }
    
    func removeTitle() {
        UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: { [weak self] in
            self?.addTitleButton.setTitle("ADD TITLE", for: .normal)
            self?.filpButton.setImage(UIImage.init(named: "flip_icon_disable"), for: .disabled)
            self?.titleLabel.alpha = 0.0
            self?.titleTextView.alpha = 0.0
            self?.bodyTextView.alpha = 1.0
        }, completion: nil)
        titleLabel.isHidden = true
        filpButton.isEnabled = false
        titleTextView.isHidden = true
        bodyTextView.isHidden = false
        titleTextView.attributedText = NSAttributedString()
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
            UIView.animateKeyframes(withDuration: 0.5, delay: 0.3, options: [], animations: { [weak self] in
                self?.titleLabel.alpha = 1.0
                self?.titleTextView.alpha = 1.0
                self?.bodyTextView.alpha = 0.0
            }, completion: nil)
            titleLabel.isHidden = false
            titleTextView.isHidden = false
            bodyTextView.isHidden = true
        } else {
            UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: { [weak self] in
                self?.titleLabel.alpha = 0.0
                self?.titleTextView.alpha = 0.0
                self?.bodyTextView.alpha = 1.0
            }, completion: nil)
            titleLabel.isHidden = true
            titleTextView.isHidden = true
            bodyTextView.isHidden = false
        }
    }
}
