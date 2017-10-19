//
//  BookMark+CoreDataProperties.swift
//  MemoryMaster
//
//  Created by apple on 17/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//
//

import Foundation
import CoreData


extension BookMark {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookMark> {
        return NSFetchRequest<BookMark>(entityName: "BookMark")
    }

    @NSManaged public var name: String
    @NSManaged public var id: Int32
    @NSManaged public var time: NSDate
    @NSManaged public var readType: String
    @NSManaged public var readPage: Int32
    @NSManaged public var readPageStatus: String?

}
