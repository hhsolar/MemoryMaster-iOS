//
//  ReciteViewController.swift
//  MemoryMaster
//
//  Created by apple on 1/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit

class ReciteViewController: UIViewController {

    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    private func setupUI() {
        indexLabel.textColor = CustomColor.medianBlue
        indexLabel.font = UIFont(name: CustomFont.navigationSideFontName, size: CustomFont.navigationSideFontSize)
        
        continueButton.backgroundColor = CustomColor.medianBlue
        continueButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 16)
        continueButton.setTitleColor(UIColor.white, for: .normal)
        continueButton.layer.cornerRadius = 14
        continueButton.layer.masksToBounds = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        
        let nib = UINib(nibName: "CircularCollectionViewCell", bundle: Bundle.main)
        collectionView.register(nib, forCellWithReuseIdentifier: "CircularCollectionViewCell")
    }
    
    @IBAction func toFirstCard(_ sender: UIButton) {
    }
    
    @IBAction func toLastCard(_ sender: UIButton) {
    }
}

extension ReciteViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 50
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CircularCollectionViewCell", for: indexPath)
        return cell
    }
}
