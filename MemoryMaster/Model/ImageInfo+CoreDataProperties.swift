//
//  ImageInfo+CoreDataProperties.swift
//  MemoryMaster
//
//  Created by apple on 9/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//
//

import Foundation
import CoreData


extension ImageInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageInfo> {
        return NSFetchRequest<ImageInfo>(entityName: "ImageInfo")
    }

    @NSManaged public var imageIndex: Int32
    @NSManaged public var imagePlaceIndex: Int16

}
