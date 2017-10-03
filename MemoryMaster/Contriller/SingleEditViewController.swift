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
        layout.itemSize = CGSize(width: collectionView.bounds.width - CustomDistance.viewToScreenEdgeDistance * 2,
                                 height: collectionView.bounds.height - CustomDistance.viewToScreenEdgeDistance * 2)
        layout.headerReferenceSize = CGSize(width: CustomDistance.viewToScreenEdgeDistance, height: collectionView.bounds.height)
        layout.footerReferenceSize = CGSize(width: CustomDistance.viewToScreenEdgeDistance, height: collectionView.bounds.height)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = CustomDistance.viewToScreenEdgeDistance * 2
        layout.minimumLineSpacing = CustomDistance.viewToScreenEdgeDistance * 2
        
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
        cell.updataCell(with: (localNote?.cards[indexPath.row])!, name: (localNote?.name)!, at: indexPath.row, total: (localNote?.numberOfCard)!)
        return cell
    }
}

extension SingleEditViewController: SingleEditCollectionViewCellDelegate {
    func addCard(currentCell: SingleEditCollectionViewCell) {
        
    }
    
    func removeCard(for cell: SingleEditCollectionViewCell) {
        
    }
    
    func addTitle(for cell: SingleEditCollectionViewCell) {
        if cell.titleButtonText == "ADD TITLE" {
            cell.addTitle()
        } else {
            cell.removeTitle()
        }
    }
    
    func changeTextContent(index: Int, titleText: String, bodyText: String) {
        
    }
}
