//
//  ReciteViewController.swift
//  MemoryMaster
//
//  Created by apple on 1/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit
import CoreData

class NothingCell: UICollectionViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class ReciteViewController: UIViewController {

    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var toLeftButton: UIButton!
    @IBOutlet weak var toRightButton: UIButton!
    
    @IBOutlet weak var noNoteImageView: UIImageView!
    @IBOutlet weak var noNoteLabel: UILabel!
    @IBOutlet weak var addNoteButton: UIButton!
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer

    var noteInfo: MyBasicNoteInfo?
    var notes = [CardContent]()
    var toPassIndex: Int?
    var toPassCardStatus: String?
    var readType: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        notes.removeAll()
    }
    
    private func updateUI() {
        let userDefault = UserDefaults.standard
        if let lastSet = userDefault.dictionary(forKey: "lastStatus") {
            let id = lastSet["id"] as! Int32
            let note = BasicNoteInfo.find(matching: id, in: (container?.viewContext)!)
            if let note = note {
                hideNoNoteLayout()
                noteInfo = MyBasicNoteInfo.convertToMyBasicNoteInfo(basicNoteInfo: note)
                for i in 0..<Int(note.numberOfCard) {
                    let cardContent = CardContent.getCardContent(with: note.name, at: i, in: note.type)
                    notes.append(cardContent)
                }
                toPassIndex = lastSet["index"] as? Int
                readType = lastSet["readType"] as? String
                toPassCardStatus = lastSet["cardStatus"] as? String
                title = (noteInfo?.name)!
                collectionView.reloadData()
                if let index = toPassIndex {
                    collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .left, animated: false)
                    indexLabel.text = String(format: "%d / %d", index + 1, notes.count)
                }
                return
            }
        }
        presentNoNoteLayout()
    }

    private func setupUI()
    {
        addNoteButton.backgroundColor = CustomColor.medianBlue
        addNoteButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 16)
        addNoteButton.setTitleColor(UIColor.white, for: .normal)
        addNoteButton.layer.cornerRadius = 14
        addNoteButton.layer.masksToBounds = true
        
        indexLabel.textColor = CustomColor.medianBlue
        indexLabel.font = UIFont(name: CustomFont.navigationSideFontName, size: CustomFont.navigationSideFontSize)
        
        continueButton.backgroundColor = CustomColor.medianBlue
        continueButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 16)
        continueButton.setTitleColor(UIColor.white, for: .normal)
        continueButton.layer.cornerRadius = 14
        continueButton.layer.masksToBounds = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        
        let nib = UINib(nibName: "CircularCollectionViewCell", bundle: Bundle.main)
        collectionView.register(nib, forCellWithReuseIdentifier: "CircularCollectionViewCell")
        collectionView.register(NothingCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    private func presentNoNoteLayout() {
        noNoteImageView.isHidden = false
        noNoteLabel.isHidden = false
        addNoteButton.isHidden = false
        addNoteButton.isEnabled = true
        
        collectionView.isHidden = true
        continueButton.isHidden = true
        toLeftButton.isHidden = true
        toRightButton.isHidden = true
        indexLabel.isHidden = true
    }
    
    private func hideNoNoteLayout() {
        noNoteImageView.isHidden = true
        noNoteLabel.isHidden = true
        addNoteButton.isHidden = true
        addNoteButton.isEnabled = false
        
        collectionView.isHidden = false
        continueButton.isHidden = false
        toLeftButton.isHidden = false
        toRightButton.isHidden = false
        indexLabel.isHidden = false
    }
    
    @IBAction func continueAction(_ sender: UIButton) {
        switch readType! {
        case ReadType.edit.rawValue:
            let controller = NoteEditViewController.init(nibName: "NoteEditViewController", bundle: nil)
            controller.passedInCardIndex = IndexPath(item: toPassIndex!, section: 0)
            controller.passedInCardStatus = toPassCardStatus!
            controller.passedInNoteInfo = noteInfo
            present(controller, animated: true, completion: nil)
        case ReadType.read.rawValue:
            let controller = ReadNoteViewController.init(nibName: "ReadNoteViewController", bundle: nil)
            controller.passedInNoteInfo = noteInfo
            controller.passedInNotes = notes
            controller.startCardIndexPath = IndexPath(item: toPassIndex!, section: 0)
            present(controller, animated: true, completion: nil)
        case ReadType.test.rawValue:
            let controller = TestNoteViewController.init(nibName: "TestNoteViewController", bundle: nil)
            controller.passedInNoteInfo = noteInfo
            controller.passedInNotes = notes
            controller.startCardIndexPath = IndexPath(item: toPassIndex!, section: 0)
            controller.passedInCardStatus = toPassCardStatus!
            present(controller, animated: true, completion: nil)
        default:
            break
        }
    }
    
    @IBAction func toFirstCard(_ sender: UIButton) {
        collectionView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    @IBAction func toLastCard(_ sender: UIButton) {
        let bottom = CGPoint(x: collectionView.contentSize.width - collectionView.bounds.width, y: 0)
        collectionView.setContentOffset(bottom, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let layout = collectionView.collectionViewLayout as! CircularCollectionViewLayout
        let index = Int(abs(layout.angle / layout.anglePerItem))
        print(index)
        indexLabel.text = String(format: "%d / %d", index + 1, notes.count)
        print(String(format: "%d / %d", index + 1, notes.count))
    }
}

extension ReciteViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if notes.count == 0 {
            return 1
        }
        return notes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if notes.count == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CircularCollectionViewCell", for: indexPath) as! CircularCollectionViewCell
        cell.updateUI(noteType: (noteInfo?.type)!, title: notes[indexPath.row].title, body: notes[indexPath.row].body, index: indexPath.row)
        return cell
    }
}
