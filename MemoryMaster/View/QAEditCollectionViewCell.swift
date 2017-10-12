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
    }
    
    func updateCell(with cardContent: CardContent, at index: Int, total: Int) {
        super.cardIndex = index
        super.indexLabel.text = String.init(format: "%d / %d", index + 1, total)
        titleTextView.attributedText = cardContent.title
        bodyTextView.attributedText = cardContent.body
    }

    @objc func filpCardAction(_ sender: UIButton) {
        qaCellDelegate?.filpQANoteCard(for: self)
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


