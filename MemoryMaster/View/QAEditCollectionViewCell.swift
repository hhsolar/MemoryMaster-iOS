//
//  QAEditCollectionViewCell.swift
//  MemoryMaster
//
//  Created by apple on 4/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit

protocol QAEditCollectionViewCellDelegate: class {
    func addCard(currentCell: QAEditCollectionViewCell)
    func removeCard(for cell: QAEditCollectionViewCell)
    func changeTextContent(index: Int, question: String, answer: String)
}

class QAEditCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var answerTextView: UITextView!
    
    var cardIndex: Int?
    weak var delegate: QAEditCollectionViewCellDelegate?
    
    var questionText: String? {
        get {
            return questionTextView.text
        }
    }
    
    var answerText: String? {
        get {
            return answerTextView.text
        }
    }
    
    @IBAction func deleteAction(_ sender: UIButton) {
        delegate?.removeCard(for: self)
    }
    
    @IBAction func addAction(_ sender: UIButton) {
        delegate?.addCard(currentCell: self)
    }
    
    func updateCell(with card: QACard, at index: Int, total: Int) {
        cardIndex = index + 1
        indexLabel.text = String.init(format: "%d / %d", cardIndex!, total)
        questionTextView.text = card.question
        answerTextView.text = card.answer
    }

    func setupUI()
    {
        backView.backgroundColor = UIColor.white
        backView.layer.cornerRadius = 15
        backView.layer.masksToBounds = true
        
        indexLabel.textColor = CustomColor.medianBlue
        questionLabel.textColor = CustomColor.medianBlue
        answerLabel.textColor = CustomColor.medianBlue
        
        questionTextView.delegate = self
        answerTextView.delegate = self
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
}

extension QAEditCollectionViewCell: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        delegate?.changeTextContent(index: cardIndex! - 1, question: questionText!, answer: answerText!)
    }
}



