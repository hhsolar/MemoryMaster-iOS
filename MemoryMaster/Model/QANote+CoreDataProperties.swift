//
//  QANote+CoreDataProperties.swift
//  
//
//  Created by apple on 1/10/2017.
//
//

import Foundation
import CoreData


extension QANote {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<QANote> {
        return NSFetchRequest<QANote>(entityName: "QANote")
    }

    @NSManaged public var name: String
    @NSManaged public var numberOfCard: Int32
    @NSManaged public var questions: [String]
    @NSManaged public var answers: [String]

}
