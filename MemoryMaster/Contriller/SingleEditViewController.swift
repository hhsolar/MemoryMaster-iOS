//
//  SingleEditViewController.swift
//  MemoryMaster
//
//  Created by apple on 1/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit
import CoreData
import SVProgressHUD

class SingleEditViewController: UIViewController
{
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
    @IBOutlet weak var collectionView: UICollectionView!
    
    var localNote: MySingleNote?
    var coredataNote: SingleNote?
    
    @IBAction func saveAction(_ sender: UIButton)
    {
        saveNote()
        showSavedPrompt()
        printDatabaseStatistics()
    }
    
    private func saveNote() {
        passedInNoteInfo?.numberOfCard = (localNote?.numberOfCard)!
        let context = container?.viewContext
        _ = try? BasicNoteInfo.findOrCreate(matching: self.passedInNoteInfo!, in: context!)
        coredataNote?.numberOfCard = Int32((localNote?.numberOfCard)!)
        coredataNote?.titles.removeAll()
        coredataNote?.bodies.removeAll()
        for card in (localNote?.cards)! {
            coredataNote?.titles.append(card.title)
            coredataNote?.bodies.append(card.body)
        }
        try? context?.save()
    }
    
    private func printDatabaseStatistics() {
        if let context = container?.viewContext {
            let request: NSFetchRequest<BasicNoteInfo> = BasicNoteInfo.fetchRequest()
            if let count = (try? context.fetch(request))?.count {
                print("\(count) note")
            }
        }
    }
    
    private func showSavedPrompt() {
        SVProgressHUD.setMaximumDismissTimeInterval(1)
        SVProgressHUD.setFadeInAnimationDuration(0.2)
        SVProgressHUD.setFadeOutAnimationDuration(0.4)
        SVProgressHUD.showSuccess(withStatus: "Saved!")
    }

    private func dismissView() {
        guard passedInCardIndex == nil else {
            dismiss(animated: true, completion: nil)
            return
        }
        let controller = self.presentingViewController?.presentingViewController
        controller?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func exitAction(_ sender: UIButton)
    {
        if (localNote?.equalTo(coredataNote!))! {
            if let context = container?.viewContext {
                _ = try? BasicNoteInfo.findOrCreate(matching: passedInNoteInfo!, in: context)
                try? context.save()
            }
            dismissView()
        } else {
            let alert = UIAlertController(title: "Reminder!", message: "Do you want to save your change?", preferredStyle: .alert)
            let yes = UIAlertAction(title: "YES", style: .default, handler: { [weak self] action in
                self?.saveNote()
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
    
    func updateUI() {
        if let basicInfo = passedInNoteInfo {
            let context = container?.viewContext
            coredataNote = try? SingleNote.findOrCreateNote(matching: basicInfo, in: context!)
            try? context?.save()
            
            if let note = coredataNote {
                localNote = MySingleNote.formCoreDataType(note: note)
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
        
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = UIColor.lightGray
        
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        collectionView.collectionViewLayout = layout
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let cardIndex = passedInCardIndex {
            collectionView.scrollToItem(at: cardIndex, at: .left, animated: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        let nib = UINib(nibName: "SingleEditCollectionViewCell", bundle: Bundle.main)
        collectionView.register(nib, forCellWithReuseIdentifier: "SingleEditCollectionViewCell")
    }
}

extension SingleEditViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return localNote?.numberOfCard ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SingleEditCollectionViewCell", for: indexPath) as! SingleEditCollectionViewCell
        cell.delegate = self
        cell.awakeFromNib()
        cell.setNeedsLayout()
        cell.updataCell(with: (localNote?.cards[indexPath.row])!, at: indexPath.row, total: (localNote?.numberOfCard)!)
        return cell
    }
}

extension SingleEditViewController: SingleEditCollectionViewCellDelegate {
    func addCard(currentCell: SingleEditCollectionViewCell) {
        let singleCard = SingleCard(title: "", body: "")
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
        localNote?.cards.insert(singleCard, at: currentCell.cardIndex!)
        collectionView.reloadData()
        collectionView.scrollToItem(at: IndexPath(item: currentCell.cardIndex!, section: 0), at: .left, animated: true)
        collectionView.reloadItems(at: [IndexPath(item: currentCell.cardIndex! - 1, section: 0)])
    }
    
    func removeCard(for cell: SingleEditCollectionViewCell) {
        if localNote?.numberOfCard == 1 {
            self.showAlert(title: "Error!", message: "A note must has one item at least.")
            return
        }
        let index = cell.cardIndex! - 1
        
        if index == 0 {
            collectionView.scrollToItem(at: IndexPath(item: index + 1, section: 0), at: .left, animated: true)

            localNote?.cards.remove(at: index)
            collectionView.reloadData()
            // have to add function reloadItems, or there will be a cell not update
            collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .left, animated: true)
            return
        }
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
        localNote?.cards.remove(at: index)
        collectionView.reloadData()
        collectionView.scrollToItem(at: IndexPath(item: index - 1, section: 0), at: .left, animated: true)
        collectionView.reloadItems(at: [IndexPath(item: index - 1, section: 0)])
    }
    
    func addTitle(for cell: SingleEditCollectionViewCell) {
        if cell.titleButtonText == "ADD TITLE" {
            cell.addTitle()
        } else {
            cell.removeTitle()
        }
    }
    
    func changeTextContent(index: Int, titleText: String, bodyText: String) {
        localNote?.cards[index].title = titleText
        localNote?.cards[index].body = bodyText
    }
}
