//
//  TestViewController.swift
//  MemoryMaster
//
//  Created by apple on 4/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    // public api
    var passedInQANote: QANote?
    var startCardIndexPath: IndexPath?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        setupUI()
        let nib = UINib(nibName: "TestCollectionViewCell", bundle: Bundle.main)
        collectionView?.register(nib, forCellWithReuseIdentifier: "TestCollectionViewCell")
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(flipCard))
        tapRecognizer.numberOfTapsRequired = 1
        collectionView.addGestureRecognizer(tapRecognizer)
    }

    override func viewDidLayoutSubviews() {
        super .viewDidLayoutSubviews()
        if let indexPath = startCardIndexPath {
            collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
        }
    }
    
    private func setupUI() {
        let index = startCardIndexPath?.row ?? 0
        let total = passedInQANote?.numberOfCard ?? 0
        titleLabel.text = String(format: "%d / %d", index + 1, total)
        titleLabel.textColor = CustomColor.deepBlue
        
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
    
    @IBAction func backAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension TestViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let note = passedInQANote {
            return Int(note.numberOfCard)
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TestCollectionViewCell", for: indexPath) as! TestCollectionViewCell
        if let note = passedInQANote {
            cell.cardIndex = indexPath.row
            cell.updateUI(question: note.questions[indexPath.row], answer: note.answers[indexPath.row])
        }
        return cell
    }
    
    // 该函数为了改变title的值，但程序运行后会crash，需要另外考虑办法
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let cells = collectionView.visibleCells
        if cells.count > 0 {
            let cell = collectionView.visibleCells[0] as! TestCollectionViewCell
            titleLabel.text = String(format: "%d / %d", cell.cardIndex! + 1, (passedInQANote?.numberOfCard)!)
        }
    }
}

