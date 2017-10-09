//
//  SingleEditCollectionViewCell.swift
//  MemoryMaster
//
//  Created by apple on 1/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit

protocol SingleEditCollectionViewCellDelegate: class {
    func addCard(currentCell: SingleEditCollectionViewCell)
    func removeCard(for cell: SingleEditCollectionViewCell)
    func addTitle(for cell: SingleEditCollectionViewCell)
    func addPhoto(for cell: SingleEditCollectionViewCell)
    func changeTextContent(index: Int, titleText: String, bodyText: String)
}

class SingleEditCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var addTitleButton: UIButton!
    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var photoButton: UIButton!
    
    var cardIndex: Int?
    weak var delegate: SingleEditCollectionViewCellDelegate?
    
    var titleButtonText = "ADD TITLE"
    
    var titleText: String? {
        get {
            return titleTextView.text
        }
    }
    
    var bodyText: String? {
        get {
            return bodyTextView.text
        }
    }
    
    var contentText: String? {
        get {
            return contentTextView.text
        }
    }
    
    @IBAction func deleteCardAction(_ sender: UIButton) {
        delegate?.removeCard(for: self)
    }
    
    @IBAction func addCardAction(_ sender: UIButton) {
        delegate?.addCard(currentCell: self)
    }
    
    @IBAction func addTitleAction(_ sender: UIButton) {
        delegate?.addTitle(for: self)
    }
    
    @IBAction func addPhotoAction(_ sender: UIButton) {
        delegate?.addPhoto(for: self)
    }
    
    func updataCell(with card: SingleCard, at index: Int, total: Int) {
        cardIndex = index + 1
        indexLabel.text = String.init(format: "%d / %d", cardIndex!, total)
        contentTextView.text = card.body
        bodyTextView.text = card.body
        if card.title != "" {
            addTitle()
            titleTextView.text = card.title
        } else {
            removeTitle()
        }
    }
    
    func setupUI()
    {
        backView.backgroundColor = UIColor.white
        backView.layer.cornerRadius = 15
        backView.layer.masksToBounds = true
        
        indexLabel.textColor = CustomColor.medianBlue
        
        addTitleButton.backgroundColor = CustomColor.medianBlue
        addTitleButton.setTitleColor(UIColor.white, for: .normal)
        addTitleButton.layer.cornerRadius = 13
        addTitleButton.layer.masksToBounds = true
        
        titleTextView.layer.cornerRadius = 10
        titleTextView.layer.masksToBounds = true
        titleTextView.layer.borderWidth = 1
        titleTextView.layer.borderColor = CustomColor.medianBlue.cgColor
        titleTextView.font = UIFont(name: "HelveticaNeue-Bold", size: 14)
        titleTextView.isHidden = true
        
        bodyTextView.layer.cornerRadius = 10
        bodyTextView.layer.masksToBounds = true
        bodyTextView.layer.borderWidth = 1
        bodyTextView.layer.borderColor = CustomColor.medianBlue.cgColor
        bodyTextView.isHidden = true
        
        titleTextView.delegate = self
        bodyTextView.delegate = self
        contentTextView.delegate = self

    }
    
    func addTitle() {
        titleButtonText = "REMOVE TITLE"
        bodyTextView.text = contentTextView.text
        addTitleButton.setTitle("REMOVE TITLE", for: .normal)
        
        UIView.animateKeyframes(withDuration: 0.5, delay: 0.3, options: [], animations: {
            self.contentTextView.alpha = 0.0
            self.titleTextView.alpha = 1.0
            self.bodyTextView.alpha = 1.0
        },
            completion: nil
        )
        contentTextView.isHidden = true
        titleTextView.isHidden = false
        bodyTextView.isHidden = false
    }
    
    func removeTitle() {
        contentTextView.text = bodyTextView.text
        addTitleButton.setTitle("ADD TITLE", for: .normal)
        titleButtonText = "ADD TITLE"
        
        UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: {
            self.contentTextView.alpha = 1.0
            self.titleTextView.alpha = 0.0
            self.bodyTextView.alpha = 0.0
        },
            completion: nil
        )
        titleTextView.isHidden = true
        bodyTextView.isHidden = true
        contentTextView.isHidden = false
        titleTextView.text = ""
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
}

extension SingleEditCollectionViewCell: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        if contentTextView.isHidden {
            delegate?.changeTextContent(index: cardIndex! - 1, titleText: titleText!, bodyText: bodyText!)
        } else {
            delegate?.changeTextContent(index: cardIndex! - 1, titleText: titleText!, bodyText: contentText!)
        }
    }
}
