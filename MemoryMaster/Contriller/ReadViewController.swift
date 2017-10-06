//
//  ReadViewController.swift
//  MemoryMaster
//
//  Created by apple on 3/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit

class ReadViewController: UIViewController {

    // public api
    var passedInSingleNote: SingleNote?
    var passedInQANote: QANote?
    var startCardIndexPath: IndexPath?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var progressBarView: UIView!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView?.isPagingEnabled = true
            collectionView?.showsHorizontalScrollIndicator = false
        }
    }
    let barFinishedPart = UIView()
    
    fileprivate var numberOfCards: Int {
        get {
            if let note = passedInSingleNote {
                return Int(note.numberOfCard)
            } else if let note = passedInQANote {
                return Int(note.numberOfCard)
            }
            return 0
        }
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    private func setupUI() {
        progressBarView.layer.cornerRadius = 4
        progressBarView.layer.masksToBounds = true
        progressBarView.layer.borderWidth = 1
        progressBarView.layer.borderColor = CustomColor.medianBlue.cgColor
        progressBarView.backgroundColor = UIColor.white
        
        barFinishedPart.backgroundColor = CustomColor.medianBlue
        let startIndex = startCardIndexPath?.row ?? 0
        let barFinishedPartWidth = progressBarView.bounds.width / CGFloat(numberOfCards) * CGFloat(startIndex + 1)
        barFinishedPart.frame = CGRect(x: 0, y: 0, width: barFinishedPartWidth, height: progressBarView.bounds.height)
        progressBarView.addSubview(barFinishedPart)
        
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize(width: (collectionView?.bounds.width)!, height: (collectionView?.bounds.height)!)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        collectionView.collectionViewLayout = layout
        
        if let note = passedInSingleNote {
            titleLabel.text = note.name
        }

        if let note = passedInQANote {
            titleLabel.text = note.name
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        setupUI()
        
        let nib = UINib(nibName: "ReadCollectionViewCell", bundle: Bundle.main)
        collectionView?.register(nib, forCellWithReuseIdentifier: "ReadCollectionViewCell")
    }

    override func viewDidLayoutSubviews() {
        super .viewDidLayoutSubviews()
        if let indexPath = startCardIndexPath {
            collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
        }
    }
        
    // MARK: draw prograss bar
    private func updatePrograssLing(readingIndex: CGFloat) {
        let width = progressBarView.bounds.width * (readingIndex + 1) / CGFloat(numberOfCards)
        barFinishedPart.frame = CGRect(x: 0, y: 0, width: width, height: progressBarView.bounds.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentIndex = collectionView.indexPathsForVisibleItems[0].row
        updatePrograssLing(readingIndex: CGFloat(currentIndex))
    }
}

extension ReadViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfCards
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReadCollectionViewCell", for: indexPath) as! ReadCollectionViewCell
        if let note = passedInSingleNote {
            cell.updateUI(title: note.titles[indexPath.row], body: note.bodies[indexPath.row], index: indexPath.row + 1)
        }
        if let note = passedInQANote {
            cell.updateUI(title: note.questions[indexPath.row], body: note.answers[indexPath.row], index: indexPath.row + 1)
        }
        return cell
    }
}
