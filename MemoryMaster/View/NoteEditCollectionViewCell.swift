//
//  NoteEditCollectionViewCell.swift
//  MemoryMaster
//
//  Created by apple on 10/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit

protocol NoteEditCollectionViewCellDelegate: class {
    func addNoteCard(for cell: NoteEditCollectionViewCell)
    func removeNoteCard(for cell: NoteEditCollectionViewCell)
    func noteAddPhoto(for cell: NoteEditCollectionViewCell, with range: NSRange?)
    func noteTextContentChange(cardIndex: Int, textViewType: String, textContent: NSAttributedString)
}

class NoteEditCollectionViewCell: UICollectionViewCell {
    
    let backView = UIView()
    let indexLabel = UILabel()
    let titleTextView = UITextView()
    let bodyTextView = UITextView()
    let removeCardButton = UIButton()
    let addPhotoButton = UIButton()
    let addCardButton = UIButton()
    
    var cardIndex: Int?
    var editingTextView: UITextView?
    weak var delegate: NoteEditCollectionViewCellDelegate?
    
    var titleText: NSAttributedString? {
        get {
            return titleTextView.attributedText
        }
    }
    
    var bodyText: NSAttributedString? {
        get {
            return bodyTextView.attributedText
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    func setupUI() {
        let cellWidth = contentView.bounds.width
        let cellHeight = contentView.bounds.height
        
        backView.frame = CGRect(x: CustomDistance.viewToScreenEdgeDistance, y: CustomDistance.viewToScreenEdgeDistance, width: cellWidth - CustomDistance.viewToScreenEdgeDistance * 2, height: cellHeight - CustomDistance.viewToScreenEdgeDistance * 2)
        backView.backgroundColor = UIColor.white
        backView.layer.cornerRadius = 15
        backView.layer.masksToBounds = true
        contentView.addSubview(backView)
        
        indexLabel.frame = CGRect(x: CustomDistance.viewToScreenEdgeDistance, y: CustomDistance.viewToScreenEdgeDistance + 2, width: 120, height: CustomSize.titleLabelHeight)
        indexLabel.font = UIFont(name: "HelveticaNeue-MediumItalic", size: 18)
        indexLabel.textColor = CustomColor.medianBlue
        backView.addSubview(indexLabel)

        titleTextView.frame = CGRect(x: CustomDistance.viewToScreenEdgeDistance,
                                     y: CustomDistance.viewToScreenEdgeDistance * 2 + CustomSize.titleLabelHeight,
                                     width: backView.bounds.width - CustomDistance.viewToScreenEdgeDistance * 2,
                                     height: backView.bounds.height - CustomDistance.viewToScreenEdgeDistance * 4 - CustomSize.titleLabelHeight - CustomSize.buttonWidth)
        titleTextView.font = UIFont(name: "HelveticaNeue-Bold", size: 15)
        titleTextView.tag = OutletTag.titleTextView.rawValue
        titleTextView.showsVerticalScrollIndicator = false
        titleTextView.delegate = self
        backView.addSubview(titleTextView)

        bodyTextView.frame = titleTextView.frame
        bodyTextView.font = UIFont(name: "HelveticaNeue", size: 15)
        bodyTextView.tag = OutletTag.bodyTextView.rawValue
        bodyTextView.showsVerticalScrollIndicator = false
        bodyTextView.delegate = self
        backView.addSubview(bodyTextView)
        
        removeCardButton.frame = CGRect(x: CustomDistance.viewToScreenEdgeDistance, y: backView.bounds.height - CustomDistance.viewToScreenEdgeDistance - CustomSize.buttonWidth, width: CustomSize.buttonWidth, height: CustomSize.buttonWidth)
        removeCardButton.setImage(UIImage.init(named: "bin_icon"), for: .normal)
        removeCardButton.addTarget(self, action: #selector(removeCardAction), for: .touchUpInside)
        backView.addSubview(removeCardButton)
        
        addPhotoButton.frame = removeCardButton.frame
        addPhotoButton.frame.origin.x = (backView.bounds.width - CustomSize.buttonWidth) / 2
        addPhotoButton.setImage(UIImage.init(named: "photo_icon"), for: .normal)
        addPhotoButton.addTarget(self, action: #selector(addPhotoAction), for: .touchUpInside)
        backView.addSubview(addPhotoButton)
        
        addCardButton.frame = removeCardButton.frame
        addCardButton.frame.origin.x = backView.bounds.width - CustomSize.buttonWidth - CustomDistance.viewToScreenEdgeDistance
        addCardButton.setImage(UIImage.init(named: "addNote_icon"), for: .normal)
        addCardButton.addTarget(self, action: #selector(addCardAction), for: .touchUpInside)
        backView.addSubview(addCardButton)
    }
        
    @objc func removeCardAction(_ sender: UIButton) {
        delegate?.removeNoteCard(for: self)
    }
    
    @objc func addPhotoAction(_ sender: UIButton) {
        var range: NSRange?
        if bodyTextView.isHidden {
            range = titleTextView.selectedRange
        } else {
            range = bodyTextView.selectedRange
        }
        delegate?.noteAddPhoto(for: self, with: range)
    }
 
    @objc func addCardAction(_ sender: UIButton) {
        delegate?.addNoteCard(for: self)
    }
    
    func titlePresent() {
        UIView.animateKeyframes(withDuration: 0.5, delay: 0.3, options: [], animations: {
            self.titleTextView.alpha = 1.0
            self.bodyTextView.alpha = 0.0
        }, completion: nil)
        titleTextView.isHidden = false
        bodyTextView.isHidden = true
    }
    
    func bodyPresent() {
        UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: {
            self.titleTextView.alpha = 0.0
            self.bodyTextView.alpha = 1.0
        }, completion: nil)
        titleTextView.isHidden = true
        bodyTextView.isHidden = false
    }
}

extension NoteEditCollectionViewCell: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        if textView.tag == OutletTag.titleTextView.rawValue {
            delegate?.noteTextContentChange(cardIndex: cardIndex!, textViewType: "title", textContent: titleText!)
        } else if textView.tag == OutletTag.bodyTextView.rawValue {
            delegate?.noteTextContentChange(cardIndex: cardIndex!, textViewType: "body", textContent: bodyText!)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        editingTextView = textView
    }
}