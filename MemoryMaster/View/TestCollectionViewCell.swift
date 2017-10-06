//
//  TestCollectionViewCell.swift
//  MemoryMaster
//
//  Created by apple on 4/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit
import QuartzCore

class TestCollectionViewCell: UICollectionViewCell {

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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    func updateUI(question: String, answer: String, index: Int, total: Int) {
        qTextView.text = question
        aTextView.text = answer
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
        questionLabel.font = UIFont(name: "Helvetica-Bold", size: 20)
        
        indexLabel.textAlignment = .center
        indexLabel.textColor = CustomColor.deepBlue
        indexLabel.font = UIFont(name: "Helvetica-Bold", size: 18)
        
        answerLabel.text = "ANSWER"
        answerLabel.textAlignment = .center
        answerLabel.textColor = CustomColor.deepBlue
        answerLabel.font = UIFont(name: "Helvetica-Bold", size: 20)

        qTextView.isEditable = false
        qTextView.font = UIFont(name: "Helvetica", size: 16)
        qTextView.textColor = UIColor.darkGray
        qTextView.backgroundColor = CustomColor.lightBlue
        
        aTextView.isEditable = false
        aTextView.font = UIFont(name: "Helvetica", size: 16)
        aTextView.textColor = UIColor.darkGray
        aTextView.backgroundColor = CustomColor.lightGreen
    }
    
    override func layoutSubviews() {
        super .layoutSubviews()
        containerView.layer.cornerRadius = 15
        containerView.layer.masksToBounds = true
        
        questionView.frame = CGRect(x: 0, y: 0, width: contentView.bounds.width - 40, height: contentView.bounds.height - 40)
        questionView.layer.cornerRadius = 15
        questionView.layer.masksToBounds = true
        questionView.layer.borderWidth = 3
        questionView.layer.borderColor = CustomColor.deepBlue.cgColor
        
        questionView.layer.shadowOpacity = 0.8
        questionView.layer.shadowColor = UIColor.gray.cgColor
        questionView.layer.shadowRadius = 10
        questionView.layer.shadowOffset = CGSize(width: 1, height: 1)
        
        answerView.frame = CGRect(x: 0, y: 0, width: contentView.bounds.width - 40, height: contentView.bounds.height - 40)
        answerView.layer.cornerRadius = 15
        answerView.layer.masksToBounds = true
        answerView.layer.borderWidth = 3
        answerView.layer.borderColor = CustomColor.deepBlue.cgColor
        
        answerView.layer.shadowOpacity = 0.8
        answerView.layer.shadowColor = UIColor.gray.cgColor
        answerView.layer.shadowRadius = 10
        answerView.layer.shadowOffset = CGSize(width: 1, height: 1)
        
        questionLabel.frame = CGRect(x: questionView.bounds.midX - questionView.bounds.width / 6, y: 20, width: questionView.bounds.width / 3, height: 24)
        qTextView.frame = CGRect(x: 20, y: questionLabel.frame.origin.y + 44, width: questionView.bounds.width - 40, height: questionView.bounds.height - questionLabel.frame.origin.y - 44 - 62)
        
        indexLabel.frame = CGRect(x: questionView.bounds.midX - questionView.bounds.width / 6, y: questionView.bounds.height - 42, width: questionView.bounds.width / 3, height: 22)
        
        answerLabel.frame = CGRect(x: answerView.bounds.midX - answerView.bounds.width / 6, y: 20, width: answerView.bounds.width / 3, height: 24)
        aTextView.frame = CGRect(x: 20, y: answerLabel.frame.origin.y + 44, width: answerView.bounds.width - 40, height: answerView.bounds.height - answerLabel.frame.origin.y - 64)
    }
}
