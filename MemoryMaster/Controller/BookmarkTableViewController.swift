//
//  BookmarkTableViewController.swift
//  MemoryMaster
//
//  Created by apple on 20/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit
import CoreData

class BookmarkTableViewController: UITableViewController {
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    var fetchedResultsController: NSFetchedResultsController<BookMark>?
    
    var noteInfo: MyBasicNoteInfo?
    var notes = [CardContent]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 60
        let nib = UINib(nibName: "BookmarkTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "bookmarkCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    func updateUI() {
        if let context = container?.viewContext {
            let request: NSFetchRequest<BookMark> = BookMark.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(
                key: "name",
                ascending: true,
                selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
                )]
            fetchedResultsController = NSFetchedResultsController<BookMark>(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            fetchedResultsController?.delegate = self
            try? fetchedResultsController?.performFetch()
            tableView.reloadData()
        }
    }
}

extension BookmarkTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookmarkCell", for: indexPath) as! BookmarkTableViewCell
        if let bookmark = fetchedResultsController?.object(at: indexPath) {
            cell.nameLabel.text = bookmark.name
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            let dateString = dateFormatter.string(from: bookmark.time as Date)
            cell.timeLabel.text = dateString
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let bookmark: BookMark! = fetchedResultsController?.object(at: indexPath)
        let note = BasicNoteInfo.find(matching: bookmark.id, in: (container?.viewContext)!)
        noteInfo = MyBasicNoteInfo.convertToMyBasicNoteInfo(basicNoteInfo: note!)
        notes = [CardContent]()
        for i in 0..<(noteInfo?.numberOfCard)! {
            let cardContent = CardContent.getCardContent(with: (noteInfo?.name)!, at: i, in: (noteInfo?.type)!)
            notes.append(cardContent)
        }
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bookmark: BookMark! = fetchedResultsController?.object(at: indexPath)
        switch bookmark.readType {
        case ReadType.edit.rawValue:
            let controller = NoteEditViewController.init(nibName: "NoteEditViewController", bundle: nil)
            controller.passedInCardIndex = IndexPath(item: Int(bookmark.readPage), section: 0)
            controller.passedInCardStatus = bookmark.readPageStatus
            controller.passedInNoteInfo = noteInfo
            controller.container = container
            present(controller, animated: true, completion: nil)
        case ReadType.read.rawValue:
            let controller = ReadNoteViewController.init(nibName: "ReadNoteViewController", bundle: nil)
            controller.passedInNoteInfo = noteInfo
            controller.passedInNotes = notes
            controller.startCardIndexPath = IndexPath(item: Int(bookmark.readPage), section: 0)
            present(controller, animated: true, completion: nil)
        case ReadType.test.rawValue:
            let controller = TestNoteViewController.init(nibName: "TestNoteViewController", bundle: nil)
            controller.passedInNoteInfo = noteInfo
            controller.passedInNotes = notes
            controller.startCardIndexPath = IndexPath(item: Int(bookmark.readPage), section: 0)
            controller.passedInCardStatus = bookmark.readPageStatus
            present(controller, animated: true, completion: nil)
        default:
            break
        }
        notes.removeAll()
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let bookmark = fetchedResultsController?.object(at: indexPath)
            let context = container?.viewContext
            context?.delete(bookmark!)
            try? context?.save()
        }
    }
}

extension BookmarkTableViewController: NSFetchedResultsControllerDelegate {
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert: tableView.insertSections([sectionIndex], with: .fade)
        case .delete: tableView.deleteSections([sectionIndex], with: .fade)
        default: break
        }
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
