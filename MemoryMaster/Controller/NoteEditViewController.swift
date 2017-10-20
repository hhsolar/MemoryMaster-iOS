//
//  NoteEditViewController.swift
//  MemoryMaster
//
//  Created by apple on 10/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit
import CoreData
import Photos
import SVProgressHUD

protocol NoteEditViewControllerDelegate: class {
    func passNoteInforBack(noteInfo: MyBasicNoteInfo)
}

class NoteEditViewController: UIViewController {

    // public api
    var isFirstTimeEdit = false
    var passedInCardIndex: IndexPath?
    var passedInCardStatus: String?
    var passedInNoteInfo: MyBasicNoteInfo? {
        didSet {
            minAddCardIndex = passedInNoteInfo?.numberOfCard
            minRemoveCardIndex = passedInNoteInfo?.numberOfCard
            if passedInNoteInfo?.type == NoteType.qa.rawValue {
                addPhotoCardStatus = CardStatus.titleFront
                noteType = NoteType.qa
            } else {
                noteType = NoteType.single
            }
            
        }
    }
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer {
        didSet {
            updateUI()
        }
    }
    
    // public api for cell
    var currentTextView: UITextView?
    var addPhotoCardStatus: CardStatus?
    var passInRange: NSRange?

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var editCollectionView: UICollectionView!
    
    var notes = [CardContent]()
    var changedCard = Set<Int>()
    
    var minAddCardIndex: Int?
    var minRemoveCardIndex: Int?
    
    var currentCardIndex: Int {
        return Int(editCollectionView.contentOffset.x) / Int(editCollectionView.bounds.width)
    }

    weak var delegate: NoteEditViewControllerDelegate?
    var keyBoardHeight: CGFloat = 0
    
    var noteType: NoteType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(returnKeyBoard))
        swipeRecognizer.direction = .down
        swipeRecognizer.numberOfTouchesRequired = 1
        editCollectionView.addGestureRecognizer(swipeRecognizer)
    }
    
    @objc private func keyboardWasShown(notification: Notification) {
        let info = notification.userInfo! as NSDictionary
        let nsValue = info.object(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        keyBoardHeight = nsValue.cgRectValue.size.height
        
        let cell = editCollectionView.cellForItem(at: IndexPath(item: currentCardIndex, section: 0)) as! NoteEditCollectionViewCell
        cell.cutTextView(KBHeight: keyBoardHeight)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editCollectionView.setNeedsLayout()
        if let indexPath = passedInCardIndex {
            editCollectionView.scrollToItem(at: indexPath, at: .left, animated: false)
            
            if let passedInCardStatus = passedInCardStatus {
                if noteType! == NoteType.single {
                    let cell = editCollectionView.dequeueReusableCell(withReuseIdentifier: "SingleEditCollectionViewCell", for: indexPath) as! SingleEditCollectionViewCell
                    cell.updateCell(with: notes[indexPath.item], at: indexPath.item, total: notes.count, cellStatus: CardStatus(rawValue: passedInCardStatus)!)
                } else {
                    let cell = editCollectionView.dequeueReusableCell(withReuseIdentifier: "QAEditCollectionViewCell", for: indexPath) as! QAEditCollectionViewCell
                    cell.updateCell(with: notes[indexPath.item], at: indexPath.item, total: notes.count, cellStatus: CardStatus(rawValue: passedInCardStatus)!)
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
        
        var status = CardStatus.bodyFrontWithTitle
        if noteType! == NoteType.single {
            let cell = editCollectionView.cellForItem(at: IndexPath(item: currentCardIndex, section: 0)) as! SingleEditCollectionViewCell
            status = cell.currentCardStatus!
        } else {
            let cell = editCollectionView.cellForItem(at: IndexPath(item: currentCardIndex, section: 0)) as! QAEditCollectionViewCell
            status = cell.currentCardStatus!
        }
        
        let userDefault = UserDefaults.standard
        if var dict = userDefault.dictionary(forKey: "lastStatus") {
            dict.updateValue((passedInNoteInfo?.id)!, forKey: "id")
            dict.updateValue(currentCardIndex, forKey: "index")
            dict.updateValue(ReadType.edit.rawValue, forKey: "readType")
            dict.updateValue(status.rawValue, forKey: "cardStatus")
            userDefault.set(dict, forKey: "lastStatus")
        } else {
            let statusDict: [String : Any] = ["id": (passedInNoteInfo?.id)!, "index": currentCardIndex, "readType": ReadType.edit.rawValue, "cardStatus": status.rawValue]
            userDefault.set(statusDict, forKey: "lastStatus")
        }
    }
    
    private func updateUI() {
        if let info = passedInNoteInfo {
            for i in 0..<info.numberOfCard {
                let cardContent = CardContent.getCardContent(with: info.name, at: i, in: info.type)
                notes.append(cardContent)
            }
        }
    }
    
    private func setupUI()
    {
        titleLabel.text = passedInNoteInfo?.name ?? "No name"
        titleLabel.textColor = CustomColor.medianBlue
        
        self.view.backgroundColor = UIColor.lightGray
        topView.backgroundColor = CustomColor.lightGreen
        
        topView.layer.cornerRadius = 15
        topView.layer.masksToBounds = true
        
        editCollectionView.delegate = self
        editCollectionView.dataSource = self
        editCollectionView.isPagingEnabled = true
        editCollectionView.showsHorizontalScrollIndicator = false
        editCollectionView.backgroundColor = UIColor.lightGray
        
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize(width: editCollectionView.bounds.width, height: editCollectionView.bounds.height)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        editCollectionView.collectionViewLayout = layout
        
        editCollectionView.register(SingleEditCollectionViewCell.self, forCellWithReuseIdentifier: "SingleEditCollectionViewCell")
        editCollectionView.register(QAEditCollectionViewCell.self, forCellWithReuseIdentifier: "QAEditCollectionViewCell")
    }
    
    @objc func returnKeyBoard(byReactionTo swipeRecognizer: UISwipeGestureRecognizer) {
        if swipeRecognizer.state == .ended {
            let indexPath = IndexPath(item: currentCardIndex, section: 0)
            let cell = editCollectionView.cellForItem(at: indexPath) as! NoteEditCollectionViewCell
            cell.editingTextView?.resignFirstResponder()
            cell.extendTextView()
        }
    }
    
    @IBAction func saveNote(_ sender: UIButton) {
        save()
        showSavedPrompt()
    }
    
    private func save() {
        let minChangedIndex = minRemoveCardIndex! < minAddCardIndex! ? minRemoveCardIndex! : minAddCardIndex!

        if minChangedIndex == (passedInNoteInfo?.numberOfCard)! && notes.count == (passedInNoteInfo?.numberOfCard)!
        {
            // case 1: no card added or removed
            for i in changedCard {
                notes[i].title.saveTextToFile(with: (passedInNoteInfo?.name)!, at: i, in: (passedInNoteInfo?.type)!, contentType: "title")
                notes[i].body.saveTextToFile(with: (passedInNoteInfo?.name)!, at: i, in: (passedInNoteInfo?.type)!, contentType: "body")
            }
        } else if minChangedIndex == (passedInNoteInfo?.numberOfCard)! && notes.count > (passedInNoteInfo?.numberOfCard)!
        {
            // case 2: card only add or removed after original length
            for i in minChangedIndex..<notes.count {
                notes[i].title.saveTextToFile(with: (passedInNoteInfo?.name)!, at: i, in: (passedInNoteInfo?.type)!, contentType: "title")
                notes[i].body.saveTextToFile(with: (passedInNoteInfo?.name)!, at: i, in: (passedInNoteInfo?.type)!, contentType: "body")
            }
            
            for i in changedCard {
                notes[i].title.saveTextToFile(with: (passedInNoteInfo?.name)!, at: i, in: (passedInNoteInfo?.type)!, contentType: "title")
                notes[i].body.saveTextToFile(with: (passedInNoteInfo?.name)!, at: i, in: (passedInNoteInfo?.type)!, contentType: "body")
            }
        } else
        {
            // case 3: card inserted or removed in original array range
            for i in minChangedIndex..<(passedInNoteInfo?.numberOfCard)! {
                CardContent.removeCardContent(with: (passedInNoteInfo?.name)!, at: i, in: (passedInNoteInfo?.type)!)
            }
            if minChangedIndex <= notes.count {
                for i in minChangedIndex..<notes.count {
                    notes[i].title.saveTextToFile(with: (passedInNoteInfo?.name)!, at: i, in: (passedInNoteInfo?.type)!, contentType: "title")
                    notes[i].body.saveTextToFile(with: (passedInNoteInfo?.name)!, at: i, in: (passedInNoteInfo?.type)!, contentType: "body")
                }
            }
            
            for i in changedCard {
                if i < minChangedIndex {
                    notes[i].title.saveTextToFile(with: (passedInNoteInfo?.name)!, at: i, in: (passedInNoteInfo?.type)!, contentType: "title")
                    notes[i].body.saveTextToFile(with: (passedInNoteInfo?.name)!, at: i, in: (passedInNoteInfo?.type)!, contentType: "body")
                } else {
                    break
                }
            }
        }
        changedCard.removeAll()
        
        passedInNoteInfo?.numberOfCard = notes.count
        let context = container?.viewContext
        _ = try? BasicNoteInfo.findOrCreate(matching: passedInNoteInfo!, in: context!)
        try? context?.save()
    }
        
    @IBAction func exit(_ sender: UIButton) {
        let minChangedIndex = minRemoveCardIndex! < minAddCardIndex! ? minRemoveCardIndex! : minAddCardIndex!

        if changedCard.isEmpty && minChangedIndex == (passedInNoteInfo?.numberOfCard)! && notes.count == (passedInNoteInfo?.numberOfCard)! {
            if let context = container?.viewContext {
                _ = try? BasicNoteInfo.findOrCreate(matching: passedInNoteInfo!, in: context)
                try? context.save()
            }
            dismissView()
        } else {
            let alert = UIAlertController(title: "Reminder!", message: "Do you want to save your change?", preferredStyle: .alert)
            let yes = UIAlertAction(title: "YES", style: .default, handler: { [weak self] action in
                self?.save()
                self?.showSavedPrompt()
                self?.afterDelay(1.0) {
                    self?.dismissView()
                }
            })
            let no = UIAlertAction(title: "NO", style: .default, handler: { [weak self] action in
                self?.dismissView()
            })
            let cancel = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
            alert.addAction(yes)
            alert.addAction(no)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
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
}

extension NoteEditViewController: UICollectionViewDelegate, UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let noteInfo = passedInNoteInfo {
            if noteInfo.type == NoteType.single.rawValue {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SingleEditCollectionViewCell", for: indexPath) as! SingleEditCollectionViewCell
                cell.singleCellDelegate = self
                cell.delegate = self
                cell.awakeFromNib()
                var singleCellStatus = CardStatus.bodyFrontWithoutTitle
                if let addPhotoCardStatus = addPhotoCardStatus {
                    singleCellStatus = addPhotoCardStatus
                } else if notes[indexPath.row].title != NSAttributedString.init() {
                    singleCellStatus = CardStatus.titleFront
                }
                cell.updateCell(with: notes[indexPath.row], at: indexPath.row, total: notes.count, cellStatus: singleCellStatus)
                addPhotoCardStatus = nil
                return cell
            } else if noteInfo.type == NoteType.qa.rawValue {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QAEditCollectionViewCell", for: indexPath) as! QAEditCollectionViewCell
                cell.qaCellDelegate = self
                cell.delegate = self
                cell.awakeFromNib()
                cell.updateCell(with: notes[indexPath.row], at: indexPath.row, total: notes.count, cellStatus: addPhotoCardStatus!)
                addPhotoCardStatus = CardStatus.titleFront
                return cell
            }
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SingleEditCollectionViewCell", for: indexPath) as! SingleEditCollectionViewCell
        return cell
    }
}

extension NoteEditViewController: SingleEditCollectionViewCellDelegate {
    func addNoteCard(for cell: NoteEditCollectionViewCell) {
        let cardContent = CardContent(title: NSAttributedString.init(), body: NSAttributedString.init())
        editCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
        let index = cell.cardIndex! + 1
        notes.insert(cardContent, at: index)
        editCollectionView.reloadData()
        editCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .left, animated: true)
        editCollectionView.reloadItems(at: [IndexPath(item: index - 1, section: 0)])
        
        if var minIndex = minAddCardIndex, minIndex > index {
            minIndex = index
        }
    }
    
    func removeNoteCard(for cell: NoteEditCollectionViewCell) {
        if notes.count == 1 {
            self.showAlert(title: "Error!", message: "A note must has one item at least.")
            return
        }
        let index = cell.cardIndex!
        
        if index == 0 {
            editCollectionView.scrollToItem(at: IndexPath(item: index + 1, section: 0), at: .left, animated: true)
            notes.remove(at: index)
            editCollectionView.reloadData()
            // have to add function reloadItems, or there will be a cell not update
            editCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            editCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .left, animated: true)
            return
        }
        editCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
        notes.remove(at: index)
        editCollectionView.reloadData()
        editCollectionView.scrollToItem(at: IndexPath(item: index - 1, section: 0), at: .left, animated: true)
        editCollectionView.reloadItems(at: [IndexPath(item: index - 1, section: 0)])
        
        if var minIndex = minRemoveCardIndex, minIndex > index {
            minIndex = index
        }
    }
    
    func noteTextContentChange(cardIndex: Int, textViewType: String, textContent: NSAttributedString) {
        if textViewType == "title" {
            if !notes[cardIndex].title.isEqual(to: textContent) {
                notes[cardIndex].title = textContent
                if cardIndex < (passedInNoteInfo?.numberOfCard)! {
                    changedCard.insert(cardIndex)
                }
            }
        } else {
            if !notes[cardIndex].body.isEqual(to: textContent) {
                notes[cardIndex].body = textContent
                if cardIndex < (passedInNoteInfo?.numberOfCard)! {
                    changedCard.insert(cardIndex)
                }
            }
        }
    }
    
    func singleNoteTitleEdit(for cell: SingleEditCollectionViewCell) {
        if cell.addTitleButton.currentTitle == "ADD TITLE" {
            cell.addTitle()
        } else {
            cell.removeTitle()
        }
    }
    
    func filpSingleNoteCard(for cell: SingleEditCollectionViewCell) {
        cell.changeFilpButtonText()
    }
    
    func singleNoteAddPhoto(for textView: UITextView, with range: NSRange, cellStatus: CardStatus) {
        currentTextView = textView
        passInRange = range
        addPhotoCardStatus = cellStatus
        showPhotoMenu()
    }
    
    func singleNoteAddBookmark(index: Int, cellStatus: CardStatus) {
        let placeholder = String(format: "%@-%@-%@-%d-%@", (passedInNoteInfo?.name)!, NoteType.single.rawValue, ReadType.edit.rawValue, index + 1, cellStatus.rawValue)
        let alert = UIAlertController(title: "Bookmark", message: "Give a name for the bookmark.", preferredStyle: .alert)
        alert.addTextField { textFiled in
            textFiled.placeholder = placeholder
        }
        let ok = UIAlertAction(title: "OK", style: .default, handler: { [weak self] action in
            var text = placeholder
            if alert.textFields![0].text! != "" {
                text = alert.textFields![0].text!
            }
            let isNameUsed = try? BookMark.find(matching: text, in: (self?.container?.viewContext)!)
            if isNameUsed! {
                self?.showAlert(title: "Error!", message: "Name already used, please give another name.")
            } else {
                let bookmark = MyBookmark(name: text, id: (self?.passedInNoteInfo?.id)!, time: Date(), readType: ReadType.edit.rawValue, readPage: index, readPageStatus: cellStatus.rawValue)
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
}

extension NoteEditViewController: QAEditCollectionViewCellDelegate {
    func filpQANoteCard(for cell: QAEditCollectionViewCell) {
        cell.changeFilpButtonText()
    }
    
    func qaNoteAddPhoto(for textView: UITextView, with range: NSRange, cellStatus: CardStatus) {
        currentTextView = textView
        passInRange = range
        addPhotoCardStatus = cellStatus
        showPhotoMenu()
    }
    
    func qaNoteAddBookmark(index: Int, cellStatus: CardStatus) {
        let placeholder = String(format: "%@-%@-%@-%d-%@", (passedInNoteInfo?.name)!, NoteType.qa.rawValue, ReadType.edit.rawValue, index + 1, cellStatus.rawValue)
        let alert = UIAlertController(title: "Bookmark", message: "Give a name for the bookmark.", preferredStyle: .alert)
        alert.addTextField { textFiled in
            textFiled.placeholder = placeholder
        }
        let ok = UIAlertAction(title: "OK", style: .default, handler: { [weak self] action in
            var text = placeholder
            if alert.textFields![0].text! != "" {
                text = alert.textFields![0].text!
            }
            let isNameUsed = try? BookMark.find(matching: text, in: (self?.container?.viewContext)!)
            if isNameUsed! {
                self?.showAlert(title: "Error!", message: "Name already used, please give another name.")
            } else {
                let bookmark = MyBookmark(name: text, id: (self?.passedInNoteInfo?.id)!, time: Date(), readType: ReadType.edit.rawValue, readPage: index, readPageStatus: cellStatus.rawValue)
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
}

extension NoteEditViewController: TOCropViewControllerDelegate {
    func cropViewController(_ cropViewController: TOCropViewController, didCropToImage image: UIImage, rect cropRect: CGRect, angle: Int)
    {
        let width = (currentTextView?.bounds.width)! - 10
        let insertImage = UIImage.scaleImageToFitTextView(image, fit: width)
        if currentTextView?.tag == OutletTag.titleTextView.rawValue {
            notes[currentCardIndex].title = updateTextView(notes[currentCardIndex].title , image: insertImage!)
        } else {
            notes[currentCardIndex].body = updateTextView(notes[currentCardIndex].body, image: insertImage!)
        }
        changedCard.insert(currentCardIndex)
        cropViewController.dismiss(animated: true) { [weak self] in
            self?.editCollectionView.reloadData()
        }
    }
    
    private func updateTextView(_ text: NSAttributedString, image: UIImage) -> NSAttributedString {
        let font = currentTextView?.font
        let imgTextAtta = NSTextAttachment()
        imgTextAtta.image = image
        if let rg = passInRange {
            currentTextView?.textStorage.insert(NSAttributedString.init(attachment: imgTextAtta), at: rg.location)
        }
        currentTextView?.font = font
        currentTextView?.selectedRange = NSRange(location: (passInRange?.location)! + 1, length: 0)
        return (currentTextView?.attributedText)!
    }
}

extension NoteEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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

    func choosePhotoFromLibrary() {
        let oldStatus = PHPhotoLibrary.authorizationStatus()
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            switch status {
            case .authorized:
                DispatchQueue.main.async {
                    let controller = ImagePickerViewController.init(nibName: "ImagePickerViewController", bundle: nil)
                    controller.lastController = self
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
