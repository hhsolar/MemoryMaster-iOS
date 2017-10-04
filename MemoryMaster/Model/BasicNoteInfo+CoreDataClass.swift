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
    
    class func findOrCreate(matching noteInfo: MyBasicNoteInfo, in context: NSManagedObjectContext) throws -> BasicNoteInfo {
        let request: NSFetchRequest<BasicNoteInfo> = BasicNoteInfo.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@ && type == %@", noteInfo.name, noteInfo.type)
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                matches[0].numberOfCard = Int32(noteInfo.numberOfCard)
                return matches[0]
            }
        } catch {
            throw error
        }
        
        let basicNote = BasicNoteInfo(context: context)
        basicNote.id = Int32(noteInfo.id)
        basicNote.name = noteInfo.name
        basicNote.type = noteInfo.type
        basicNote.createTime = noteInfo.time as NSDate
        basicNote.numberOfCard = Int32(noteInfo.numberOfCard)
        return basicNote
    }
}
