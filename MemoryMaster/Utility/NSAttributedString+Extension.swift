//
//  NSAttributedString+Extension.swift
//  MemoryMaster
//
//  Created by apple on 10/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import Foundation

extension NSAttributedString {
    class func getTextFromFile(with noteName: String, at index: Int, in noteType: String, contentType: String) -> NSAttributedString {
        let fileName = "\(noteType)-\(noteName)-\(index)-\(contentType)"
        let url = applicationDocumentsDirectory.appendingPathComponent(fileName)
        let data = try? Data(contentsOf: url)
        if let data = data {
            let att = try? NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtfd], documentAttributes: nil)
            if let att = att {
                return att
            }
        }
        return NSAttributedString.init()
    }
    
    func saveTextToFile(with noteName: String, at index: Int, in noteType: String, contentType: String) {
        let data = try? self.data(from: NSRange(location: 0, length: self.length), documentAttributes: [NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.rtfd])
        let fileName = "\(noteType)-\(noteName)-\(index)-\(contentType)"
        let url = applicationDocumentsDirectory.appendingPathComponent(fileName)
        do {
            try data?.write(to: url, options: .atomic)
        } catch {
            print("Error writing file: \(error)")
        }
    }
    
    class func prepareAttributeStringForRead(noteType: String, title: NSAttributedString, body: NSAttributedString, index: Int) -> NSAttributedString {
        let showString = NSMutableAttributedString(string: String(format: "%d. ", index + 1))
        if title == NSAttributedString() {
            showString.append(body)
            showString.addAttributes(CustomRichTextAttri.bodyNormal, range: NSRange.init(location: 0, length: showString.length))
        } else {
            showString.append(title)
            showString.addAttributes(CustomRichTextAttri.titleNormal, range: NSRange.init(location: 0, length: showString.length))
            let returnAtt = NSAttributedString(string: "\n\n")
            showString.append(returnAtt)
            let location = showString.length
            showString.append(body)
            showString.addAttributes(CustomRichTextAttri.bodyNormal, range: NSRange.init(location: location, length: body.length))
        }
        return showString as NSAttributedString
    }
    
    func addAttributesForText(_ attrs: [NSAttributedStringKey : Any] = [:], range: NSRange) -> NSAttributedString {
        let string = NSMutableAttributedString(attributedString: self)
        string.addAttributes(attrs, range: range)
        return string as NSAttributedString
    }
    
    // change NSAttributeString's attachment image to fit the constrain width of the container
    func changeAttachmentImageToFitContainer(containerWidth: CGFloat, in range: NSRange) -> NSAttributedString
    {
        let imageInfo = self.getAllImageAttachments(in: range)
        let mutableAttri = NSMutableAttributedString.init(attributedString: self)
        for i in 0..<imageInfo.imageArray.count {
            let imgTextAttach = NSTextAttachment()
            imgTextAttach.image = UIImage.scaleImageToFitTextView(imageInfo.imageArray[i], fit: containerWidth)!
            let imageAttach = NSAttributedString.init(attachment: imgTextAttach)
            mutableAttri.replaceCharacters(in: imageInfo.rangeArray[i], with: imageAttach)
        }
        return mutableAttri as NSAttributedString
    }
    
    func getAllImageAttachments(in range: NSRange) -> ImageAttachmentsInfo {
        var imageInfo = ImageAttachmentsInfo(imageArray: [], rangeArray: [])
        self.enumerateAttribute(NSAttributedStringKey.attachment, in: range, options: [], using: { (value, range, stop) in
            if value is NSTextAttachment {
                let attachment = value as? NSTextAttachment
                var image: UIImage? = nil
                
                if attachment?.image != nil {
                    image = attachment?.image
                } else {
                    image = attachment?.image(forBounds: (attachment?.bounds)!, textContainer: nil, characterIndex: range.location)
                }
                
                if image != nil {
                    imageInfo.imageArray.append(image!)
                    imageInfo.rangeArray.append(range)
                }
            }
        })
        return imageInfo
    }
    
    struct ImageAttachmentsInfo {
        var imageArray: [UIImage]
        var rangeArray: [NSRange]
    }
}


