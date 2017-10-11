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

class NoteEditViewController: UIViewController {

    // public api
    var passedInNoteInfo: MyBasicNoteInfo?
    var passedInCardIndex: IndexPath?
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var editCollectionView: UICollectionView!
    
    var notes = [CardContent]()
    var changedCard = Set<Int>()
    
    var currentTextView: UITextView?
    var passInRange: NSRange?
    var currentCardIndex: Int?
    
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
    
    func updateUI() {
        if let info = passedInNoteInfo {
            for i in 0..<info.numberOfCard {
                let cardContent = CardContent.getCardContent(with: info.name, at: i, in: info.type)
                notes.append(cardContent)
            }
        }
    }
    
    func setupUI()
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
        
        let nib = UINib(nibName: "SingleEditCollectionViewCell", bundle: Bundle.main)
        editCollectionView.register(nib, forCellWithReuseIdentifier: "SingleEditCollectionViewCell")
    }

    @IBAction func saveNote(_ sender: UIButton) {
        save()
        showSavedPrompt()
    }
    
    private func save() {
        passedInNoteInfo?.numberOfCard = notes.count
        let context = container?.viewContext
        _ = try? BasicNoteInfo.findOrCreate(matching: self.passedInNoteInfo!, in: context!)
        try? context?.save()
        
        for i in changedCard {
            notes[i].title.saveTextToFile(with: (passedInNoteInfo?.name)!, at: i, in: (passedInNoteInfo?.type)!, contentType: "title")
            notes[i].body.saveTextToFile(with: (passedInNoteInfo?.name)!, at: i, in: (passedInNoteInfo?.type)!, contentType: "body")
        }
        changedCard.removeAll()
    }
    
    private func showSavedPrompt() {
        SVProgressHUD.setMaximumDismissTimeInterval(1)
        SVProgressHUD.setFadeInAnimationDuration(0.2)
        SVProgressHUD.setFadeOutAnimationDuration(0.4)
        SVProgressHUD.showSuccess(withStatus: "Saved!")
    }
    
    @IBAction func exit(_ sender: UIButton) {
        if changedCard.isEmpty {
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
        guard passedInCardIndex == nil else {
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SingleEditCollectionViewCell", for: indexPath) as! SingleEditCollectionViewCell
        cell.delegate = self
        cell.awakeFromNib()
        cell.setNeedsLayout()
        cell.updataCell(with: notes[indexPath.row], at: indexPath.row, total: notes.count)
        return cell
    }
}

extension NoteEditViewController: SingleEditCollectionViewCellDelegate {
    func addCard(currentCell: SingleEditCollectionViewCell) {
        let cardContent = CardContent(title: NSAttributedString.init(), body: NSAttributedString.init())
        editCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
        notes.insert(cardContent, at: currentCell.cardIndex!)
        editCollectionView.reloadData()
        editCollectionView.scrollToItem(at: IndexPath(item: currentCell.cardIndex!, section: 0), at: .left, animated: true)
        editCollectionView.reloadItems(at: [IndexPath(item: currentCell.cardIndex! - 1, section: 0)])
    }
    
    func removeCard(for cell: SingleEditCollectionViewCell) {
        if notes.count == 1 {
            self.showAlert(title: "Error!", message: "A note must has one item at least.")
            return
        }
        let index = cell.cardIndex! - 1
        
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
    }
    
    func addTitle(for cell: SingleEditCollectionViewCell) {
        if cell.titleButtonText == "ADD TITLE" {
            cell.addTitle()
        } else {
            cell.removeTitle()
        }
    }
    
    func addPhoto(for cell: SingleEditCollectionViewCell, range: NSRange?) {
        if cell.currentTextView != nil {
            if let range = range, range.location != NSNotFound {
                currentTextView = cell.currentTextView!
                passInRange = range
                currentCardIndex = cell.cardIndex! - 1
                
                let controller = ImagePickerViewController.init(nibName: "ImagePickerViewController", bundle: nil)
                controller.lastController = self
                present(controller, animated: true, completion: {
                    let indexPath = IndexPath(item: self.currentCardIndex!, section: 0)
                    self.passedInCardIndex = indexPath
                })
            }
        }
        showAlert(title: "Error!", message: "Choose a place to get photo.")
    }
    
    func changeTextContent(index: Int, titleText: NSAttributedString, bodyText: NSAttributedString) {
        notes[index].title = titleText
        notes[index].body = bodyText
        changedCard.insert(index)
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
        if var rg = passInRange {
            if rg.location == NSNotFound {
                rg.location = (currentTextView?.text.count)!
            }
            currentTextView?.textStorage.insert(NSAttributedString.init(attachment: imgTextAtta), at: rg.location)
        }
        return (currentTextView?.attributedText)!
    }
}

