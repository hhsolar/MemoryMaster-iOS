//
//  UIImage+Extension.swift
//  MemoryMaster
//
//  Created by apple on 8/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import Foundation
import UIKit
import Photos

extension UIImage {
    
    class func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    class func scaleImage(_ image: UIImage, to scaleSize: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContext(CGSize(width: image.size.width * scaleSize, height: image.size.height * scaleSize))
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width * scaleSize, height: image.size.height * scaleSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
    
    class func reSizeImage(_ image: UIImage, to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(CGSize(width: size.width, height: size.height))
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let reSizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return reSizeImage
    }
    
    // make the photo to fit the UITextView size
    class func scaleImageToFitTextView(_ image: UIImage, fit textViewWidth: CGFloat) -> UIImage? {
        if image.size.width <= textViewWidth {
            return image
        }
        let size = CGSize(width: textViewWidth, height: textViewWidth * image.size.height / image.size.width)
        return UIImage.reSizeImage(image, to: size)
    }
    
    // save photo to the library
    class func saveImageWithPhotoLibrary(image: UIImage) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { (success, error) in
            if success {
                print("success = %d, error = %@", success, error!)
            }
        }
    }
    
    // async get the photos form library with small size
    class func async_getLibraryThumbnails(smallImageCallBack: @escaping (_ allSmallImageArray: [UIImage]) -> ()) {
        let image = UIImage()
        let concurrentQueue = DispatchQueue(label: "getLibiaryAllImage-queue", attributes: .concurrent)
        concurrentQueue.async {
            var smallPhotoArray = [UIImage]()
            smallPhotoArray.append(contentsOf: UIImage.getImageWithScaleImage(image: image, isOriginalPhoto: false))
            DispatchQueue.main.async {
                smallImageCallBack(smallPhotoArray)
            }
        }
    }
    
    // async to get the photos form library with small size and original size at same time
    class func async_getLibraryPhoto(smallImageCallBack: @escaping (_ allSmallImageArray: [UIImage]) -> (), allOriginalImageCallBack: @escaping (_ allOriginalImageArray: [UIImage]) -> ()) {
        let image = UIImage()
        let concurrentQueue = DispatchQueue(label: "getLibiaryAllImage-queue", attributes: .concurrent)
        concurrentQueue.async {
            var smallPhotoArray = [UIImage]()
            smallPhotoArray.append(contentsOf: UIImage.getImageWithScaleImage(image: image, isOriginalPhoto: false))
            DispatchQueue.main.async {
                smallImageCallBack(smallPhotoArray)
            }
        }
        concurrentQueue.async {
            var allOriginalPhotoArray = [UIImage]()
            allOriginalPhotoArray.append(contentsOf: UIImage.getImageWithScaleImage(image: image, isOriginalPhoto: true))
            DispatchQueue.main.async {
                allOriginalImageCallBack(allOriginalPhotoArray)
            }
        }
    }
    
    // get all the photoes with original size or not
    class func getImageWithScaleImage(image: UIImage, isOriginalPhoto: Bool) -> [UIImage] {
        var photoArray = [UIImage]()
        let assetCollections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        for i in 0..<assetCollections.count {
            photoArray.append(contentsOf: image.enumerateAssetsInAssetCollection(assetCollection: assetCollections[i], origial: isOriginalPhoto))
        }
        let cameraRoll = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil).lastObject
        if let cameraRoll = cameraRoll {
            photoArray.append(contentsOf: image.enumerateAssetsInAssetCollection(assetCollection: cameraRoll, origial: isOriginalPhoto))
        }
        return photoArray
    }
    
    // get photos form a assection collection
    func enumerateAssetsInAssetCollection(assetCollection: PHAssetCollection, origial: Bool) -> [UIImage] {
        var array = [UIImage]()
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        let scale = UIScreen.main.scale
        let width = (UIScreen.main.bounds.width - 20) / 3
        let thumbnailSize = CGSize(width: width * scale, height: width * scale)
        let assets = PHAsset.fetchAssets(in: assetCollection, options: nil)
        for i in 0..<assets.count {
            let size = origial ? CGSize(width: assets[i].pixelWidth, height:assets[i].pixelHeight) : thumbnailSize
            PHImageManager.default().requestImage(for: assets[i], targetSize: size, contentMode: .default, options: options, resultHandler: { (result, info) in
                array.append(result!)
            })
        }
        return array
    }
    
    //////////////////////////
    
    // load a group of thumbnails
    class func async_getLibraryThumbnails(assets: [PHAsset], smallImageCallBack: @escaping (_ allSmallImageArray: [UIImage]) -> ()) {
        let concurrentQueue = DispatchQueue(label: "getLibiaryAllImage-queue", attributes: .concurrent)
        concurrentQueue.async {
            var smallPhotoArray = [UIImage]()
            smallPhotoArray.append(contentsOf: getThumbnailsByPhotoAssectArray(assets: assets))
            DispatchQueue.main.async {
                smallImageCallBack(smallPhotoArray)
            }
        }
    }
    
    // get thumbnails according to array of photo assects
    class func getThumbnailsByPhotoAssectArray(assets: [PHAsset]) -> [UIImage] {
        var array = [UIImage]()
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        let scale = UIScreen.main.scale
        let width = (UIScreen.main.bounds.width - 20) / 3
        let thumbnailSize = CGSize(width: width * scale, height: width * scale)
        for assets in assets {
            PHImageManager.default().requestImage(for: assets, targetSize: thumbnailSize, contentMode: .default, options: options, resultHandler: { (result, info) in
                array.append(result!)
            })
        }
        return array
    }
 
    // get original size photo according to photo assect
    class func getOriginalPhoto(asset: PHAsset) -> UIImage {
        var image = UIImage()
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        let size = CGSize(width: asset.pixelWidth, height:asset.pixelHeight)
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .default, options: options) { (result, info) in
            image = result!
        }
        return image
    }
    
    // get photo asset from all of the albums
    class func getPhotoAssets() -> [PHAsset] {
        var array = [PHAsset]()
        let assetCollections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        for i in 0..<assetCollections.count {
            let assets = PHAsset.fetchAssets(in: assetCollections[i], options: nil)
            for j in 0..<assets.count {
                array.append(assets[j])
            }
        }
        let cameraRoll = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil).lastObject
        if let cameraRoll = cameraRoll {
            let rollAssets = PHAsset.fetchAssets(in: cameraRoll, options: nil)
            for i in 0..<rollAssets.count {
                array.append(rollAssets[i])
            }
        }
        return array
    }
}
