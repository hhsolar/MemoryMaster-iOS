//
//  NoteString+CoreDataProperties.swift
//  MemoryMaster
//
//  Created by apple on 9/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//
//

import Foundation
import CoreData


extension NoteString {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NoteString> {
        return NSFetchRequest<NoteString>(entityName: "NoteString")
    }

    @NSManaged public var imagesInfo: [ImageInfo]
    @NSManaged public var text: String

}
