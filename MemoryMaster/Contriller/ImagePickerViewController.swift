//
//  ImagePickerViewController.swift
//  MemoryMaster
//
//  Created by apple on 8/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit
import Photos
import SVProgressHUD

class ImagePickerViewController: BaseTopViewController, UICollectionViewDelegateFlowLayout {

    // public api
    var lastController: NoteEditViewController?
    var smallPhotoArray = [UIImage]()
    var photoAsset = [PHAsset]()
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getPhotoData()
    }
    
    override func setupUI() {
        super.setupUI()
        super.titleLabel.text = "All Photos"
        let nib = UINib(nibName: "ImagePickerCollectionViewCell", bundle: Bundle.main)
        photoCollectionView.register(nib, forCellWithReuseIdentifier: "ImagePickerCollectionViewCell")

        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.width - 20) / 3, height: (UIScreen.main.bounds.width - 20) / 3)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 0
        photoCollectionView.collectionViewLayout = layout
        photoCollectionView.backgroundColor = UIColor.white
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(5, 5, 5, 5)
    }
    
    private func getPhotoData() {
        photoAsset = UIImage.getPhotoAssets()
        SVProgressHUD.show()
        UIImage.async_getLibraryThumbnails { [weak self] (allSmallImageArray) in
            self?.smallPhotoArray.append(contentsOf: allSmallImageArray)
            SVProgressHUD.dismiss()
            self?.photoCollectionView.reloadData()
            self?.photoCollectionView.scrollToItem(at: IndexPath(item: (self?.smallPhotoArray.count )! - 1, section: 0), at: .top, animated: false)
        }
    }
}

extension ImagePickerViewController: UICollectionViewDelegate, UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return smallPhotoArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagePickerCollectionViewCell", for: indexPath) as! ImagePickerCollectionViewCell
        cell.photoImageView.image = smallPhotoArray[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = UIImage.getOriginalPhoto(asset: photoAsset[indexPath.row])
        let controller = TOCropViewController.init(image: image)
        controller.delegate = self.lastController
        dismiss(animated: true) {
            self.lastController?.present(controller, animated: true, completion: nil)
        }
    }
}
