//
//  EditNoteViewController.swift
//  MemoryMaster
//
//  Created by apple on 23/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit
import CoreData
import Photos
import SVProgressHUD

protocol EditNoteViewControllerDelegate: class {
    func passNoteInforBack(noteInfo: MyBasicNoteInfo)
}

private let cellReuseIdentifier = "EditNoteCollectionViewCell"

class EditNoteViewController: BaseTopViewController {

    // public api
    var isFirstTimeEdit = false
    var passedInCardIndex: IndexPath?
    var passedInCardStatus: String?
    var passedInNoteInfo: MyBasicNoteInfo! {
        didSet {
            minAddCardIndex = passedInNoteInfo?.numberOfCard
            minRemoveCardIndex = passedInNoteInfo?.numberOfCard
        }
    }
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer {
        didSet {
            setupData()
        }
    }
        
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flipButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIButton!
    
    var notes = [CardContent]()
    var changedCard = Set<Int>()
    
    var minAddCardIndex: Int?
    var minRemoveCardIndex: Int?
    
    var currentCardIndex: Int {
        return Int(collectionView.contentOffset.x) / Int(collectionView.bounds.width)
    }
    
    weak var delegate: EditNoteViewControllerDelegate?
    var keyBoardHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
    }

    override func setupUI() {
        super.setupUI()
        titleLabel.text = passedInNoteInfo.name
        
        if passedInNoteInfo.type == NoteType.single.rawValue {
            flipButton.image = UIImage(named: "flip_icon_disable")
            flipButton.isEnabled = false
        }
        
        saveButton.setTitleColor(UIColor.white, for: .normal)
        view.bringSubview(toFront: saveButton)
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = UIColor.lightGray
        
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView.collectionViewLayout = layout
        
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(returnKeyBoard))
        swipeRecognizer.direction = .down
        swipeRecognizer.numberOfTouchesRequired = 1
        collectionView.addGestureRecognizer(swipeRecognizer)
        
        let nib = UINib(nibName: cellReuseIdentifier, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: cellReuseIdentifier)
    }
    
    private func setupData() {
        for i in 0..<passedInNoteInfo.numberOfCard {
            let cardContent = CardContent.getCardContent(with: passedInNoteInfo.name, at: i, in: passedInNoteInfo.type)
            notes.append(cardContent)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.setNeedsLayout()
        if let indexPath = passedInCardIndex {
            collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
            if let status = passedInCardStatus {
                setFilpButton(cellStatus: CardStatus(rawValue: status)!)
            } else {
                if passedInNoteInfo.type == NoteType.single.rawValue && notes[indexPath.item].title == NSAttributedString() {
                    flipButton.image = UIImage(named: "flip_icon_disable")
                    flipButton.isEnabled = false
                } else {
                    flipButton.image = UIImage(named: "flip_icon")
                    flipButton.isEnabled = true
                }
            }
        }
        self.registerForKeyboardNotifications()
    }
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        
        let cell = collectionView.cellForItem(at: IndexPath(item: currentCardIndex, section: 0)) as! EditNoteCollectionViewCell
        let status: CardStatus! = cell.currentStatus

        let userDefault = UserDefaults.standard
        if var dict = userDefault.dictionary(forKey: UserDefaultsKeys.lastReadStatus) {
            dict.updateValue((passedInNoteInfo?.id)!, forKey: UserDefaultsDictKey.id)
            dict.updateValue(currentCardIndex, forKey: UserDefaultsDictKey.cardIndex)
            dict.updateValue(ReadType.edit.rawValue, forKey: UserDefaultsDictKey.readType)
            dict.updateValue(status.rawValue, forKey: UserDefaultsDictKey.cardStatus)
            userDefault.set(dict, forKey: UserDefaultsKeys.lastReadStatus)
        } else {
            let statusDict: [String : Any] = [UserDefaultsDictKey.id: (passedInNoteInfo?.id)!, UserDefaultsDictKey.cardIndex: currentCardIndex, UserDefaultsDictKey.readType: ReadType.edit.rawValue, UserDefaultsDictKey.cardStatus: status.rawValue]
            userDefault.set(statusDict, forKey: UserDefaultsKeys.lastReadStatus)
        }
    }
    
    // MARK: show and dismiss keyboard
    @objc private func keyboardWasShown(notification: Notification) {
        let info = notification.userInfo! as NSDictionary
        let nsValue = info.object(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        keyBoardHeight = nsValue.cgRectValue.size.height
        
        let cell = collectionView.cellForItem(at: IndexPath(item: currentCardIndex, section: 0)) as! EditNoteCollectionViewCell
        cell.cutTextView(KBHeight: keyBoardHeight)
    }
    
    @objc func returnKeyBoard(byReactionTo swipeRecognizer: UISwipeGestureRecognizer) {
        if swipeRecognizer.state == .ended {
            let indexPath = IndexPath(item: currentCardIndex, section: 0)
            let cell = collectionView.cellForItem(at: indexPath) as! EditNoteCollectionViewCell
            cell.editingTextView?.resignFirstResponder()
            cell.extendTextView()
        }
    }
    
    @IBAction func addNoteAction(_ sender: UIBarButtonItem) {
        let cardContent = CardContent(title: NSAttributedString.init(), body: NSAttributedString.init())
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
        let index = currentCardIndex + 1
        notes.insert(cardContent, at: index)
        collectionView.reloadData()
        collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .left, animated: true)
        collectionView.reloadItems(at: [IndexPath(item: index - 1, section: 0)])
        if var minIndex = minAddCardIndex, minIndex > index {
            minIndex = index
        }
        if passedInNoteInfo.type == NoteType.single.rawValue {
            setFilpButton(cellStatus: CardStatus.bodyFrontWithoutTitle)
        } else {
            setFilpButton(cellStatus: CardStatus.titleFront)
        }
    }
    
    @IBAction func removeNoteAction(_ sender: UIBarButtonItem) {
        if notes.count == 1 {
            self.showAlert(title: "Error!", message: "A note must has one item at least.")
            return
        }
        let index = currentCardIndex
        
        if index == 0 {
            collectionView.scrollToItem(at: IndexPath(item: index + 1, section: 0), at: .left, animated: true)
            notes.remove(at: index)
            collectionView.reloadData()
            // have to add function reloadItems, or there will be a cell not update
            collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .left, animated: true)
            return
        }
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
        notes.remove(at: index)
        collectionView.reloadData()
        collectionView.scrollToItem(at: IndexPath(item: index - 1, section: 0), at: .left, animated: true)
        collectionView.reloadItems(at: [IndexPath(item: index - 1, section: 0)])
        
        if var minIndex = minRemoveCardIndex, minIndex > index {
            minIndex = index
        }
        
        if passedInNoteInfo.type == NoteType.single.rawValue {
            let cell = collectionView.cellForItem(at: IndexPath(item: currentCardIndex, section: 0)) as! EditNoteCollectionViewCell
            setFilpButton(cellStatus: cell.currentStatus!)
        }
    }
    
    @IBAction func addPhotoAction(_ sender: UIBarButtonItem) {
        let cell = collectionView.cellForItem(at: IndexPath(item: currentCardIndex, section: 0)) as! EditNoteCollectionViewCell
        cell.editingTextView?.resignFirstResponder()
        cell.extendTextView()
        showPhotoMenu()
    }
    
    @IBAction func addBookmarkAction(_ sender: UIBarButtonItem) {
        let cell = collectionView.cellForItem(at: IndexPath(item: currentCardIndex, section: 0)) as! EditNoteCollectionViewCell
        let placeholder = String(format: "%@-%@-%@-%d-%@", passedInNoteInfo.name, passedInNoteInfo.type, ReadType.edit.rawValue, currentCardIndex, cell.currentStatus!.rawValue)
        let alert = UIAlertController(title: "Bookmark", message: "Give a name for the bookmark.", preferredStyle: .alert)
        alert.addTextField { textFiled in
            textFiled.placeholder = placeholder
        }
        let ok = UIAlertAction(title: "OK", style: .default, handler: { [weak self = self] action in
            var text = placeholder
            if alert.textFields![0].text! != "" {
                text = alert.textFields![0].text!
            }
            let isNameUsed = try? BookMark.find(matching: text, in: (self?.container?.viewContext)!)
            if isNameUsed! {
                self?.showAlert(title: "Error!", message: "Name already used, please give another name.")
            } else {
                let bookmark = MyBookmark(name: text, id: (self?.passedInNoteInfo.id)!, time: Date(), readType: ReadType.edit.rawValue, readPage: (self?.currentCardIndex)!, readPageStatus: cell.currentStatus!.rawValue)
                self?.container?.performBackgroundTask({ (context) in
                    self?.save()
                    BookMark.findOrCreate(matching: bookmark, in: context)
                    DispatchQueue.main.async {
                        self?.showSavedPrompt()
                    }
                })
            }
        })
        let cancel = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func flipCardAction(_ sender: UIBarButtonItem) {
        let cell = collectionView.cellForItem(at: IndexPath(item: currentCardIndex, section: 0)) as! EditNoteCollectionViewCell
        if cell.currentStatus! == CardStatus.titleFront {
            cell.currentStatus = CardStatus.bodyFrontWithTitle
            cell.showBody(noteType: NoteType(rawValue: passedInNoteInfo.type)!)
        } else {
            cell.currentStatus = CardStatus.titleFront
            cell.showTitle(noteType: NoteType(rawValue: passedInNoteInfo.type)!)
        }
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
        playSound.playClickSound(SystemSound.buttonClick)
        save()
        showSavedPrompt()
    }
    
    override func backAction(_ sender: UIButton) {
        playSound.playClickSound(SystemSound.buttonClick)
        let minChangedIndex = minRemoveCardIndex! < minAddCardIndex! ? minRemoveCardIndex! : minAddCardIndex!
        
        if changedCard.isEmpty && minChangedIndex == passedInNoteInfo.numberOfCard && notes.count == passedInNoteInfo.numberOfCard {
            if let context = container?.viewContext {
                _ = try? BasicNoteInfo.findOrCreate(matching: passedInNoteInfo!, in: context)
                try? context.save()
            }
            dismissView()
        } else {
            showAlertWithAction(title: "Reminder!", message: "Do you want to save your change?", hasNo: true, yesHandler: { [weak self] _ in
                    self?.save()
                    self?.showSavedPrompt()
                    self?.afterDelay(0.8) {
                        self?.dismissView()
                    }
                }, noHandler: { [weak self] _ in
                    self?.dismissView()
            })
        }
    }
    
    private func save() {
        let minChangedIndex = minRemoveCardIndex! < minAddCardIndex! ? minRemoveCardIndex! : minAddCardIndex!
        
        if minChangedIndex == passedInNoteInfo.numberOfCard && notes.count == passedInNoteInfo.numberOfCard
        {
            // case 1: no card added or removed
            for i in changedCard {
                notes[i].saveCardContentToFile(cardIndex: i, noteName: passedInNoteInfo.name, noteType: passedInNoteInfo.type)
            }
        } else if minChangedIndex == passedInNoteInfo.numberOfCard && notes.count > passedInNoteInfo.numberOfCard
        {
            // case 2: card only add or removed after original length
            for i in minChangedIndex..<notes.count {
                notes[i].saveCardContentToFile(cardIndex: i, noteName: passedInNoteInfo.name, noteType: passedInNoteInfo.type)
            }
            
            for i in changedCard {
                notes[i].saveCardContentToFile(cardIndex: i, noteName: passedInNoteInfo.name, noteType: passedInNoteInfo.type)
            }
        } else
        {
            // case 3: card inserted or removed in original array range
            for i in minChangedIndex..<passedInNoteInfo.numberOfCard {
                CardContent.removeCardContent(with: passedInNoteInfo.name, at: i, in: passedInNoteInfo.type)
            }
            if minChangedIndex <= notes.count {
                for i in minChangedIndex..<notes.count {
                    notes[i].saveCardContentToFile(cardIndex: i, noteName: passedInNoteInfo.name, noteType: passedInNoteInfo.type)
                }
            }
            
            for i in changedCard {
                if i < minChangedIndex {
                    notes[i].saveCardContentToFile(cardIndex: i, noteName: passedInNoteInfo.name, noteType: passedInNoteInfo.type)
                } else {
                    break
                }
            }
        }
        changedCard.removeAll()
        
        passedInNoteInfo.numberOfCard = notes.count
        let context = container?.viewContext
        _ = try? BasicNoteInfo.findOrCreate(matching: passedInNoteInfo!, in: context!)
        try? context?.save()
    }
    
    private func afterDelay(_ seconds: Double, closure: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: closure)
    }

    private func dismissView() {
        delegate?.passNoteInforBack(noteInfo: passedInNoteInfo!)
        guard isFirstTimeEdit else {
            dismiss(animated: true, completion: nil)
            return
        }
        let controller = self.presentingViewController?.presentingViewController
        controller?.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "RefreshPage"), object: nil)
        })
    }
    
    private func setFilpButton(cellStatus: CardStatus) {
        if cellStatus == CardStatus.bodyFrontWithoutTitle {
            flipButton.image = UIImage(named: "flip_icon_disable")
            flipButton.isEnabled = false
        } else {
            flipButton.image = UIImage(named: "flip_icon")
            flipButton.isEnabled = true
        }
    }
}

extension EditNoteViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if passedInNoteInfo.type == NoteType.single.rawValue {
            let cell = collectionView.cellForItem(at: IndexPath(item: currentCardIndex, section: 0)) as! EditNoteCollectionViewCell
            setFilpButton(cellStatus: cell.currentStatus!)
        }
    }
}

extension EditNoteViewController: UICollectionViewDelegate, UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let newCell = cell as! EditNoteCollectionViewCell
        var cellStatus = CardStatus.titleFront
        if passedInNoteInfo.type == NoteType.single.rawValue && notes[indexPath.item].title == NSAttributedString() {
            cellStatus = CardStatus.bodyFrontWithoutTitle
        } else if let passIndex = passedInCardIndex, let status = passedInCardStatus, indexPath == passIndex {
            cellStatus = CardStatus(rawValue: status)!
        }
        newCell.updateCell(with: notes[indexPath.row], at: indexPath.row, total: notes.count, cellStatus: cellStatus, noteType: NoteType(rawValue: passedInNoteInfo.type)!)
        newCell.delegate = self
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "EditNoteCollectionViewCell", for: indexPath) as! EditNoteCollectionViewCell
    }
}

extension EditNoteViewController: EditNoteCollectionViewCellDelegate {
    func noteTitleEdit(for cell: EditNoteCollectionViewCell) {
        if cell.titleEditButton.titleLabel?.text == "Add Title" {
            cell.currentStatus = CardStatus.titleFront
            cell.showTitle(noteType: NoteType.single)
        } else {
            cell.currentStatus = CardStatus.bodyFrontWithoutTitle
            cell.showBody(noteType: NoteType.single)
            cell.titleTextView.attributedText = NSAttributedString()
        }
        setFilpButton(cellStatus: cell.currentStatus!)
    }
    
    func noteTextContentChange(cardIndex: Int, textViewType: String, textContent: NSAttributedString) {
        if textViewType == "title" {
            if !notes[cardIndex].title.isEqual(to: textContent) {
                notes[cardIndex].title = textContent
                if cardIndex < passedInNoteInfo.numberOfCard {
                    changedCard.insert(cardIndex)
                }
            }
        } else {
            if !notes[cardIndex].body.isEqual(to: textContent) {
                notes[cardIndex].body = textContent
                if cardIndex < passedInNoteInfo.numberOfCard {
                    changedCard.insert(cardIndex)
                }
            }
        }
    }
    
    func noteAddPhoto() {
        let cell = collectionView.cellForItem(at: IndexPath(item: currentCardIndex, section: 0)) as! EditNoteCollectionViewCell
        cell.editingTextView?.resignFirstResponder()
        cell.extendTextView()
        showPhotoMenu()
    }
}

extension EditNoteViewController: TOCropViewControllerDelegate {
    func cropViewController(_ cropViewController: TOCropViewController, didCropToImage image: UIImage, rect cropRect: CGRect, angle: Int)
    {
        let cell = collectionView.cellForItem(at: IndexPath(item: currentCardIndex, section: 0)) as! EditNoteCollectionViewCell
        
        let width = (cell.editingTextView?.bounds.width)! - CustomDistance.wideEdge * 2 - (cell.editingTextView?.textContainer.lineFragmentPadding)! * 2
                
        let insertImage = UIImage.scaleImageToFitTextView(image, fit: width)
        if cell.editingTextView?.tag == OutletTag.titleTextView.rawValue {
            notes[currentCardIndex].title = updateTextView(notes[currentCardIndex].title , image: insertImage!)
        } else {
            notes[currentCardIndex].body = updateTextView(notes[currentCardIndex].body, image: insertImage!)
        }
        changedCard.insert(currentCardIndex)
        cropViewController.dismiss(animated: true) { [weak self] in
            cell.updateCell(with: (self?.notes[(self?.currentCardIndex)!])!, at: (self?.currentCardIndex)!, total: (self?.notes.count)!, cellStatus: cell.currentStatus!, noteType: NoteType(rawValue: (self?.passedInNoteInfo.type)!)!)

        }
    }
    
    private func updateTextView(_ text: NSAttributedString, image: UIImage) -> NSAttributedString {
        let cell = collectionView.cellForItem(at: IndexPath(item: currentCardIndex, section: 0)) as! EditNoteCollectionViewCell

        let font = cell.editingTextView?.font
        let imgTextAtta = NSTextAttachment()
        imgTextAtta.image = image
        var range: NSRange! = cell.editingTextView?.selectedRange
        if range.location == NSNotFound {
            range.location = (cell.editingTextView?.text.count)!
        }
        
        cell.editingTextView?.textStorage.insert(NSAttributedString.init(attachment: imgTextAtta), at: range.location)
        cell.editingTextView?.font = font
        cell.editingTextView?.selectedRange = NSRange(location: range.location + 1, length: 0)
        return (cell.editingTextView?.attributedText)!
    }
}

extension EditNoteViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func showPhotoMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: { _ in self.takePhotoWithCamera() })
        alertController.addAction(takePhotoAction)
        let chooseFormLibraryAction = UIAlertAction(title: "Choose From Library", style: .default, handler: { _ in self.choosePhotoFromLibrary() })
        alertController.addAction(chooseFormLibraryAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func takePhotoWithCamera() {
        let oldStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        AVCaptureDevice.requestAccess(for: .video) { [weak self] isPermit in
            if isPermit {
                DispatchQueue.main.async {
                    let imagePicker = UIImagePickerController()
                    imagePicker.sourceType = .camera
                    imagePicker.delegate = self
                    imagePicker.allowsEditing = true
                    self?.present(imagePicker, animated: true, completion: nil)
                }
            } else {
                if oldStatus == .notDetermined {
                    return
                }
                DispatchQueue.main.async {
                    self?.showAlert(title: "Alert!", message: "Please allow us to use your phone camera. You can set the permission at Setting -> Privacy -> Camera")
                }
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        let controller = TOCropViewController.init(image: image!)
        controller.delegate = self
        dismiss(animated: true, completion: { [weak self] in
            self?.present(controller, animated: true, completion: nil)
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        passedInCardIndex = IndexPath(item: currentCardIndex, section: 0)
        let cell = collectionView.cellForItem(at: passedInCardIndex!) as! EditNoteCollectionViewCell
        passedInCardStatus = cell.currentStatus?.rawValue
        dismiss(animated: true, completion: nil)
    }
    
    func choosePhotoFromLibrary() {
        let oldStatus = PHPhotoLibrary.authorizationStatus()
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            switch status {
            case .authorized:
                DispatchQueue.main.async {
                    let controller = ImagePickerViewController.init(nibName: "ImagePickerViewController", bundle: nil)
                    controller.noteController = self
                    self?.present(controller, animated: true, completion: {
                        let indexPath = IndexPath(item: (self?.currentCardIndex)!, section: 0)
                        self?.passedInCardIndex = indexPath
                    })
                }
            case .denied:
                if oldStatus == .notDetermined {
                    return
                }
                DispatchQueue.main.async {
                    self?.showAlert(title: "Alert!", message: "Please allow us to access your photo library. You can set the permission at Setting -> Privacy -> Photos")
                }
            default:
                break
            }
        }
    }
}
