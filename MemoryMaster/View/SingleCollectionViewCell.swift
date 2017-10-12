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
    @IBOutlet weak var bodyLabel: UILabel!
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
    
    func updateCell(title: String, body: NSAttributedString, index: Int) {
        if title == "" {
            nameLabel.text = String(format: "%d. %@", index, body.string)
        } else {
            nameLabel.text = String(format: "%d. %@", index, title)
        }
        bodyLabel.attributedText = body
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
