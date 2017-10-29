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
    var contentToShow = [NSAttributedString]()
    
    // var for pass
    var toPassIndex: Int?
    var toPassCardStatus: String?
    var readType: String?
    
    var toScreenView: UIView!
    var toScreenTextView: UITextView!
    
    fileprivate let playSound = SystemAudioPlayer()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
        
        self.navigationItem.title = noteInfo?.name ?? "Recite"

        // add notification to refreash view when back to the controller
        NotificationCenter.default.addObserver(self, selector: #selector(refreshPage), name: NSNotification.Name(rawValue: "RefreshPage"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        notes.removeAll()
        contentToShow.removeAll()
        // remove notification
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "RefreshPage"), object: nil)
    }
    
    @objc func refreshPage() {
        updateUI()
    }
    
    private func updateUI() {
        // read last visit note infomation from userDefault
        let userDefault = UserDefaults.standard
        if let lastSet = userDefault.dictionary(forKey: UserDefaultsKeys.lastReadStatus) {
            let id = lastSet[UserDefaultsDictKey.id] as! Int32
            let note = BasicNoteInfo.find(matching: id, in: (container?.viewContext)!)
            if let note = note {
                hideNoNoteLayout()
                noteInfo = MyBasicNoteInfo.convertToMyBasicNoteInfo(basicNoteInfo: note)
                for i in 0..<Int(note.numberOfCard) {
                    let cardContent = CardContent.getCardContent(with: note.name, at: i, in: note.type)
                    notes.append(cardContent)
                }
                contentToShow.append(contentsOf: perpareToShow(notes: notes, noteType: note.type))
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
            } else if let noteNumber = noteNumber, noteNumber > 0 {
                noNoteLabel.text = "Oops, the note you read last time seems to be removed."
                noteInfo = nil
                presentNoNoteLayout()
                addNoteButton.isHidden = true
                addNoteButton.isEnabled = false
                return
            }
        }
        presentNoNoteLayout()
    }

    private func perpareToShow(notes: [CardContent], noteType: String) -> [NSAttributedString] {
        var contents = [NSAttributedString]()
        for i in 0..<notes.count {
            var length = notes[i].title.length > 200 ? 200 : notes[i].title.length
            let containerWidth = (collectionView.collectionViewLayout as! CircularCollectionViewLayout).itemSize.width - 17 * 2
            let titleRange = NSRange.init(location: 0, length: length)
            var subTitle = notes[i].title.attributedSubstring(from: titleRange)
            if subTitle.containsAttachments(in: titleRange) {
                subTitle = subTitle.changeAttachmentImageToFitContainer(containerWidth: containerWidth, in: titleRange)
            }
            var subBody = NSAttributedString()
            if length < 150 {
                length = notes[i].body.length > (200 - length) ? (200 - length) : notes[i].body.length
                let bodyRange = NSRange.init(location: 0, length: length)
                subBody = notes[i].body.attributedSubstring(from: bodyRange)
                if subBody.containsAttachments(in: bodyRange) {
                    subBody = subBody.changeAttachmentImageToFitContainer(containerWidth: containerWidth, in: bodyRange)
                }
            }
            contents.append(NSAttributedString.prepareAttributeStringForRead(noteType: noteType, title: subTitle, body: subBody, index: i))
        }
        return contents
    }
    
    var noteNumber: Int? {
        if let context = container?.viewContext {
            return try? context.count(for: BasicNoteInfo.fetchRequest())
        }
        return nil
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
        playSound.playClickSound(SystemSound.buttonClick)
        switch readType! {
        case ReadType.edit.rawValue:
            let controller = EditNoteViewController.init(nibName: "EditNoteViewController", bundle: nil)
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
        indexLabel.text = String(format: "%d / %d", index + 1, contentToShow.count)
    }
}

extension ReciteViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if contentToShow.count == 0 {
            return 1
        }
        return contentToShow.count
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if contentToShow.count != 0 {
            let newCell = cell as! CircularCollectionViewCell
            newCell.updateUI(content: contentToShow[indexPath.item])
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
        let finalFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - CustomSize.barHeight * 2 - CustomSize.statusBarHeight)
        UIView.animateKeyframes(withDuration: 0.5, delay: 0.2, options: [], animations: {
            self.toScreenView.frame = finalFrame
            self.toScreenTextView.frame = finalFrame
            self.toScreenTextView.isEditable = false
            self.toScreenView.layer.cornerRadius = 0
            self.toScreenView.layer.masksToBounds = false
            self.toScreenView.layer.borderWidth = 0
        })
        
        collectionView.deselectItem(at: indexPath, animated: false)
    }
    
    private func prepareForToScreenView(collectionView: UICollectionView, indexPath: IndexPath) {
        // get cell frame
        let attributes: UICollectionViewLayoutAttributes! = collectionView.layoutAttributesForItem(at: indexPath)
        let frameInSuperView: CGRect! = collectionView.convert(attributes.frame, to: collectionView.superview)
        toScreenView = UIView(frame: frameInSuperView)
        view.addSubview(toScreenView)
        
        toScreenView.layer.cornerRadius = 10
        toScreenView.layer.masksToBounds = true
        toScreenView.layer.borderWidth = 1
        toScreenView.backgroundColor = CustomColor.weakGray
        
        toScreenTextView = UITextView(frame: CGRect(origin: CGPoint.zero, size: toScreenView.bounds.size))
        toScreenTextView.textContainerInset = UIEdgeInsets(top: 17, left: CustomDistance.wideEdge, bottom: 17, right: CustomDistance.wideEdge)
        toScreenTextView.attributedText = NSAttributedString.prepareAttributeStringForRead(noteType: (noteInfo?.type)!, title: notes[indexPath.item].title, body: notes[indexPath.item].body, index: indexPath.item)
        toScreenTextView.backgroundColor = CustomColor.weakGray
        toScreenTextView.contentOffset.y = 0
        toScreenView.addSubview(toScreenTextView)
        
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(removeScreenView))
        swipeRecognizer.direction = .left
        swipeRecognizer.numberOfTouchesRequired = 1
        toScreenView.addGestureRecognizer(swipeRecognizer)
    }
    
    @objc private func removeScreenView(byReactionTo swipeRecognizer: UISwipeGestureRecognizer) {
        if swipeRecognizer.state == .ended {
            UIView.animateKeyframes(withDuration: 0.3, delay: 0.01, options: [], animations: {
                self.toScreenView.frame.origin.x = -UIScreen.main.bounds.width
            }) { finished in
                self.toScreenView.removeFromSuperview()
                self.toScreenView = nil
                self.toScreenTextView = nil
            }
        }
    }
}
