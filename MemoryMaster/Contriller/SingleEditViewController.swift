//
//  SingleEditViewController.swift
//  MemoryMaster
//
//  Created by apple on 1/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit
import CoreData

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
    
    var localNote: MySingleNote?
    var coredataNote: SingleNote?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBAction func saveAction(_ sender: UIButton)
    {
    }
    
    @IBAction func exitAction(_ sender: UIButton)
    {
    }
    
    func updateUI() {
        if let basicInfo = passedInNoteInfo {
            let context = container?.viewContext
            coredataNote = try? SingleNote.findOrCreateNote(matching: basicInfo, in: context!)
            try? context?.save()
            
            if let cdNote = coredataNote {
                localNote = MySingleNote.formCoreDataType(note: cdNote)
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
        layout.itemSize = CGSize(width: collectionView.bounds.width,
                                 height: collectionView.bounds.height)
//        layout.headerReferenceSize = CGSize(width: CustomDistance.viewToScreenEdgeDistance, height: collectionView.bounds.height)
//        layout.footerReferenceSize = CGSize(width: CustomDistance.viewToScreenEdgeDistance, height: collectionView.bounds.height)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        collectionView.collectionViewLayout = layout
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
        cell.updataCell(with: (localNote?.cards[indexPath.row])!, name: (localNote?.name)!, at: indexPath.row, total: (localNote?.numberOfCard)!)
        return cell
    }
}

extension SingleEditViewController: SingleEditCollectionViewCellDelegate {
    func addCard(currentCell: SingleEditCollectionViewCell) {
        let singleCard = SingleCard(title: "", body: "")
        localNote?.cards.insert(singleCard, at: currentCell.cardIndex!)
        let indexPath = IndexPath(item: currentCell.cardIndex!, section: 0)
        collectionView.insertItems(at: [indexPath])
        collectionView.reloadData()
        // have to add function reloadItems, or there will be a cell not update
        collectionView.reloadItems(at: [IndexPath(item: currentCell.cardIndex! - 1, section: 0)])
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
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
