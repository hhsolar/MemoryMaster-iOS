//
//  TestNoteViewController.swift
//  MemoryMaster
//
//  Created by apple on 11/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit
import CoreData

private let cellReuseIdentifier = "TestCollectionViewCell"

class TestNoteViewController: BaseTopViewController {

    // public api
    var passedInNoteInfo: MyBasicNoteInfo?
    var passedInNotes = [CardContent]()
    var passedInCardStatus: String?
    var startCardIndexPath: IndexPath?
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addBookmarkButton: UIButton!

    var scrollView: UIScrollView!
    var imageView: UIImageView!
    
    var currentIndex: Int {
        return Int(collectionView.contentOffset.x) / Int(collectionView.bounds.width)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        
        setupUI()
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(flipCard))
        tapRecognizer.numberOfTapsRequired = 1
        collectionView.addGestureRecognizer(tapRecognizer)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.setNeedsLayout()
        if let indexPath = startCardIndexPath {
            collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
        }
        if let status = passedInCardStatus {
            if status == CardStatus.bodyFrontWithTitle.rawValue {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: startCardIndexPath!) as! TestCollectionViewCell
                cell.containerView.sendSubview(toBack: cell.questionView)
                cell.questionAtFront = false
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let status = getCardStatus(index: currentIndex).rawValue
        
        let userDefault = UserDefaults.standard
        if var dict = userDefault.dictionary(forKey: UserDefaultsKeys.lastReadStatus) {
            dict.updateValue((passedInNoteInfo?.id)!, forKey: UserDefaultsDictKey.id)
            dict.updateValue(currentIndex, forKey: UserDefaultsDictKey.cardIndex)
            dict.updateValue(ReadType.test.rawValue, forKey: UserDefaultsDictKey.readType)
            dict.updateValue(status, forKey: UserDefaultsDictKey.cardStatus)
            userDefault.set(dict, forKey: UserDefaultsKeys.lastReadStatus)
        } else {
            let statusDict: [String : Any] = [UserDefaultsDictKey.id: (passedInNoteInfo?.id)!, UserDefaultsDictKey.cardIndex: currentIndex, UserDefaultsDictKey.readType: ReadType.test.rawValue, UserDefaultsDictKey.cardStatus: status]
            userDefault.set(statusDict, forKey: UserDefaultsKeys.lastReadStatus)
        }
    }
    
    private func getCardStatus(index: Int) -> CardStatus {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: IndexPath(item: index, section: 0)) as! TestCollectionViewCell
        var status = CardStatus.titleFront
        if cell.questionLabel.isHidden {
            status = CardStatus.bodyFrontWithTitle
        }
        return status
    }
    
    override func setupUI() {
        super.setupUI()
        super.titleLabel.text = passedInNoteInfo?.name ?? "Name"
        
        addBookmarkButton.setTitleColor(UIColor.white, for: .normal)
        view.bringSubview(toFront: addBookmarkButton)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize(width: (collectionView?.bounds.width)!, height: (collectionView?.bounds.height)!)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView.collectionViewLayout = layout
        
        let nib = UINib(nibName: cellReuseIdentifier, bundle: Bundle.main)
        collectionView?.register(nib, forCellWithReuseIdentifier: cellReuseIdentifier)
    }
    
    @objc func flipCard(byReactingTo tapRecognizer: UITapGestureRecognizer) {
        if tapRecognizer.state == .ended {
            let tapPoint = tapRecognizer.location(in: collectionView)
            let indexPath = collectionView.indexPathForItem(at: tapPoint)
            let cell = collectionView.cellForItem(at: indexPath!) as! TestCollectionViewCell
            if cell.questionAtFront {
                UIView.transition(from: cell.questionView, to: cell.answerView, duration: 0.4, options: UIViewAnimationOptions.transitionFlipFromLeft, completion: nil)
                cell.questionAtFront = false
            } else {
                UIView.transition(from: cell.answerView, to: cell.questionView, duration: 0.4, options: UIViewAnimationOptions.transitionFlipFromLeft, completion: nil)
                cell.questionAtFront = true
            }
        }
    }
    
    @IBAction func addBookmarkAction(_ sender: UIButton) {
        let status = getCardStatus(index: currentIndex).rawValue
        let placeholder = String(format: "%@-%@-%@-%d-%@", (passedInNoteInfo?.name)!, (passedInNoteInfo?.type)!, ReadType.test.rawValue, currentIndex + 1, status)
        
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
                let bookmark = MyBookmark(name: text, id: (self?.passedInNoteInfo?.id)!, time: Date(), readType: ReadType.test.rawValue, readPage: (self?.currentIndex)!, readPageStatus: status)
                self?.container?.performBackgroundTask({ (context) in
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

extension TestNoteViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return passedInNotes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let newCell = cell as! TestCollectionViewCell
        newCell.updateUI(question: passedInNotes[indexPath.row].title, answer: passedInNotes[indexPath.row].body, index: indexPath.row, total: passedInNotes.count)
        newCell.delegate = self
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        return collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath)
    }
}

extension TestNoteViewController: TestCollectionViewCellDelegate {
    func testEnlargeTapedImage(image: UIImage)
    {
        let xScale = UIScreen.main.bounds.width / image.size.width
        let yScale = UIScreen.main.bounds.height / image.size.height
        let scale = min(xScale, yScale)
        
        let newImage = UIImage.scaleImage(image, to: scale)
        imageView = UIImageView(image: newImage)
        
        setupScrollView()
        
        setZoomScales()
        setContentInset()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissImage))
        tapRecognizer.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(tapRecognizer)
        
        UIView.animate(withDuration: 0.3, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.scrollView.alpha = 1.0
        }, completion: nil)
    }
    
    private func setupScrollView() {
        scrollView = UIScrollView(frame: UIScreen.main.bounds)
        scrollView.backgroundColor = UIColor.black
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentSize = imageView.bounds.size
        scrollView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        
        view.addSubview(scrollView)
        view.bringSubview(toFront: scrollView)
        scrollView.addSubview(imageView)
        scrollView.alpha = 0.0
        
        scrollView.delegate = self
    }
    
    @objc func dismissImage(byReactingTo tapRecognizer: UITapGestureRecognizer) {
        if tapRecognizer.state == .ended {
            UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseOut, animations: {
                self.scrollView.alpha = 0.0
            }, completion: { finish in
                self.scrollView.removeFromSuperview()
                self.imageView = nil
                self.scrollView = nil
            })
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        setContentInset()
    }
    
    private func setZoomScales() {
        let boundsSize = scrollView.bounds.size
        let imageSize = imageView.bounds.size
        
        let xScale = boundsSize.width / imageSize.width
        let yScale = boundsSize.height / imageSize.height
        let minScale = min(xScale, yScale)
        
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
        scrollView.maximumZoomScale = 3.0
    }
    
    private func setContentInset() {
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }
}
