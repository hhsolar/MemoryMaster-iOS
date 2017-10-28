//
//  EditNoteCollectionViewCell.swift
//  MemoryMaster
//
//  Created by apple on 23/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit

protocol EditNoteCollectionViewCellDelegate: class {
    func noteTitleEdit(for cell: EditNoteCollectionViewCell)
    func noteTextContentChange(cardIndex: Int, textViewType: String, textContent: NSAttributedString)
    func noteAddPhoto()
}

class EditNoteCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var titleEditButton: UIButton!
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var bodyTextView: UITextView!
    
    let titleTextView = UITextView()
    let titleKeyboardAddPhotoButton = UIButton()
    let bodyKeyboardAddPhotoButton = UIButton()
    
    var cardIndex: Int?
    var currentStatus: CardStatus?
    var editingTextView: UITextView?
    
    weak var delegate: EditNoteCollectionViewCellDelegate?
    
    var titleText: NSAttributedString? {
        get {
            return titleTextView.attributedText
        }
    }
    
    var bodyText: NSAttributedString? {
        get {
            return bodyTextView.attributedText
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI()
    {
        contentView.backgroundColor = CustomColor.paperColor
        
        titleEditButton.setTitleColor(CustomColor.medianBlue, for: .normal)
        
        // titleTextView
        titleTextView.textContainerInset = UIEdgeInsets(top: 0, left: CustomDistance.wideEdge, bottom: 0, right: CustomDistance.wideEdge)
        titleTextView.backgroundColor = CustomColor.paperColor
        titleTextView.tag = OutletTag.titleTextView.rawValue
        titleTextView.showsVerticalScrollIndicator = false
        titleTextView.delegate = self
        contentView.addSubview(titleTextView)
        
        let titleAccessoryView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        titleKeyboardAddPhotoButton.frame = CGRect(x: UIScreen.main.bounds.width - CustomDistance.midEdge - CustomSize.smallBtnHeight, y: 0, width: CustomSize.smallBtnHeight, height: CustomSize.smallBtnHeight)
        titleKeyboardAddPhotoButton.setImage(UIImage.init(named: "photo_icon"), for: .normal)
        titleKeyboardAddPhotoButton.addTarget(self, action: #selector(addPhotoAction), for: .touchUpInside)
        titleAccessoryView.addSubview(titleKeyboardAddPhotoButton)
        titleTextView.inputAccessoryView = titleAccessoryView
        
        // bodyTextView
        bodyTextView.textContainerInset = UIEdgeInsets(top: 0, left: CustomDistance.wideEdge, bottom: 0, right: CustomDistance.wideEdge)
        bodyTextView.backgroundColor = CustomColor.paperColor
        bodyTextView.tag = OutletTag.bodyTextView.rawValue
        bodyTextView.showsVerticalScrollIndicator = false
        bodyTextView.delegate = self
        
        let bodyAccessoryView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        bodyKeyboardAddPhotoButton.frame = CGRect(x: UIScreen.main.bounds.width - CustomDistance.midEdge - CustomSize.smallBtnHeight, y: 0, width: CustomSize.smallBtnHeight, height: CustomSize.smallBtnHeight)
        bodyKeyboardAddPhotoButton.setImage(UIImage.init(named: "photo_icon"), for: .normal)
        bodyKeyboardAddPhotoButton.addTarget(self, action: #selector(addPhotoAction), for: .touchUpInside)
        bodyAccessoryView.addSubview(bodyKeyboardAddPhotoButton)
        bodyTextView.inputAccessoryView = bodyAccessoryView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleTextView.frame = bodyTextView.frame
    }
    
    func updateCell(with cardContent: CardContent, at index: Int, total: Int, cellStatus: CardStatus, noteType: NoteType) {
        cardIndex = index
        currentStatus = cellStatus
        indexLabel.text = String.init(format: "%d / %d", index + 1, total)
        bodyTextView.attributedText = cardContent.body.addAttributesForText(CustomRichTextAttri.bodyNormal, range: NSRange(location: 0, length: cardContent.body.length))
        if noteType == NoteType.single {
            titleEditButton.isHidden = false
        } else {
            titleEditButton.isHidden = true
        }
        switch cellStatus {
        case .titleFront:
            titleTextView.attributedText = cardContent.title.addAttributesForText(CustomRichTextAttri.bodyNormal, range: NSRange(location: 0, length: cardContent.title.length))
            showTitle(noteType: noteType)
        case .bodyFrontWithTitle:
            titleTextView.attributedText = cardContent.title.addAttributesForText(CustomRichTextAttri.bodyNormal, range: NSRange(location: 0, length: cardContent.title.length))
            showBody(noteType: noteType)
        default:
            showBody(noteType: noteType)
            titleTextView.attributedText = NSAttributedString()
        }
    }
    
    func showTitle(noteType: NoteType)
    {
        UIView.animateKeyframes(withDuration: 0.5, delay: 0.3, options: [], animations: {
            if noteType == NoteType.single {
                self.titleEditButton.setTitle("Remove Title", for: .normal)
                self.titleLable.text = "Title"
            } else {
                self.titleLable.text = "Question"
            }
            self.titleTextView.alpha = 1.0
            self.bodyTextView.alpha = 0.0
            }, completion: nil)
        titleTextView.isHidden = false
        bodyTextView.isHidden = true
        bodyTextView.resignFirstResponder()
        editingTextView = titleTextView
    }
    
    func showBody(noteType: NoteType)
    {
        UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: {
            if noteType == NoteType.single {
                self.titleLable.text = ""
                if self.currentStatus == CardStatus.bodyFrontWithTitle {
                    self.titleEditButton.setTitle("Remove Title", for: .normal)
                    
                } else {
                    self.titleEditButton.setTitle("Add Title", for: .normal)
                }
            } else {
                self.titleLable.text = "Answer"
            }
            self.titleTextView.alpha = 0.0
            self.bodyTextView.alpha = 1.0
            }, completion: nil)
        titleTextView.isHidden = true
        bodyTextView.isHidden = false
        titleTextView.resignFirstResponder()
        editingTextView = bodyTextView
    }
    
    @IBAction func titleEditAction(_ sender: UIButton) {
        delegate?.noteTitleEdit(for: self)
    }
    
    @objc func addPhotoAction() {
        delegate?.noteAddPhoto()
    }
    
    func cutTextView(KBHeight: CGFloat) {
        editingTextView?.frame.size.height = contentView.bounds.height + CustomSize.barHeight - KBHeight - CustomSize.buttonHeight
    }
    
    func extendTextView() {
        editingTextView?.frame.size.height = contentView.bounds.height - CustomSize.buttonHeight
    }
}

extension EditNoteCollectionViewCell: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        if textView.tag == OutletTag.titleTextView.rawValue {
            delegate?.noteTextContentChange(cardIndex: cardIndex!, textViewType: "title", textContent: titleText!)
        } else if textView.tag == OutletTag.bodyTextView.rawValue {
            delegate?.noteTextContentChange(cardIndex: cardIndex!, textViewType: "body", textContent: bodyText!)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.markedTextRange == nil {
            let range = textView.selectedRange
            let attrubuteStr = NSMutableAttributedString(attributedString: textView.attributedText)
            attrubuteStr.addAttributes(CustomRichTextAttri.bodyNormal, range: NSRange(location: 0, length: textView.text.count))
            textView.attributedText = attrubuteStr
            textView.selectedRange = range
        }
    }
    
}
