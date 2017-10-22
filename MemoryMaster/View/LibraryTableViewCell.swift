//
//  LibraryTableViewCell.swift
//  MemoryMaster
//
//  Created by apple on 3/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit

class LibraryTableViewCell: UITableViewCell {

    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberOfCardLabel: UILabel!
        
    let backView = BorderUIView()
    let lastCell = ""
    
    func updateCell(with card: BasicNoteInfo, lastCardType: String) {
        nameLabel.text = card.name
        numberOfCardLabel.text = String(format: "%d items", card.numberOfCard)
        if card.type == NoteType.single.rawValue {
            iconImageView.image = UIImage(named: "single_icon_unclick.png")
            backView.backgroundColor = CustomColor.lightGreen
        } else if card.type == NoteType.qa.rawValue {
            iconImageView.image = UIImage(named: "qa_icon_unclick.png")
            backView.backgroundColor = CustomColor.lightBlue
        }
        if lastCardType == NoteType.single.rawValue {
            bottomView.backgroundColor = CustomColor.lightGreen
        } else if lastCardType == NoteType.qa.rawValue {
            bottomView.backgroundColor = CustomColor.lightBlue
        } else {
            bottomView.backgroundColor = UIColor.white
        }
    }
    
    private func setupUI() {
        backView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: contentView.bounds.height)
        self.contentView.addSubview(backView)
        self.contentView.sendSubview(toBack: backView)
        
        
        
        let rect = CGRect(x: 0, y: 0, width: backView.bounds.width, height: backView.bounds.height)
        let radio = CGSize(width: 10, height: 10)
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft, .topRight], cornerRadii: radio)
        let masklayer = CAShapeLayer()
        masklayer.frame = backView.bounds
        masklayer.path = path.cgPath
        backView.layer.mask = masklayer
        
        self.contentView.sendSubview(toBack: bottomView)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
}
