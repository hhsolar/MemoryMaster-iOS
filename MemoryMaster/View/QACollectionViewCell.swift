//
//  QACollectionViewCell.swift
//  MemoryMaster
//
//  Created by apple on 3/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit
import MMCardView

protocol QACollectionViewCellDelegate: class {
    func toQANoteEdit(with indexPath: IndexPath)
    func toQANoteRead(with indexPath: IndexPath)
    func toQANoteTest(with indexPath: IndexPath)
}

class QACollectionViewCell: CardCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var testButton: UIButton!
    @IBOutlet weak var readButton: UIButton!
    
    // public api
    var cardIndexPath: IndexPath?
    
    @IBAction func toEdit(_ sender: UIButton) {
        if let indexPath = cardIndexPath {
            delegate?.toQANoteEdit(with: indexPath)
        }
    }
    
    @IBAction func toTest(_ sender: UIButton) {
        if let indexPath = cardIndexPath {
            delegate?.toQANoteTest(with: indexPath)
        }
    }
    
    @IBAction func toRead(_ sender: UIButton) {
        if let indexPath = cardIndexPath {
            delegate?.toQANoteRead(with: indexPath)
        }
    }
    
    weak var delegate: QACollectionViewCellDelegate?
    
    func updateCell(question: NSAttributedString, answer: NSAttributedString, index: Int) {
        self.layoutIfNeeded()
        let temp = NSMutableAttributedString.init(string: String(format: "%d. %@", index, question.string))
        if question.containsAttachments(in: NSRange.init(location: 0, length: question.length)) {
            let image = question.getAllImageAttachments(in: NSRange.init(location: 0, length: question.length)).imageArray[0]
            let imgTextAttach = NSTextAttachment()
            imgTextAttach.image = UIImage.reSizeImage(image, to: CGSize(width: nameLabel.bounds.height * image.size.width / image.size.height, height: nameLabel.bounds.height))!
            let imageAtt = NSAttributedString.init(attachment: imgTextAttach)
            temp.append(imageAtt)
        }
        nameLabel.attributedText = temp as NSAttributedString
        bodyTextView.attributedText = answer
        bodyTextView.contentOffset.y = 0
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        bodyTextView.isEditable = false
        bodyTextView.isScrollEnabled = true
        bodyTextView.showsHorizontalScrollIndicator = false
    }
}
