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
        NotificationCenter.default.addObserver(self, selector: #selector(refreshPage), name: NSNotification.Name(rawValue: "RefreshPage"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        notes.removeAll()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "RefreshPage"), object: nil)
    }
    
    @objc func refreshPage() {
        updateUI()
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
                collectionView.reloadData()
                if let index = toPassIndex {
                    var sec = 0
                    if (noteInfo?.numberOfCard)! > 1 {
                        collectionView.layoutIfNeeded()
                        view.layoutIfNeeded()
                        sec = Int(collectionView.contentSize.width - UIScreen.main.bounds.width) / ((noteInfo?.numberOfCard)! - 1)
                    }
                    let offset = CGPoint(x: sec * index, y: 0)
                    collectionView.setContentOffset(offset, animated: false)
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
            // container must be sent after passedInNoteInfo sent, since updateUI() will execute when container set
            controller.container = container
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
        indexLabel.text = String(format: "%d / %d", index + 1, notes.count)
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let toScreenView = UIView(frame: UIScreen.main.bounds)
        toScreenView.backgroundColor = CustomColor.weakGray
        let textView = UITextView(frame: CGRect(x: CustomSize.barHeight, y: CustomSize.barHeight, width: UIScreen.main.bounds.width - CustomSize.barHeight * 2, height: UIScreen.main.bounds.height - CustomSize.barHeight * 2))
        textView.attributedText = NSAttributedString.prepareAttributeStringForRead(noteType: (noteInfo?.type)!, title: notes[indexPath.item].title, body: notes[indexPath.item].body, index: indexPath.item)
        textView.backgroundColor = CustomColor.weakGray
    }
}
