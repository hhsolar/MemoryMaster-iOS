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
    @IBOutlet weak var bodyLabel: UILabel!
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
    
    func updateCell(question: String, answer: String, index: Int) {
        nameLabel.text = String(format: "%d. %@", index, question)
        bodyLabel.text = answer
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
