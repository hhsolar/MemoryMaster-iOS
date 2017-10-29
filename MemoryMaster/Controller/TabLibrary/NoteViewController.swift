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

private let cellReuseIdentifier1 = "SingleCollectionViewCell"
private let cellReuseIdentifier2 = "QACollectionViewCell"

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
        
        let singleNib = UINib(nibName: cellReuseIdentifier1, bundle: Bundle.main)
        collectionView.register(singleNib, forCellWithReuseIdentifier: cellReuseIdentifier1)
        let qaNib = UINib(nibName: cellReuseIdentifier2, bundle: Bundle.main)
        collectionView.register(qaNib, forCellWithReuseIdentifier: cellReuseIdentifier2)
    }
    
}

extension NoteViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if passedInNoteInfo?.type == NoteType.single.rawValue {
            let newCell = cell as! SingleCollectionViewCell
            newCell.delegate = self
            newCell.cardIndexPath = indexPath
            newCell.updateCell(title: notes[indexPath.row].title, body: notes[indexPath.row].body, index: indexPath.row + 1)
        } else {
            let newCell = cell as! QACollectionViewCell
            newCell.delegate = self
            newCell.cardIndexPath = indexPath
            newCell.updateCell(question: notes[indexPath.row].title, answer: notes[indexPath.row].body, index: indexPath.row + 1)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if passedInNoteInfo?.type == NoteType.single.rawValue {
            return collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier1, for: indexPath) as! SingleCollectionViewCell
        } else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier2, for: indexPath) as! QACollectionViewCell
        }
    }
    
    private func presentNoteEditController(with indexPath: IndexPath) {
        let controller = EditNoteViewController.init(nibName: "EditNoteViewController", bundle: nil)
        
        controller.passedInCardIndex = indexPath
        if let note = passedInNoteInfo {
            controller.passedInNoteInfo = note
        }
        controller.container = self.container
        controller.isFirstTimeEdit = false
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }

    private func presentForNoteReadController(with indexPath: IndexPath) {
        let controller = ReadNoteViewController.init(nibName: "ReadNoteViewController", bundle: nil)
        
        if let note = passedInNoteInfo {
            controller.passedInNoteInfo = note
            controller.passedInNotes = notes
        }
        controller.startCardIndexPath = indexPath
        
        present(controller, animated: true, completion: nil)

    }
}

extension NoteViewController: SingleCollectionViewCellDelegate {
    func toSingleNoteEdit(with indexPath: IndexPath) {
        playSound.playClickSound(SystemSound.buttonClick)
        presentNoteEditController(with: indexPath)
    }
    
    func toSingleNoteRead(with indexPath: IndexPath) {
        playSound.playClickSound(SystemSound.buttonClick)
        presentForNoteReadController(with: indexPath)
    }
}

extension NoteViewController: QACollectionViewCellDelegate {
    func toQANoteEdit(with indexPath: IndexPath) {
        playSound.playClickSound(SystemSound.buttonClick)
        presentNoteEditController(with: indexPath)
    }
    
    func toQANoteRead(with indexPath: IndexPath) {
        playSound.playClickSound(SystemSound.buttonClick)
        presentForNoteReadController(with: indexPath)
    }
    
    func toQANoteTest(with indexPath: IndexPath) {
        playSound.playClickSound(SystemSound.buttonClick)
        let controller = TestNoteViewController.init(nibName: "TestNoteViewController", bundle: nil)
        
        if let note = passedInNoteInfo {
            controller.passedInNoteInfo = note
            controller.passedInNotes = notes
        }
        controller.startCardIndexPath = indexPath

        present(controller, animated: true, completion: nil)
    }
}

extension NoteViewController: EditNoteViewControllerDelegate {
    func passNoteInforBack(noteInfo: MyBasicNoteInfo) {
        passedInNoteInfo = noteInfo
    }
}
