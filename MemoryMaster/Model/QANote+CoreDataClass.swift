//
//  QANote+CoreDataClass.swift
//  
//
//  Created by apple on 1/10/2017.
//
//

import Foundation
import CoreData


public class QANote: NSManagedObject
{
    class func findOrCreateNote(matching noteInfo: MyBasicNoteInfo, in context: NSManagedObjectContext) throws -> QANote
    {
        let request: NSFetchRequest<QANote> = QANote.fetchRequest()
        request.predicate = NSPredicate(format: "name = %@", noteInfo.name)
        
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count == 1, "QANote.findeOrCreateNote -- database inconsistency")
                return matches[0]
            }
        } catch {
            throw error
        }
        
        let qaNote = QANote(context: context)
        qaNote.name = noteInfo.name
        qaNote.numberOfCard = Int32(noteInfo.numberOfCard)
        qaNote.questions.append("")
        qaNote.answers.append("")
        return qaNote
    }
}
