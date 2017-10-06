//
//  QAEditViewController.swift
//  MemoryMaster
//
//  Created by apple on 4/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit
import CoreData
import SVProgressHUD

class QAEditViewController: UIViewController
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
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var localNote: MyQANote?
    var coredataNote: QANote?
    
    @IBAction func exitButton(_ sender: UIButton)
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
    
    private func saveNote() {
        passedInNoteInfo?.numberOfCard = (localNote?.numberOfCard)!
        let context = container?.viewContext
        _ = try? BasicNoteInfo.findOrCreate(matching: self.passedInNoteInfo!, in: context!)
        coredataNote?.numberOfCard = Int32((localNote?.numberOfCard)!)
        coredataNote?.questions.removeAll()
        coredataNote?.answers.removeAll()
        for card in (localNote?.cards)! {
            coredataNote?.questions.append(card.question)
            coredataNote?.answers.append(card.answer)
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
    
    @IBAction func saveButton(_ sender: UIButton) {
        saveNote()
        showSavedPrompt()
        printDatabaseStatistics()
    }
    
    func updateUI() {
        if let basicInfo = passedInNoteInfo {
            let context = container?.viewContext
            coredataNote = try? QANote.findOrCreateNote(matching: basicInfo, in: context!)
            try? context?.save()
            
            if let note = coredataNote {
                localNote = MyQANote.formCoreDataType(note: note)
            }
        }
    }
    
    func setupUI()
    {
        nameLabel.text = passedInNoteInfo?.name ?? "No name"
        nameLabel.textColor = CustomColor.medianBlue
        
        self.view.backgroundColor = UIColor.lightGray
        topView.backgroundColor = CustomColor.lightBlue
        
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
        
        let nib = UINib(nibName: "QAEditCollectionViewCell", bundle: Bundle.main)
        collectionView.register(nib, forCellWithReuseIdentifier: "QAEditCollectionViewCell")
    }
}

extension QAEditViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return localNote?.numberOfCard ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QAEditCollectionViewCell", for: indexPath) as! QAEditCollectionViewCell
        cell.delegate = self
        cell.awakeFromNib()
        cell.setNeedsLayout()
        cell.updateCell(with: (localNote?.cards[indexPath.row])!, at: indexPath.row, total: (localNote?.numberOfCard)!)
        return cell
    }
}

extension QAEditViewController: QAEditCollectionViewCellDelegate {
    func addCard(currentCell: QAEditCollectionViewCell) {
        let qaCard = QACard(question: "", answer: "")
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
        localNote?.cards.insert(qaCard, at: currentCell.cardIndex!)
        collectionView.reloadData()
        collectionView.scrollToItem(at: IndexPath(item: currentCell.cardIndex!, section: 0), at: .left, animated: true)
        collectionView.reloadItems(at: [IndexPath(item: currentCell.cardIndex! - 1, section: 0)])
    }
    
    func removeCard(for cell: QAEditCollectionViewCell) {
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
    
    func changeTextContent(index: Int, question: String, answer: String) {
        localNote?.cards[index].question = question
        localNote?.cards[index].answer = answer

    }
}
