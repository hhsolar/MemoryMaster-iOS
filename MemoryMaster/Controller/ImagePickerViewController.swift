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
    var noteController: NoteEditViewController?
    var personController: PersonEditTableViewController?
    var smallPhotoArray = [UIImage]()
    var subPhotoArray = [UIImage]()
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
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector(("loadMorePhoto")), for: .valueChanged)
        photoCollectionView.addSubview(refreshControl)
    }
    
    func loadMorePhoto() {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(5, 5, 5, 5)
    }
    
    private func getPhotoData() {
        photoAsset = UIImage.getPhotoAssets()
        DispatchQueue.main.async {
            SVProgressHUD.show()
        }
        UIImage.async_getLibraryThumbnails { [weak self] (allSmallImageArray) in
            self?.smallPhotoArray.append(contentsOf: allSmallImageArray)
            SVProgressHUD.dismiss()
            self?.photoCollectionView.reloadData()
            self?.photoCollectionView.scrollToItem(at: IndexPath(item: (self?.smallPhotoArray.count )! - 1, section: 0), at: .top, animated: false)
        }
    }
    
    override func backAction() {
        super.backAction()
        SVProgressHUD.dismiss()
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
        if noteController != nil {
            let controller = TOCropViewController.init(image: image)
            controller.delegate = self.noteController
            dismiss(animated: true) {
                    self.noteController?.present(controller, animated: true, completion: nil)
            }
        } else if personController != nil {
            let controller = TOCropViewController.init(croppingStyle: .circular, image: image)
            controller.delegate = self.personController
            dismiss(animated: true) {
                self.personController?.present(controller, animated: true, completion: nil)
            }
        }
    }
}
