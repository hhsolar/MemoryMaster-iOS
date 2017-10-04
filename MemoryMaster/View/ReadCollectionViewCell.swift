//
//  ReadCollectionViewCell.swift
//  MemoryMaster
//
//  Created by apple on 3/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit

class ReadCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var bodyTextView: UITextView!
    
    func updateUI(title: String, body: String, index: Int) {
        let showString = NSMutableAttributedString(string: String(format: "%d. ", index), attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 16)])
        if title != "" {
            let titleAtt = NSAttributedString(string: title, attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 16)])
            let returnAtt = NSAttributedString(string: "\n\n")
            showString.append(titleAtt)
            showString.append(returnAtt)
        }
        
        let bodyAtt = NSAttributedString(string: body, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15)] )
        showString.append(bodyAtt)
        print(showString)
        
        bodyTextView.attributedText = showString
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bodyTextView.isEditable = false
//        self.layer.borderWidth = 1
//        self.layer.borderColor = UIColor.black.cgColor
        
    }

}
