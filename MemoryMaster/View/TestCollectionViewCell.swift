//
//  TestCollectionViewCell.swift
//  MemoryMaster
//
//  Created by apple on 4/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit
import QuartzCore

class TestCollectionViewCell: UICollectionViewCell, UITextViewDelegate {

    // public api
    var questionAtFront = true
    
    @IBOutlet weak var containerView: UIView!
    let questionView = UIView()
    let answerView = UIView()
    let questionLabel = UILabel()
    let answerLabel = UILabel()
    let qTextView = UITextView()
    let aTextView = UITextView()
    let indexLabel = UILabel()
    
    weak var delegate: EnlargeImageCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    func updateUI(question: NSAttributedString, answer: NSAttributedString, index: Int, total: Int) {
        qTextView.attributedText = question.addAttributesForText(CustomRichTextAttri.bodyNormal, range: NSRange.init(location: 0, length: question.length))
        aTextView.attributedText = answer.addAttributesForText(CustomRichTextAttri.bodyNormal, range: NSRange.init(location: 0, length: answer.length))
        indexLabel.text = String(format: "%d / %d", index + 1, total)
    }
    
    private func setupUI() {
        containerView.addSubview(answerView)
        containerView.addSubview(questionView)
        containerView.backgroundColor = UIColor.white
        
        questionView.backgroundColor = CustomColor.lightBlue
        questionView.addSubview(questionLabel)
        questionView.addSubview(qTextView)
        questionView.addSubview(indexLabel)
        
        answerView.backgroundColor = CustomColor.lightGreen
        answerView.addSubview(answerLabel)
        answerView.addSubview(aTextView)
        
        questionLabel.text = "QUESTION"
        questionLabel.textAlignment = .center
        questionLabel.textColor = CustomColor.deepBlue
        questionLabel.font = UIFont(name: "Helvetica-Bold", size: CustomFont.FontSizeMid)
        questionLabel.adjustsFontSizeToFitWidth = true
        
        indexLabel.textAlignment = .center
        indexLabel.textColor = CustomColor.deepBlue
        indexLabel.font = UIFont(name: "Helvetica-Bold", size: CustomFont.FontSizeMid)
        
        answerLabel.text = "ANSWER"
        answerLabel.textAlignment = .center
        answerLabel.textColor = CustomColor.deepBlue
        answerLabel.font = UIFont(name: "Helvetica-Bold", size: CustomFont.FontSizeMid)
        answerLabel.adjustsFontSizeToFitWidth = true

        qTextView.isEditable = false
        qTextView.font = UIFont(name: "Helvetica", size: 16)
        qTextView.textColor = UIColor.darkGray
        qTextView.backgroundColor = CustomColor.lightBlue
        qTextView.showsVerticalScrollIndicator = false
        qTextView.delegate = self
        
        aTextView.isEditable = false
        aTextView.font = UIFont(name: "Helvetica", size: 16)
        aTextView.textColor = UIColor.darkGray
        aTextView.backgroundColor = CustomColor.lightGreen
        aTextView.showsVerticalScrollIndicator = false
        aTextView.delegate = self
    }
    
    override func layoutSubviews() {
        super .layoutSubviews()
        containerView.layer.cornerRadius = 15
        containerView.layer.masksToBounds = true
        
        questionView.frame = CGRect(x: 0, y: 0, width: contentView.bounds.width - CustomDistance.midEdge * 2, height: contentView.bounds.height - CustomDistance.midEdge * 2)
        questionView.layer.cornerRadius = 15
        questionView.layer.masksToBounds = true
        questionView.layer.borderWidth = 3
        questionView.layer.borderColor = CustomColor.deepBlue.cgColor
        
        questionView.layer.shadowOpacity = 0.8
        questionView.layer.shadowColor = UIColor.gray.cgColor
        questionView.layer.shadowRadius = 10
        questionView.layer.shadowOffset = CGSize(width: 1, height: 1)
        
        answerView.frame = questionView.frame
        answerView.layer.cornerRadius = 15
        answerView.layer.masksToBounds = true
        answerView.layer.borderWidth = 3
        answerView.layer.borderColor = CustomColor.deepBlue.cgColor
        
        answerView.layer.shadowOpacity = 0.8
        answerView.layer.shadowColor = UIColor.gray.cgColor
        answerView.layer.shadowRadius = 10
        answerView.layer.shadowOffset = CGSize(width: 1, height: 1)
        
        questionLabel.frame = CGRect(x: questionView.bounds.midX - questionView.bounds.width / 6, y: CustomDistance.midEdge, width: questionView.bounds.width / 3, height: CustomSize.titleLabelHeight)
        qTextView.frame = CGRect(x: 0, y: CustomDistance.midEdge * 2 + CustomSize.titleLabelHeight, width: questionView.bounds.width, height: questionView.bounds.height - CustomDistance.midEdge * 4 - CustomSize.titleLabelHeight * 2)
        qTextView.textContainerInset = UIEdgeInsets(top: 0, left: CustomDistance.narrowEdge, bottom: 0, right: CustomDistance.narrowEdge)
        
        indexLabel.frame = CGRect(x: questionView.bounds.midX - questionView.bounds.width / 6, y: questionView.bounds.height - CustomSize.titleLabelHeight - CustomDistance.midEdge, width: questionView.bounds.width / 3, height: CustomSize.titleLabelHeight)
        
        answerLabel.frame = questionLabel.frame
        aTextView.frame = qTextView.frame
        aTextView.textContainerInset = UIEdgeInsets(top: 0, left: CustomDistance.narrowEdge, bottom: 0, right: CustomDistance.narrowEdge)
        aTextView.frame.size.height += (CustomDistance.midEdge + CustomSize.titleLabelHeight)
    }
    
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        var image: UIImage? = nil
        if textAttachment.image != nil {
            image = textAttachment.image
        } else {
            image = textAttachment.image(forBounds: textAttachment.bounds, textContainer: nil, characterIndex: characterRange.location)
        }
        
        if let image = image {
            delegate?.enlargeTapedImage(image: image)
        }
        return true
    }
}
