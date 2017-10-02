//
//  SingleNote+CoreDataProperties.swift
//  
//
//  Created by apple on 1/10/2017.
//
//

import Foundation
import CoreData


extension SingleNote {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SingleNote> {
        return NSFetchRequest<SingleNote>(entityName: "SingleNote")
    }

    @NSManaged public var name: String
    @NSManaged public var numberOfCard: Int32
    @NSManaged public var titles: [String]
    @NSManaged public var bodies: [String]

}
