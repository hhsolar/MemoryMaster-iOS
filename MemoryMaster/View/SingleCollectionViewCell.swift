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
    func editAction(with indexPath: IndexPath)
    func readAction(with indexPath: IndexPath)
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
            delegate?.editAction(with: indexPath)
        }
    }
    
    @IBAction func toRead(_ sender: UIButton) {
        if let indexPath = cardIndexPath {
            delegate?.readAction(with: indexPath)
        }
    }
    
    weak var delegate: SingleCollectionViewCellDelegate?
    
    func updateCell(title: String, body: String, index: Int) {
        if title == "" {
            nameLabel.text = String(format: "%d. %@", index, body)
        } else {
            nameLabel.text = String(format: "%d. %@", index, title)
        }
        bodyLabel.text = body
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
