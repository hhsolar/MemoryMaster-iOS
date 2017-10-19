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
    func noteTextContentChange(cardIndex: Int, textViewType: String, textContent: NSAttributedString)
}

class NoteEditCollectionViewCell: UICollectionViewCell {
    
    let backView = UIView()
    let indexLabel = UILabel()
    let titleTextView = UITextView()
    let bodyTextView = UITextView()
    let removeCardButton = UIButton()
    let addCardButton = UIButton()
    let addPhotoButton = UIButton()
    let addBookmarkButton = UIButton()
    let titleKeyboardAddPhotoButton = UIButton()
    let bodyKeyboardAddPhotoButton = UIButton()
    
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
                                     height: backView.bounds.height - CustomDistance.viewToScreenEdgeDistance * 4 - CustomSize.titleLabelHeight - CustomSize.buttonHeight)
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
        
        removeCardButton.frame = CGRect(x: CustomDistance.viewToScreenEdgeDistance, y: backView.bounds.height - CustomDistance.viewToScreenEdgeDistance - CustomSize.buttonHeight, width: CustomSize.buttonHeight, height: CustomSize.buttonHeight)
        removeCardButton.setImage(UIImage.init(named: "bin_icon"), for: .normal)
        removeCardButton.addTarget(self, action: #selector(removeCardAction), for: .touchUpInside)
        backView.addSubview(removeCardButton)
        
        let buttonInterval = (backView.bounds.width - CustomDistance.viewToScreenEdgeDistance * 2 - CustomSize.buttonHeight * 4) / 3
        addPhotoButton.frame = removeCardButton.frame
        addPhotoButton.frame.origin.x = CustomDistance.viewToScreenEdgeDistance + CustomSize.buttonHeight + buttonInterval
        addPhotoButton.setImage(UIImage.init(named: "photo_icon"), for: .normal)
        backView.addSubview(addPhotoButton)
        
        addBookmarkButton.frame = removeCardButton.frame
        addBookmarkButton.frame.origin.x = CustomDistance.viewToScreenEdgeDistance + CustomSize.buttonHeight * 2 + buttonInterval * 2
        addBookmarkButton.setImage(UIImage.init(named: "bookMark_icon"), for: .normal)
        backView.addSubview(addBookmarkButton)
        
        addCardButton.frame = removeCardButton.frame
        addCardButton.frame.origin.x = backView.bounds.width - CustomSize.buttonHeight - CustomDistance.viewToScreenEdgeDistance
        addCardButton.setImage(UIImage.init(named: "addNote_icon"), for: .normal)
        addCardButton.addTarget(self, action: #selector(addCardAction), for: .touchUpInside)
        backView.addSubview(addCardButton)
        
        let titleAccessoryView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        titleKeyboardAddPhotoButton.frame = CGRect(x: UIScreen.main.bounds.width - CustomDistance.viewToScreenEdgeDistance * 2 - CustomSize.smallBtnHeight, y: 0, width: CustomSize.smallBtnHeight, height: CustomSize.smallBtnHeight)
        titleKeyboardAddPhotoButton.setImage(UIImage.init(named: "photo_icon"), for: .normal)
        titleAccessoryView.addSubview(titleKeyboardAddPhotoButton)
        titleTextView.inputAccessoryView = titleAccessoryView
        
        let bodyAccessoryView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        bodyKeyboardAddPhotoButton.frame = CGRect(x: UIScreen.main.bounds.width - CustomDistance.viewToScreenEdgeDistance * 2 - CustomSize.smallBtnHeight, y: 0, width: CustomSize.smallBtnHeight, height: CustomSize.smallBtnHeight)
        bodyKeyboardAddPhotoButton.setImage(UIImage.init(named: "photo_icon"), for: .normal)
        bodyAccessoryView.addSubview(bodyKeyboardAddPhotoButton)
        bodyTextView.inputAccessoryView = bodyAccessoryView
    }
    
    @objc func removeCardAction(_ sender: UIButton) {
        delegate?.removeNoteCard(for: self)
    }
 
    @objc func addCardAction(_ sender: UIButton) {
        delegate?.addNoteCard(for: self)
    }
    
    func cutTextView(KBHeight: CGFloat) {
        editingTextView?.frame.size.height = backView.bounds.height - KBHeight - CustomSize.titleLabelHeight - CustomDistance.viewToScreenEdgeDistance
    }
    
    func extendTextView() {
        editingTextView?.frame.size.height = backView.bounds.height - CustomDistance.viewToScreenEdgeDistance * 4 - CustomSize.titleLabelHeight - CustomSize.buttonHeight
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
