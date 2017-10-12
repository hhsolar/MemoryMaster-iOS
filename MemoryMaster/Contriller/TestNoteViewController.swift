//
//  TestNoteViewController.swift
//  MemoryMaster
//
//  Created by apple on 11/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit

class TestNoteViewController: BaseTopViewController {

    // public api
    var passedInNoteInfo: MyBasicNoteInfo?
    var passedInNotes = [CardContent]()
    var startCardIndexPath: IndexPath?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
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
    }
    
    override func setupUI() {
        super.setupUI()
        super.titleLabel.text = passedInNoteInfo?.name ?? "Name"
        
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
        
        let nib = UINib(nibName: "TestCollectionViewCell", bundle: Bundle.main)
        collectionView?.register(nib, forCellWithReuseIdentifier: "TestCollectionViewCell")
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
}

extension TestNoteViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return passedInNotes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TestCollectionViewCell", for: indexPath) as! TestCollectionViewCell
        cell.updateUI(question: passedInNotes[indexPath.row].title, answer: passedInNotes[indexPath.row].body, index: indexPath.row, total: passedInNotes.count)
        return cell
    }
}
