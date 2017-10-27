//
//  MyTextAttachment.swift
//  MemoryMaster
//
//  Created by apple on 26/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit

class MyTextAttachment: NSTextAttachment {
    override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect
    {
        guard let image = self.image else {
            return CGRect.zero
        }
        
        let width = lineFrag.size.width
        
        var scalingFactor = CGFloat(1)
        let imageSize = image.size
        if width < imageSize.width {
            scalingFactor = width / imageSize.width
        }
        return CGRect(x: 0, y: 0, width: imageSize.width * scalingFactor, height: imageSize.height * scalingFactor)
    }
}
