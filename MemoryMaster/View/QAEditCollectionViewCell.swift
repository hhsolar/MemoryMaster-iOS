//
//  QAEditCollectionViewCell.swift
//  MemoryMaster
//
//  Created by apple on 4/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit

protocol QAEditCollectionViewCellDelegate: NoteEditCollectionViewCellDelegate {
    func filpQANoteCard(for cell: QAEditCollectionViewCell)
    func qaNoteAddPhoto(for textView: UITextView, at index: Int, with range: NSRange, cellStatus: CellStatus)

}

class QAEditCollectionViewCell: NoteEditCollectionViewCell {
    
    let questionLabel = UILabel()
    let answerLabel = UILabel()
    let filpButton = UIButton()
    
    weak var qaCellDelegate: QAEditCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func setupUI()
    {
        super.setupUI()
        let containerWidth = UIScreen.main.bounds.width - CustomDistance.viewToScreenEdgeDistance * 2
        
        questionLabel.frame = CGRect(x: (containerWidth - 120) / 2, y: CustomDistance.viewToScreenEdgeDistance, width: 120, height: 24)
        questionLabel.text = "QUESTION"
        questionLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        questionLabel.textColor = CustomColor.medianBlue
        questionLabel.textAlignment = .center
        backView.addSubview(questionLabel)
        
        answerLabel.frame = CGRect(x: (containerWidth - 120) / 2, y: CustomDistance.viewToScreenEdgeDistance, width: 120, height: 24)
        answerLabel.text = "ANSWER"
        answerLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 22)
        answerLabel.textColor = CustomColor.medianBlue
        answerLabel.textAlignment = .center
        answerLabel.isHidden = true
        answerLabel.alpha = 0.0
        backView.addSubview(answerLabel)

        filpButton.frame = CGRect(x: containerWidth - 28 - CustomDistance.viewToScreenEdgeDistance, y: CustomDistance.viewToScreenEdgeDistance - 2, width: 28, height: 28)
        filpButton.setImage(UIImage.init(named: "filp_icon"), for: .normal)
        filpButton.addTarget(self, action: #selector(filpCardAction), for: .touchUpInside)
        backView.addSubview(filpButton)
        
        bodyTextView.isHidden = true
        
        addPhotoButton.addTarget(self, action: #selector(addPhotoAction), for: .touchUpInside)
        photoBtnInTitleAccessoryView.addTarget(self, action: #selector(addPhotoAction), for: .touchUpInside)
        photoBtnInBodyAccessoryView.addTarget(self, action: #selector(addPhotoAction), for: .touchUpInside)
    }
    
    func updateCell(with cardContent: CardContent, at index: Int, total: Int, cellStatus: CellStatus) {
        super.cardIndex = index
        super.indexLabel.text = String.init(format: "%d / %d", index + 1, total)
        titleTextView.attributedText = cardContent.title
        bodyTextView.attributedText = cardContent.body
        if cellStatus == CellStatus.titleFront {
            questionLabel.alpha = 1.0
            answerLabel.alpha = 0.0
            questionLabel.isHidden = false
            answerLabel.isHidden = true
            titleTextView.alpha = 1.0
            bodyTextView.alpha = 0.0
            titleTextView.isHidden = false
            bodyTextView.isHidden = true
        } else {
            questionLabel.alpha = 0.0
            answerLabel.alpha = 1.0
            questionLabel.isHidden = true
            answerLabel.isHidden = false
            titleTextView.alpha = 0.0
            bodyTextView.alpha = 1.0
            titleTextView.isHidden = true
            bodyTextView.isHidden = false
        }
    }

    @objc func filpCardAction(_ sender: UIButton) {
        qaCellDelegate?.filpQANoteCard(for: self)
    }
    
    @objc func addPhotoAction(_ sender: UIButton) {
        if bodyTextView.isHidden {
            var range = titleTextView.selectedRange
            if range.location == NSNotFound {
                range.location = titleTextView.text.count
            }
            qaCellDelegate?.qaNoteAddPhoto(for: titleTextView, at: cardIndex!, with: range, cellStatus: CellStatus.titleFront)
        } else {
            var range = bodyTextView.selectedRange
            if range.location == NSNotFound {
                range.location = bodyTextView.text.count
            }
            qaCellDelegate?.qaNoteAddPhoto(for: bodyTextView, at: cardIndex!, with: range, cellStatus: CellStatus.bodyFrontWithTitle)
        }
    }
    
    func changeFilpButtonText() {
        if titleTextView.isHidden {
            UIView.animateKeyframes(withDuration: 0.5, delay: 0.3, options: [], animations: {
                self.questionLabel.alpha = 1.0
                self.answerLabel.alpha = 0.0
            }, completion: nil)
            questionLabel.isHidden = false
            answerLabel.isHidden = true
            titlePresent()
        } else {
            UIView.animateKeyframes(withDuration: 0.5, delay: 0.3, options: [], animations: {
                self.questionLabel.alpha = 0.0
                self.answerLabel.alpha = 1.0
            }, completion: nil)
            questionLabel.isHidden = true
            answerLabel.isHidden = false
            bodyPresent()
        }
    }
}


