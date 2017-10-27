//
//  SingleCollectionViewCell.swift
//  MemoryMaster
//
//  Created by apple on 3/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit
import MMCardView

protocol SingleCollectionViewCellDelegate: class {
    func toSingleNoteEdit(with indexPath: IndexPath)
    func toSingleNoteRead(with indexPath: IndexPath)
}

class SingleCollectionViewCell: CardCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var readButton: UIButton!
    
    // public api
    var cardIndexPath: IndexPath?
    
    @IBAction func toEdit(_ sender: UIButton) {
        if let indexPath = cardIndexPath {
            delegate?.toSingleNoteEdit(with: indexPath)
        }
    }
    
    @IBAction func toRead(_ sender: UIButton) {
        if let indexPath = cardIndexPath {
            delegate?.toSingleNoteRead(with: indexPath)
        }
    }
    
    weak var delegate: SingleCollectionViewCellDelegate?
    
    func updateCell(title: NSAttributedString, body: NSAttributedString, index: Int) {
        if title == NSAttributedString() {
            nameLabel.attributedText = prepareForTitle(text: body, index: index, height: nameLabel.bounds.height)
        } else {
            nameLabel.attributedText = prepareForTitle(text: title, index: index, height: nameLabel.bounds.height)
        }
        bodyTextView.attributedText = body
        bodyTextView.contentOffset.y = 0
    }
    
    private func prepareForTitle(text: NSAttributedString, index: Int, height: CGFloat) -> NSAttributedString {
        let temp = NSMutableAttributedString.init(string: String(format: "%d. %@", index, text.string))
        if text.containsAttachments(in: NSRange.init(location: 0, length: text.length)) {
            let image = text.getAllImageAttachments(in: NSRange.init(location: 0, length: text.length)).imageArray[0]
            let imgTextAttach = NSTextAttachment()
            imgTextAttach.image = UIImage.reSizeImage(image, to: CGSize(width: height * image.size.width / image.size.height, height: height))!
            let imageAtt = NSAttributedString.init(attachment: imgTextAttach)
            temp.append(imageAtt)
        }
        return temp as NSMutableAttributedString
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bodyTextView.isEditable = false
        bodyTextView.isScrollEnabled = true
        bodyTextView.showsHorizontalScrollIndicator = false
    }

}
