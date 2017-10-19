//
//  NoteViewController.swift
//  MemoryMaster
//
//  Created by apple on 2/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit
import CoreData
import MMCardView

class NoteViewController: BaseTopViewController {
    
    // public api
    var passedInNoteInfo: MyBasicNoteInfo?
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer

    @IBOutlet weak var collectionView: MMCollectionView!
    
    var notes = [CardContent]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        updateUI()
    }
    
    func updateUI() {
        if let info = passedInNoteInfo {
            notes.removeAll()
            for i in 0..<info.numberOfCard {
                let cardContent = CardContent.getCardContent(with: info.name, at: i, in: info.type)
                notes.append(cardContent)
            }
        }
        collectionView.reloadData()
    }
    
    override func setupUI() {
        super.setupUI()
        super.titleLabel.text = passedInNoteInfo?.name ?? "Note name"

        // remove collection view top blank
        self.automaticallyAdjustsScrollViewInsets = false
        
        collectionView.backgroundColor = CustomColor.weakGray
        if let layout = collectionView.collectionViewLayout as? CustomCardLayout {
            layout.titleHeight = 50.0
            layout.bottomShowCount = 3
            layout.cardHeight = 450
            layout.showStyle = .cover
        }
        
        let singleNib = UINib(nibName: "SingleCollectionViewCell", bundle: Bundle.main)
        collectionView.register(singleNib, forCellWithReuseIdentifier: "SingleCollectionViewCell")
        let qaNib = UINib(nibName: "QACollectionViewCell", bundle: Bundle.main)
        collectionView.register(qaNib, forCellWithReuseIdentifier: "QACollectionViewCell")
    }
    
}

extension NoteViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if passedInNoteInfo?.type == NoteType.single.rawValue {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SingleCollectionViewCell", for: indexPath) as! SingleCollectionViewCell
            cell.delegate = self
            cell.cardIndexPath = indexPath
            cell.updateCell(title: notes[indexPath.row].title.string, body: notes[indexPath.row].body, index: indexPath.row + 1)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QACollectionViewCell", for: indexPath) as! QACollectionViewCell
            cell.delegate = self
            cell.cardIndexPath = indexPath
            cell.updateCell(question: notes[indexPath.row].title.string, answer: notes[indexPath.row].body, index: indexPath.row + 1)
            return cell
        }
    }
}

extension NoteViewController: SingleCollectionViewCellDelegate {
    func toSingleNoteEdit(with indexPath: IndexPath) {
        let controller = NoteEditViewController.init(nibName: "NoteEditViewController", bundle: nil)

        controller.passedInCardIndex = indexPath
        if let note = passedInNoteInfo {
            controller.passedInNoteInfo = note
        }
        controller.container = self.container
        controller.isFirstTimeEdit = false
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
    
    func toSingleNoteRead(with indexPath: IndexPath) {
        let controller = ReadNoteViewController.init(nibName: "ReadNoteViewController", bundle: nil)
        
        if let note = passedInNoteInfo {
            controller.passedInNoteInfo = note
            controller.passedInNotes = notes
        }
        controller.startCardIndexPath = indexPath
        
        present(controller, animated: true, completion: nil)
    }
}

extension NoteViewController: QACollectionViewCellDelegate {
    func toQANoteEdit(with indexPath: IndexPath) {
        let controller = NoteEditViewController.init(nibName: "NoteEditViewController", bundle: nil)
        
        controller.passedInCardIndex = indexPath
        if let note = passedInNoteInfo {
            controller.passedInNoteInfo = note
        }
        controller.container = self.container
        controller.isFirstTimeEdit = false
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
    
    func toQANoteRead(with indexPath: IndexPath) {
        let controller = ReadNoteViewController.init(nibName: "ReadNoteViewController", bundle: nil)
        
        if let note = passedInNoteInfo {
            controller.passedInNoteInfo = note
            controller.passedInNotes = notes
        }
        controller.startCardIndexPath = indexPath
        
        present(controller, animated: true, completion: nil)
    }
    
    func toQANoteTest(with indexPath: IndexPath) {
        let controller = TestNoteViewController.init(nibName: "TestNoteViewController", bundle: nil)
        
        if let note = passedInNoteInfo {
            controller.passedInNoteInfo = note
            controller.passedInNotes = notes
        }
        controller.startCardIndexPath = indexPath

        present(controller, animated: true, completion: nil)
    }
}

extension NoteViewController: NoteEditViewControllerDelegate {
    func passNoteInforBack(noteInfo: MyBasicNoteInfo) {
        passedInNoteInfo = noteInfo
    }
}
