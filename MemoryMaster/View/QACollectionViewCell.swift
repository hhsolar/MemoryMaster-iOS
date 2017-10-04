//
//  QACollectionViewCell.swift
//  MemoryMaster
//
//  Created by apple on 3/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit
import MMCardView

class QACollectionViewCell: CardCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var testButton: UIButton!
    @IBOutlet weak var readButton: UIButton!
    
    func updateCell(question: String, answer: String, index: Int) {
        nameLabel.text = String(format: "%d. %@", index, question)
        bodyLabel.text = answer
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
