//
//  BasicNoteInfo+CoreDataClass.swift
//  
//
//  Created by apple on 1/10/2017.
//
//

import Foundation
import CoreData


public class BasicNoteInfo: NSManagedObject {

    class func isNoteExist(name: String, type: String, in context: NSManagedObjectContext) -> Bool
    {
        let request: NSFetchRequest<BasicNoteInfo> = BasicNoteInfo.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@ && type == %@", name, type)
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                return true
            }
        } catch {
            fatalError("BasicNoteInfo.isNoteExist -- database fetch error \(error)")
        }
        return false
    }
}
