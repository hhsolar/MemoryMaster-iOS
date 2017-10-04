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

class NoteViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var collectionView: MMCollectionView! {
        didSet {
            collectionView.backgroundColor = CustomColor.weakGray
        }
    }
    
    // public api
    var passedInNodeInfo: MyBasicNoteInfo?
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    var singleNote: SingleNote?
    var qaNote: QANote?
    
    @IBAction func backAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func updateUI(with noteInfo: MyBasicNoteInfo) {
        if let context = container?.viewContext {
            if noteInfo.type == NoteType.single.rawValue {
                singleNote = try? SingleNote.findOrCreateNote(matching: noteInfo, in: context)
            }
        }
        collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        if let note = passedInNodeInfo {
            updateUI(with: note)
        }
    }
    
    private func setupUI() {
        nameLabel.text = passedInNodeInfo?.name ?? "Note name"
        
        if let layout = collectionView.collectionViewLayout as? CustomCardLayout {
            layout.titleHeight = 50.0
            layout.bottomShowCount = 3
            layout.cardHeight = 450
            layout.showStyle = .cover
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // remove collection view top blank
        self.automaticallyAdjustsScrollViewInsets = false
        
        setupUI()
        
        let singleNib = UINib(nibName: "SingleCollectionViewCell", bundle: Bundle.main)
        collectionView.register(singleNib, forCellWithReuseIdentifier: "SingleCollectionViewCell")
        let qaNib = UINib(nibName: "QACollectionViewCell", bundle: Bundle.main)
        collectionView.register(qaNib, forCellWithReuseIdentifier: "QACollectionViewCell")
    }
}

extension NoteViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let singleNote = singleNote {
            return Int(singleNote.numberOfCard)
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SingleCollectionViewCell", for: indexPath) as! SingleCollectionViewCell
        cell.delegate = self
        cell.cardIndexPath = indexPath
        cell.updateCell(title: (singleNote?.titles[indexPath.row])!, body: (singleNote?.bodies[indexPath.row])!, index: indexPath.row + 1)
        return cell
    }
}

extension NoteViewController: SingleCollectionViewCellDelegate {
    func editAction(with indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SingleEditViewController") as! SingleEditViewController
        
        if let note = passedInNodeInfo {
            controller.passedInNoteInfo = MyBasicNoteInfo(id: Int(note.id), time: note.time, type: note.type, name: note.name, numberOfCard: Int(note.numberOfCard))
        }
        controller.passedInCardIndex = indexPath
        controller.container = self.container
        
        present(controller, animated: true, completion: nil)
    }
    
    func readAction(with indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ReadViewController") as! ReadViewController
        
        if let note = singleNote {
            controller.passedInSingleNote = note
        } else if let note = qaNote {
            controller.passedInQANote = note
        }
        controller.startCardIndexPath = indexPath
        
        present(controller, animated: true, completion: nil)
    }
}
