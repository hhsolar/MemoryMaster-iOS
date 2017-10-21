//
//  ReciteViewController.swift
//  MemoryMaster
//
//  Created by apple on 1/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit
import CoreData

private let cellReuseIdentifier1 = "CircularCollectionViewCell"
private let cellReuseIdentifier2 = "cell"

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

    // var for show data and pass
    var noteInfo: MyBasicNoteInfo?
    var notes = [CardContent]()
    
    // var for pass
    var toPassIndex: Int?
    var toPassCardStatus: String?
    var readType: String?
    
    let toScreenView = UIView()
    let toScreenTextView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(removeScreenView))
        swipeRecognizer.direction = .left
        swipeRecognizer.numberOfTouchesRequired = 1
        toScreenView.addGestureRecognizer(swipeRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
        
        // add notification to refreash view when back to the controller
        NotificationCenter.default.addObserver(self, selector: #selector(refreshPage), name: NSNotification.Name(rawValue: "RefreshPage"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        notes.removeAll()
        
        // remove notification
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "RefreshPage"), object: nil)
    }
    
    @objc func refreshPage() {
        updateUI()
    }
    
    private func updateUI() {
        // read last visit note infomation from userDefault
        let userDefault = UserDefaults.standard
        if let lastSet = userDefault.dictionary(forKey: "lastStatus") {
            let id = lastSet[UserDefaultsDictKey.id] as! Int32
            let note = BasicNoteInfo.find(matching: id, in: (container?.viewContext)!)
            if let note = note {
                hideNoNoteLayout()
                noteInfo = MyBasicNoteInfo.convertToMyBasicNoteInfo(basicNoteInfo: note)
                for i in 0..<Int(note.numberOfCard) {
                    let cardContent = CardContent.getCardContent(with: note.name, at: i, in: note.type)
                    notes.append(cardContent)
                }
                toPassIndex = lastSet[UserDefaultsDictKey.cardIndex] as? Int
                readType = lastSet[UserDefaultsDictKey.readType] as? String
                toPassCardStatus = lastSet[UserDefaultsDictKey.cardStatus] as? String
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
        addNoteButton.titleLabel?.font = UIFont(name: CustomFont.HelveticaNeue, size: CustomFont.FontSizeSmall)
        addNoteButton.setTitleColor(UIColor.white, for: .normal)
        addNoteButton.layer.cornerRadius = 14
        addNoteButton.layer.masksToBounds = true
        
        indexLabel.textColor = CustomColor.medianBlue
        indexLabel.font = UIFont(name: CustomFont.HelveticaNeue, size: CustomFont.FontSizeMid)
        
        continueButton.backgroundColor = CustomColor.medianBlue
        continueButton.titleLabel?.font = UIFont(name: CustomFont.HelveticaNeue, size: CustomFont.FontSizeSmall)
        continueButton.setTitleColor(UIColor.white, for: .normal)
        continueButton.layer.cornerRadius = 14
        continueButton.layer.masksToBounds = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        
        let nib = UINib(nibName: cellReuseIdentifier1, bundle: Bundle.main)
        collectionView.register(nib, forCellWithReuseIdentifier: cellReuseIdentifier1)
        collectionView.register(NothingCell.self, forCellWithReuseIdentifier: cellReuseIdentifier2)
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
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if notes.count != 0 {
            let newCell = cell as! CircularCollectionViewCell
            newCell.updateUI(noteType: (noteInfo?.type)!, title: notes[indexPath.row].title, body: notes[indexPath.row].body, index: indexPath.row)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if notes.count == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier2, for: indexPath)
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier1, for: indexPath) as! CircularCollectionViewCell
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        prepareForToScreenView(collectionView: collectionView, indexPath: indexPath)
        let finalFrame = CGRect(x: 0, y: CustomSize.barHeight + CustomSize.statusBarHeight, width: collectionView.bounds.width, height: UIScreen.main.bounds.height - CustomSize.barHeight * 2 - CustomSize.statusBarHeight)
        let finalScreenFrame = CGRect(x: CustomDistance.viewToScreenEdgeDistance, y: CustomDistance.viewToScreenEdgeDistance, width: finalFrame.size.width - CustomDistance.viewToScreenEdgeDistance * 2, height: finalFrame.size.height - CustomDistance.viewToScreenEdgeDistance * 2)
        UIView.animateKeyframes(withDuration: 0.5, delay: 0.2, options: [], animations: {
            self.toScreenView.frame = finalFrame
            self.toScreenTextView.frame = finalScreenFrame
            self.toScreenTextView.isEditable = false
            self.toScreenView.layer.cornerRadius = 0
            self.toScreenView.layer.masksToBounds = false
            self.toScreenView.layer.borderWidth = 0
        })
        
        collectionView.deselectItem(at: indexPath, animated: false)
    }
    
    private func prepareForToScreenView(collectionView: UICollectionView, indexPath: IndexPath) {
        toScreenView.layer.cornerRadius = 10
        toScreenView.layer.masksToBounds = true
        toScreenView.layer.borderWidth = 1
        toScreenView.backgroundColor = CustomColor.weakGray
        let attributes: UICollectionViewLayoutAttributes! = collectionView.layoutAttributesForItem(at: indexPath)
        let frameInSuperView: CGRect! = collectionView.convert(attributes.frame, to: collectionView.superview)
        toScreenView.frame = frameInSuperView
        view.addSubview(toScreenView)

        toScreenTextView.frame = CGRect(x: CustomSize.barHeight, y: CustomSize.barHeight, width: toScreenView.bounds.width - CustomSize.barHeight * 2, height: toScreenView.bounds.height - CustomSize.barHeight * 2)
        toScreenTextView.attributedText = NSAttributedString.prepareAttributeStringForRead(noteType: (noteInfo?.type)!, title: notes[indexPath.item].title, body: notes[indexPath.item].body, index: indexPath.item)
        toScreenTextView.backgroundColor = CustomColor.weakGray
        toScreenView.addSubview(toScreenTextView)
    }
    
    @objc private func removeScreenView(byReactionTo swipeRecognizer: UISwipeGestureRecognizer) {
        if swipeRecognizer.state == .ended {
            UIView.animateKeyframes(withDuration: 0.3, delay: 0.01, options: [], animations: {
                self.toScreenView.frame.origin.x = -UIScreen.main.bounds.width
            }) { finished in
                self.toScreenView.removeFromSuperview()
            }
        }
    }
}
