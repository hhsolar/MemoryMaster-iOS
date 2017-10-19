//
//  ReadNoteViewController.swift
//  MemoryMaster
//
//  Created by apple on 11/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit
import CoreData

class ReadNoteViewController: BaseTopViewController {

    // public api
    var passedInNoteInfo: MyBasicNoteInfo?
    var passedInNotes = [CardContent]()
    var startCardIndexPath: IndexPath?
    
    @IBOutlet weak var progressBarView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    let barFinishedPart = UIView()
    let addBookmarkButton = UIButton()
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.setNeedsLayout()
        if let indexPath = startCardIndexPath {
            collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let currentIndex = Int(collectionView.contentOffset.x) / Int(collectionView.bounds.width)
        
        let userDefault = UserDefaults.standard
        if var dict = userDefault.dictionary(forKey: "lastStatus") {
            dict.updateValue((passedInNoteInfo?.id)!, forKey: "id")
            dict.updateValue(currentIndex, forKey: "index")
            dict.updateValue(ReadType.read.rawValue, forKey: "readType")
            dict.updateValue("", forKey: "cardStatus")
            userDefault.set(dict, forKey: "lastStatus")
        } else {
            let statusDict: [String : Any] = ["id": (passedInNoteInfo?.id)!, "index": currentIndex, "readType": ReadType.read.rawValue, "cardStatus": ""]
            userDefault.set(statusDict, forKey: "lastStatus")
        }
    }
    
    override func setupUI() {
        super.setupUI()
        super.titleLabel.text = passedInNoteInfo?.name
        self.automaticallyAdjustsScrollViewInsets = false
        
        addBookmarkButton.frame = CGRect(x: topView.bounds.width - CustomSize.smallBtnHeight - CustomDistance.viewToScreenEdgeDistance,
                                         y: CustomSize.statusBarHeight + (CustomSize.barHeight - CustomSize.smallBtnHeight) / 2,
                                         width: CustomSize.smallBtnHeight, height: CustomSize.smallBtnHeight)
        addBookmarkButton.setImage(UIImage.init(named: "bookMark_icon"), for: .normal)
        addBookmarkButton.addTarget(self, action: #selector(addBookmark), for: .touchUpInside)
        
        progressBarView.layer.cornerRadius = 4
        progressBarView.layer.masksToBounds = true
        progressBarView.layer.borderWidth = 1
        progressBarView.layer.borderColor = CustomColor.medianBlue.cgColor
        progressBarView.backgroundColor = UIColor.white
        
        barFinishedPart.backgroundColor = CustomColor.medianBlue
        let startIndex = startCardIndexPath?.row ?? 0
        let barFinishedPartWidth = progressBarView.bounds.width / CGFloat(passedInNotes.count) * CGFloat(startIndex + 1)
        barFinishedPart.frame = CGRect(x: 0, y: 0, width: barFinishedPartWidth, height: progressBarView.bounds.height)
        progressBarView.addSubview(barFinishedPart)
        
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
        
        let nib = UINib(nibName: "ReadCollectionViewCell", bundle: Bundle.main)
        collectionView?.register(nib, forCellWithReuseIdentifier: "ReadCollectionViewCell")
    }
    
    @objc func addBookmark() {
        let currentIndex = Int(collectionView.contentOffset.x) / Int(collectionView.bounds.width)
        
        let placeholder = String(format: "%@-%@-%@-%d", (passedInNoteInfo?.name)!, (passedInNoteInfo?.type)!, ReadType.read.rawValue, currentIndex + 1)

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
                let bookmark = MyBookmark(name: text, id: (self?.passedInNoteInfo?.id)!, time: Date(), readType: ReadType.read.rawValue, readPage: currentIndex, readPageStatus: nil)
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
    
    // MARK: draw prograss bar
    private func updatePrograssLing(readingIndex: CGFloat) {
        let width = progressBarView.bounds.width * (readingIndex + 1) / CGFloat(passedInNotes.count)
        UIView.animate(withDuration: 0.4, delay: 0.1, options: [], animations: {
            self.barFinishedPart.frame.size.width = width
        }, completion: nil)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentIndex = collectionView.indexPathsForVisibleItems[0].row
        updatePrograssLing(readingIndex: CGFloat(currentIndex))
    }
}

extension ReadNoteViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return passedInNotes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReadCollectionViewCell", for: indexPath) as! ReadCollectionViewCell
        cell.updateUI(noteType: (passedInNoteInfo?.type)!, title: passedInNotes[indexPath.row].title, body: passedInNotes[indexPath.row].body, index: indexPath.row + 1)
        return cell
    }
}
