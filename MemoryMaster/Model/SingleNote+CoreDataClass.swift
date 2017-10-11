//
//  SingleNote+CoreDataClass.swift
//  
//
//  Created by apple on 1/10/2017.
//
//

import Foundation
import CoreData

public class SingleNote: NSManagedObject
{
    class func findOrCreateNote(matching noteInfo: MyBasicNoteInfo, in context: NSManagedObjectContext) throws -> SingleNote
    {
        let request: NSFetchRequest<SingleNote> = SingleNote.fetchRequest()
        request.predicate = NSPredicate(format: "name = %@", noteInfo.name)
        
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count == 1, "SingleNote.findeOrCreateNote -- database inconsistency")
                return matches[0]
            }
        } catch {
            throw error
        }
        
        let singleNote = SingleNote(context: context)
        singleNote.name = noteInfo.name
        singleNote.numberOfCard = Int32(noteInfo.numberOfCard)
        
        singleNote.titles.append("")
        singleNote.bodies.append("")
        return singleNote
    }
}
