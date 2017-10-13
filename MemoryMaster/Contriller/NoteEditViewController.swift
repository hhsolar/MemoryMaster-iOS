//
//  NoteEditViewController.swift
//  MemoryMaster
//
//  Created by apple on 10/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit
import CoreData
import SVProgressHUD

protocol NoteEditViewControllerDelegate: class {
    func passNoteInforBack(noteInfo: MyBasicNoteInfo)
}

class NoteEditViewController: UIViewController {

    // public api
    var isFirstTimeEdit = false
    var passedInNoteInfo: MyBasicNoteInfo? {
        didSet {
            minAddCardIndex = passedInNoteInfo?.numberOfCard
            minRemoveCardIndex = passedInNoteInfo?.numberOfCard
            if passedInNoteInfo?.type == NoteType.single.rawValue {
                addPhotoCellStatus = CellStatus.bodyFrontWithoutTitle
            } else if passedInNoteInfo?.type == NoteType.qa.rawValue {
                addPhotoCellStatus = CellStatus.titleFront
            }
        }
    }
    var passedInCardIndex: IndexPath?
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer {
        didSet {
            updateUI()
        }
    }
    
    // public api for cell
    var currentCardIndex: Int?
    var currentTextView: UITextView?
    var passInRange: NSRange?
    var addPhotoCellStatus: CellStatus?

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var editCollectionView: UICollectionView!
    
    var notes = [CardContent]()
    var changedCard = Set<Int>()
    
    var minAddCardIndex: Int?
    var minRemoveCardIndex: Int?
    
    weak var delegate: NoteEditViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editCollectionView.setNeedsLayout()
        if let cardIndex = passedInCardIndex {
            editCollectionView.scrollToItem(at: cardIndex, at: .left, animated: false)
        }
    }
    
    private func updateUI() {
        if let info = passedInNoteInfo {
            for i in 0..<info.numberOfCard {
                let cardContent = CardContent.getCardContent(with: info.name, at: i, in: info.type)
                notes.append(cardContent)
            }
        }
    }
    
    private func setupUI()
    {
        titleLabel.text = passedInNoteInfo?.name ?? "No name"
        titleLabel.textColor = CustomColor.medianBlue
        
        self.view.backgroundColor = UIColor.lightGray
        topView.backgroundColor = CustomColor.lightGreen
        
        topView.layer.cornerRadius = 15
        topView.layer.masksToBounds = true
        
        editCollectionView.delegate = self
        editCollectionView.dataSource = self
        editCollectionView.isPagingEnabled = true
        editCollectionView.showsHorizontalScrollIndicator = false
        editCollectionView.backgroundColor = UIColor.lightGray
        
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize(width: editCollectionView.bounds.width, height: editCollectionView.bounds.height)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        editCollectionView.collectionViewLayout = layout
        
        editCollectionView.register(SingleEditCollectionViewCell.self, forCellWithReuseIdentifier: "SingleEditCollectionViewCell")
        editCollectionView.register(QAEditCollectionViewCell.self, forCellWithReuseIdentifier: "QAEditCollectionViewCell")
    }

    @IBAction func saveNote(_ sender: UIButton) {
        save()
        showSavedPrompt()
    }
    
    private func save() {
        let minChangedIndex = minRemoveCardIndex! < minAddCardIndex! ? minRemoveCardIndex! : minAddCardIndex!

        if minChangedIndex == (passedInNoteInfo?.numberOfCard)! && notes.count == (passedInNoteInfo?.numberOfCard)!
        {
            // case 1: no card added or removed
            for i in changedCard {
                notes[i].title.saveTextToFile(with: (passedInNoteInfo?.name)!, at: i, in: (passedInNoteInfo?.type)!, contentType: "title")
                notes[i].body.saveTextToFile(with: (passedInNoteInfo?.name)!, at: i, in: (passedInNoteInfo?.type)!, contentType: "body")
            }
        } else if minChangedIndex == (passedInNoteInfo?.numberOfCard)! && notes.count > (passedInNoteInfo?.numberOfCard)!
        {
            // case 2: card only add or removed after original length
            for i in minChangedIndex..<notes.count {
                notes[i].title.saveTextToFile(with: (passedInNoteInfo?.name)!, at: i, in: (passedInNoteInfo?.type)!, contentType: "title")
                notes[i].body.saveTextToFile(with: (passedInNoteInfo?.name)!, at: i, in: (passedInNoteInfo?.type)!, contentType: "body")
            }
            
            for i in changedCard {
                notes[i].title.saveTextToFile(with: (passedInNoteInfo?.name)!, at: i, in: (passedInNoteInfo?.type)!, contentType: "title")
                notes[i].body.saveTextToFile(with: (passedInNoteInfo?.name)!, at: i, in: (passedInNoteInfo?.type)!, contentType: "body")
            }
        } else
        {
            // case 3: card inserted or removed in original array range
            for i in minChangedIndex..<(passedInNoteInfo?.numberOfCard)! {
                CardContent.removeCardContent(with: (passedInNoteInfo?.name)!, at: i, in: (passedInNoteInfo?.type)!)
            }
            if minChangedIndex <= notes.count {
                for i in minChangedIndex..<notes.count {
                    notes[i].title.saveTextToFile(with: (passedInNoteInfo?.name)!, at: i, in: (passedInNoteInfo?.type)!, contentType: "title")
                    notes[i].body.saveTextToFile(with: (passedInNoteInfo?.name)!, at: i, in: (passedInNoteInfo?.type)!, contentType: "body")
                }
            }
            
            for i in changedCard {
                if i < minChangedIndex {
                    notes[i].title.saveTextToFile(with: (passedInNoteInfo?.name)!, at: i, in: (passedInNoteInfo?.type)!, contentType: "title")
                    notes[i].body.saveTextToFile(with: (passedInNoteInfo?.name)!, at: i, in: (passedInNoteInfo?.type)!, contentType: "body")
                } else {
                    break
                }
            }
        }
        changedCard.removeAll()
        
        passedInNoteInfo?.numberOfCard = notes.count
        let context = container?.viewContext
        _ = try? BasicNoteInfo.findOrCreate(matching: self.passedInNoteInfo!, in: context!)
        try? context?.save()
    }
    
    private func showSavedPrompt() {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setFadeInAnimationDuration(0.2)
        SVProgressHUD.showSuccess(withStatus: "Saved!")
        SVProgressHUD.dismiss(withDelay: 0.9)
        SVProgressHUD.setFadeOutAnimationDuration(0.4)
    }
    
    @IBAction func exit(_ sender: UIButton) {
        let minChangedIndex = minRemoveCardIndex! < minAddCardIndex! ? minRemoveCardIndex! : minAddCardIndex!

        if changedCard.isEmpty && minChangedIndex == (passedInNoteInfo?.numberOfCard)! && notes.count == (passedInNoteInfo?.numberOfCard)! {
            if let context = container?.viewContext {
                _ = try? BasicNoteInfo.findOrCreate(matching: passedInNoteInfo!, in: context)
                try? context.save()
            }
            dismissView()
        } else {
            let alert = UIAlertController(title: "Reminder!", message: "Do you want to save your change?", preferredStyle: .alert)
            let yes = UIAlertAction(title: "YES", style: .default, handler: { [weak self] action in
                self?.save()
                self?.showSavedPrompt()
            })
            let no = UIAlertAction(title: "NO", style: .default, handler: { [weak self] action in
                self?.dismissView()
            })
            let cancel = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
            alert.addAction(yes)
            alert.addAction(no)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func dismissView() {
        delegate?.passNoteInforBack(noteInfo: passedInNoteInfo!)
        guard isFirstTimeEdit else {
            dismiss(animated: true, completion: nil)
            return
        }
        let controller = self.presentingViewController?.presentingViewController
        controller?.dismiss(animated: true, completion: nil)
    }
}

extension NoteEditViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let noteInfo = passedInNoteInfo {
            if noteInfo.type == NoteType.single.rawValue {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SingleEditCollectionViewCell", for: indexPath) as! SingleEditCollectionViewCell
                cell.singleCellDelegate = self
                cell.delegate = self
                cell.awakeFromNib()
                cell.setNeedsLayout()
                cell.updataCell(with: notes[indexPath.row], at: indexPath.row, total: notes.count, cellStatus: addPhotoCellStatus!)
                addPhotoCellStatus = CellStatus.bodyFrontWithoutTitle
                return cell
            } else if noteInfo.type == NoteType.qa.rawValue {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QAEditCollectionViewCell", for: indexPath) as! QAEditCollectionViewCell
                cell.qaCellDelegate = self
                cell.delegate = self
                cell.awakeFromNib()
                cell.setNeedsLayout()
                cell.updateCell(with: notes[indexPath.row], at: indexPath.row, total: notes.count, cellStatus: addPhotoCellStatus!)
                addPhotoCellStatus = CellStatus.titleFront
                return cell
            }
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SingleEditCollectionViewCell", for: indexPath) as! SingleEditCollectionViewCell
        return cell
    }
}

extension NoteEditViewController {
    func addNoteCard(for cell: NoteEditCollectionViewCell) {
        let cardContent = CardContent(title: NSAttributedString.init(), body: NSAttributedString.init())
        editCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
        let index = cell.cardIndex! + 1
        notes.insert(cardContent, at: index)
        editCollectionView.reloadData()
        editCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .left, animated: true)
        editCollectionView.reloadItems(at: [IndexPath(item: index - 1, section: 0)])
        
        if var minIndex = minAddCardIndex, minIndex > index {
            minIndex = index
        }
    }
    
    func removeNoteCard(for cell: NoteEditCollectionViewCell) {
        if notes.count == 1 {
            self.showAlert(title: "Error!", message: "A note must has one item at least.")
            return
        }
        let index = cell.cardIndex!

        if index == 0 {
            editCollectionView.scrollToItem(at: IndexPath(item: index + 1, section: 0), at: .left, animated: true)
            notes.remove(at: index)
            editCollectionView.reloadData()
            // have to add function reloadItems, or there will be a cell not update
            editCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            editCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .left, animated: true)
            return
        }
        editCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
        notes.remove(at: index)
        editCollectionView.reloadData()
        editCollectionView.scrollToItem(at: IndexPath(item: index - 1, section: 0), at: .left, animated: true)
        editCollectionView.reloadItems(at: [IndexPath(item: index - 1, section: 0)])
        
        if var minIndex = minRemoveCardIndex, minIndex > index {
            minIndex = index
        }
    }
    
    func noteTextContentChange(cardIndex: Int, textViewType: String, textContent: NSAttributedString) {
        if textViewType == "title" {
            if !notes[cardIndex].title.isEqual(to: textContent) {
                notes[cardIndex].title = textContent
                if cardIndex < (passedInNoteInfo?.numberOfCard)! {
                    changedCard.insert(cardIndex)
                }
            }
        } else {
            if !notes[cardIndex].body.isEqual(to: textContent) {
                notes[cardIndex].body = textContent
                if cardIndex < (passedInNoteInfo?.numberOfCard)! {
                    changedCard.insert(cardIndex)
                }
            }
        }
    }
}

extension NoteEditViewController: SingleEditCollectionViewCellDelegate {
    func singleNoteTitleEdit(for cell: SingleEditCollectionViewCell) {
        if cell.titleButtonText == "ADD TITLE" {
            cell.addTitle()
            cell.titlePresent()
        } else {
            cell.removeTitle()
            cell.bodyPresent()
        }
    }
    
    func filpSingleNoteCard(for cell: SingleEditCollectionViewCell) {
        cell.changeFilpButtonText()
    }
    
    func singleNoteAddPhoto(for textView: UITextView, at index: Int, with range: NSRange, cellStatus: CellStatus) {
        currentTextView = textView
        passInRange = range
        currentCardIndex = index
        addPhotoCellStatus = cellStatus
        let controller = ImagePickerViewController.init(nibName: "ImagePickerViewController", bundle: nil)
        controller.lastController = self
        present(controller, animated: true, completion: {
            let indexPath = IndexPath(item: self.currentCardIndex!, section: 0)
            self.passedInCardIndex = indexPath
        })
    }

}

extension NoteEditViewController: QAEditCollectionViewCellDelegate {
    func filpQANoteCard(for cell: QAEditCollectionViewCell) {
        cell.changeFilpButtonText()
    }
    
    func qaNoteAddPhoto(for textView: UITextView, at index: Int, with range: NSRange, cellStatus: CellStatus) {
        currentTextView = textView
        passInRange = range
        currentCardIndex = index
        addPhotoCellStatus = cellStatus
        let controller = ImagePickerViewController.init(nibName: "ImagePickerViewController", bundle: nil)
        controller.lastController = self
        present(controller, animated: true, completion: {
            let indexPath = IndexPath(item: self.currentCardIndex!, section: 0)
            self.passedInCardIndex = indexPath
        })
    }

}

extension NoteEditViewController: TOCropViewControllerDelegate {
    func cropViewController(_ cropViewController: TOCropViewController, didCropToImage image: UIImage, rect cropRect: CGRect, angle: Int)
    {
        let width = (currentTextView?.bounds.width)! - 10
        let insertImage = UIImage.scaleImageToFitTextView(image, fit: width)
        if currentTextView?.tag == OutletTag.titleTextView.rawValue {
            notes[currentCardIndex!].title = updateTextView(notes[currentCardIndex!].title , image: insertImage!)
        } else {
            notes[currentCardIndex!].body = updateTextView(notes[currentCardIndex!].body, image: insertImage!)
        }
        cropViewController.dismiss(animated: true) {
            let indexPath = IndexPath(item: self.currentCardIndex!, section: 0)
            self.editCollectionView.reloadItems(at: [indexPath])
        }
    }
    
    private func updateTextView(_ text: NSAttributedString, image: UIImage) -> NSAttributedString {
        let imgTextAtta = NSTextAttachment()
        imgTextAtta.image = image
        if let rg = passInRange {
            currentTextView?.textStorage.insert(NSAttributedString.init(attachment: imgTextAtta), at: rg.location)
        }
        return (currentTextView?.attributedText)!
    }
}

