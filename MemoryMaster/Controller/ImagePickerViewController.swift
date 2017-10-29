//
//  ImagePickerViewController.swift
//  MemoryMaster
//
//  Created by apple on 8/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit
import Photos

private let oneTimeLoadPhotos: Int = 45

class ImagePickerViewController: BaseTopViewController, UICollectionViewDelegateFlowLayout {

    // public api
    var noteController: EditNoteViewController?
    var personController: PersonEditTableViewController?
    var smallPhotoArray = [UIImage]()
    var photoAsset = [PHAsset]()
    
    var loadImageIndex: Int?
    var unloadImageNumber: Int {
        return photoAsset.count - smallPhotoArray.count
    }
    
    let refreshControl = UIRefreshControl()
        
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
        
        refreshControl.addTarget(self, action: #selector(self.loadMorePhoto), for: .valueChanged)
        photoCollectionView.addSubview(refreshControl)
    }
    
    @objc func loadMorePhoto() {
        var upperIndex = 0
        var scrollIndex = loadImageIndex!
        if loadImageIndex! - (oneTimeLoadPhotos - 1) >= 0 {
            upperIndex = loadImageIndex! - (oneTimeLoadPhotos - 1)
            scrollIndex = oneTimeLoadPhotos - 1
        }
        let subAsset = Array(photoAsset[upperIndex...loadImageIndex!])
        UIImage.async_getLibraryThumbnails(assets: subAsset) { [weak self] (allSmallImageArray) in
            self?.smallPhotoArray.insert(contentsOf: allSmallImageArray, at: 0)
            DispatchQueue.main.async {
                self?.photoCollectionView.reloadData()
                self?.photoCollectionView.scrollToItem(at: IndexPath(item: scrollIndex, section: 0), at: .top, animated: false)
                self?.refreshControl.endRefreshing()
            }
        }
        loadImageIndex = upperIndex - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(5, 5, 5, 5)
    }
    
    private func getPhotoData() {
        photoAsset = UIImage.getPhotoAssets()
        loadImageIndex = photoAsset.count - 1
        loadMorePhoto()
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
        let image = UIImage.getOriginalPhoto(asset: photoAsset[unloadImageNumber + indexPath.row])
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
