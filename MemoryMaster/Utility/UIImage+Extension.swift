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
    
    class func scaleImageToFitTextView(_ image: UIImage, fit textViewWidth: CGFloat) -> UIImage? {
        if image.size.width <= textViewWidth {
            return image
        }
        UIGraphicsBeginImageContext(CGSize(width: textViewWidth, height: textViewWidth * image.size.height / image.size.width))
        image.draw(in: CGRect(x: 0, y: 0, width: textViewWidth, height: textViewWidth * image.size.height / image.size.width))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
    
    class func saveImageWithPhotoLibrary(image: UIImage) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { (success, error) in
            if success {
                print("success = %d, error = %@", success, error!)
            }
        }
    }
    
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
    
    class func getImageWithScaleImage(image: UIImage, isOriginalPhoto: Bool) -> [UIImage] {
        var photoArray = [UIImage]()
        let assetCollections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        for i in 0..<assetCollections.count {
            photoArray.append(contentsOf: image.enumerateAssetsInAssetCollection(assetCollection: assetCollections[i], origial: isOriginalPhoto))
        }
        let cameraRoll = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil).lastObject
        photoArray.append(contentsOf: image.enumerateAssetsInAssetCollection(assetCollection: cameraRoll!, origial: isOriginalPhoto))
        return photoArray
    }
    
    func enumerateAssetsInAssetCollection(assetCollection: PHAssetCollection, origial: Bool) -> [UIImage] {
        var array = [UIImage]()
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        let assets = PHAsset.fetchAssets(in: assetCollection, options: nil)
        for i in 0..<assets.count {
            let size = origial ? CGSize(width: assets[i].pixelWidth, height:assets[i].pixelHeight) : CGSize.zero
            PHImageManager.default().requestImage(for: assets[i], targetSize: size, contentMode: .default, options: options, resultHandler: { (result, info) in
                array.append(result!)
            })
        }
        return array
    }
    
    func beginClip() -> UIImage {
        let size = self.size
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        let path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        path.addClip()
        self.draw(at: CGPoint.zero)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
