//
//  ReadNoteViewController.swift
//  MemoryMaster
//
//  Created by apple on 11/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit

class ReadNoteViewController: BaseTopViewController {

    // public api
    var passedInNoteInfo: MyBasicNoteInfo?
    var passedInNotes = [CardContent]()
    var startCardIndexPath: IndexPath?
    
    @IBOutlet weak var progressBarView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    let barFinishedPart = UIView()
    
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

    override func setupUI() {
        super.setupUI()
        super.titleLabel.text = passedInNoteInfo?.name
        self.automaticallyAdjustsScrollViewInsets = false

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
        collectionView?.isPagingEnabled = true
        collectionView?.showsHorizontalScrollIndicator = false
        
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize(width: (collectionView?.bounds.width)!, height: (collectionView?.bounds.height)!)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        collectionView.collectionViewLayout = layout
        
        let nib = UINib(nibName: "ReadCollectionViewCell", bundle: Bundle.main)
        collectionView?.register(nib, forCellWithReuseIdentifier: "ReadCollectionViewCell")
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
