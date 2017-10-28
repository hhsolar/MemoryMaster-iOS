//
//  EnlargeImageViewController.swift
//  MemoryMaster
//
//  Created by apple on 27/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit

class EnlargeImageViewController: BaseTopViewController {

    var scrollView: UIScrollView!
    var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension EnlargeImageViewController: EnlargeImageCellDelegate, UIScrollViewDelegate
{
    func enlargeTapedImage(image: UIImage)
    {
        let xScale = UIScreen.main.bounds.width / image.size.width
        let yScale = UIScreen.main.bounds.height / image.size.height
        let scale = min(xScale, yScale)
        
        let newImage = UIImage.scaleImage(image, to: scale)
        imageView = UIImageView(image: newImage)
        
        setupScrollView()
        
        setZoomScales()
        setContentInset()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissImage))
        tapRecognizer.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(tapRecognizer)
        
        UIView.animate(withDuration: 0.3, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.scrollView.alpha = 1.0
        }, completion: nil)
    }
    
    private func setupScrollView() {
        scrollView = UIScrollView(frame: UIScreen.main.bounds)
        scrollView.backgroundColor = UIColor.black
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentSize = imageView.bounds.size
        scrollView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        
        view.addSubview(scrollView)
        view.bringSubview(toFront: scrollView)
        scrollView.addSubview(imageView)
        scrollView.alpha = 0.0
        
        scrollView.delegate = self
    }
    
    @objc func dismissImage(byReactingTo tapRecognizer: UITapGestureRecognizer) {
        if tapRecognizer.state == .ended {
            UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseOut, animations: {
                self.scrollView.alpha = 0.0
            }, completion: { finish in
                self.scrollView.removeFromSuperview()
                self.imageView = nil
                self.scrollView = nil
            })
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        setContentInset()
    }
    
    private func setZoomScales() {
        let boundsSize = scrollView.bounds.size
        let imageSize = imageView.bounds.size
        
        let xScale = boundsSize.width / imageSize.width
        let yScale = boundsSize.height / imageSize.height
        let minScale = min(xScale, yScale)
        
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
        scrollView.maximumZoomScale = 3.0
    }
    
    private func setContentInset() {
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }
}
