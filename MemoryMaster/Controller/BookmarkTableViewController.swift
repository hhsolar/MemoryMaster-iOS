//
//  BookmarkTableViewController.swift
//  MemoryMaster
//
//  Created by apple on 20/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit
import CoreData

private let cellReuseIdentifier = "BookmarkTableViewCell"

class BookmarkTableViewController: UITableViewController {
    
    let nothingFoundLabel = UILabel()
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    var fetchedResultsController: NSFetchedResultsController<BookMark>?
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var noteInfo: MyBasicNoteInfo?
    var notes = [CardContent]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.extendedLayoutIncludesOpaqueBars = true

        nothingFoundLabel.frame = CGRect(x: 0, y: 44, width: UIScreen.main.bounds.width, height: 60)
        nothingFoundLabel.text = "Nothing Found"
        nothingFoundLabel.textColor = CustomColor.wordGray
        nothingFoundLabel.textAlignment = .center
        view.addSubview(nothingFoundLabel)
        
        tableView.rowHeight = 60
        let nib = UINib(nibName: cellReuseIdentifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellReuseIdentifier)
    
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        
        searchController.searchBar.isTranslucent = false
        searchController.searchBar.backgroundImage = UIImage()
        
        let searchField = searchController.searchBar.value(forKey: "searchField") as? UITextField
        searchField?.layer.cornerRadius = 14
        searchField?.layer.masksToBounds = true
        
        searchController.searchBar.delegate = self
        searchController.searchBar.tintColor = UIColor.white
        searchController.searchBar.barTintColor = CustomColor.deepBlue
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateData(searchKeyWord: nil)
    }
    
    deinit {
        self.searchController.view.removeFromSuperview()
    }
    
    func updateData(searchKeyWord: String?) {
        if let context = container?.viewContext {
            let request: NSFetchRequest<BookMark> = BookMark.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(
                key: "name",
                ascending: true,
                selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
                )]
            if let searchKeyWord = searchKeyWord, searchKeyWord != "" {
                request.predicate = NSPredicate(format: "name CONTAINS[c] %@", searchKeyWord)
            }
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

extension BookmarkTableViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        updateData(searchKeyWord: searchController.searchBar.text)
    }
}

extension BookmarkTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            if sections[section].numberOfObjects == 0 {
                nothingFoundLabel.isHidden = false
            } else {
                nothingFoundLabel.isHidden = true
            }
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! BookmarkTableViewCell
        let bookmark = (fetchedResultsController?.object(at: indexPath))!
        cell.nameLabel.text = bookmark.name
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        let dateString = dateFormatter.string(from: bookmark.time as Date)
        cell.timeLabel.text = dateString
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
            let controller = EditNoteViewController.init(nibName: "NoteEditViewController", bundle: nil)
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
