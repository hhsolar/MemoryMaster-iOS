//
//  LibraryViewController.swift
//  MemoryMaster
//
//  Created by apple on 1/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit
import CoreData

class LibraryViewController: UIViewController {

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var allNoteButton: UIButton!
    @IBOutlet weak var qaNoteButton: UIButton!
    @IBOutlet weak var singleNoteButton: UIButton!
    @IBOutlet weak var noteSearchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.separatorStyle = .none
        }
    }
    
    // public api
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    var fetchedResultsController: NSFetchedResultsController<BasicNoteInfo>?
    var lastType = ""
    var selectedCellIndex: IndexPath?
    var showFlag: NoteType = .all
    
    func updateUI() {
        if let context = container?.viewContext {
            let request: NSFetchRequest<BasicNoteInfo> = BasicNoteInfo.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(
                key: "name",
                ascending: true,
                selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
            )]
            if showFlag == .single {
                request.predicate = NSPredicate(format: "type == %@", NoteType.single.rawValue)
            } else if showFlag == .qa {
                request.predicate = NSPredicate(format: "type == %@", NoteType.qa.rawValue)
            }
            fetchedResultsController = NSFetchedResultsController<BasicNoteInfo>(
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
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        updateUI()
    }
    
    @IBAction func showAllNote(_ sender: UIButton) {
        showFlag = .all
        allNoteButton.setImage(UIImage(named: "all_icon_click.png"), for: .normal)
        qaNoteButton.setImage(UIImage(named: "qa_icon_unclick.png"), for: .normal)
        singleNoteButton.setImage(UIImage(named: "single_icon_unclick.png"), for: .normal)
        updateUI()
    }
    
    @IBAction func showQANote(_ sender: UIButton) {
        showFlag = .qa
        allNoteButton.setImage(UIImage(named: "all_icon_unclick.png"), for: .normal)
        qaNoteButton.setImage(UIImage(named: "qa_icon_click.png"), for: .normal)
        singleNoteButton.setImage(UIImage(named: "single_icon_unclick.png"), for: .normal)
        updateUI()
    }
    
    @IBAction func showSingleNote(_ sender: UIButton) {
        showFlag = .single
        allNoteButton.setImage(UIImage(named: "all_icon_unclick.png"), for: .normal)
        qaNoteButton.setImage(UIImage(named: "qa_icon_unclick.png"), for: .normal)
        singleNoteButton.setImage(UIImage(named: "single_icon_click.png"), for: .normal)
        updateUI()
    }
    
    private func setupUI()
    {
        // remove black border line
        noteSearchBar.isTranslucent = false
        noteSearchBar.backgroundImage = UIImage()
        
        // set background color
        noteSearchBar.barTintColor = CustomColor.deepBlue
        
        let searchField = noteSearchBar.value(forKey: "searchField") as? UITextField
        searchField?.layer.cornerRadius = 14
        searchField?.layer.masksToBounds = true
        
        allNoteButton.setImage(UIImage(named: "all_icon_click.png"), for: .normal)
        singleNoteButton.setImage(UIImage(named: "single_icon_unclick.png"), for: .normal)
        qaNoteButton.setImage(UIImage(named: "qa_icon_unclick.png"), for: .normal)
        
        addButton.tintColor = UIColor.white
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        let nib = UINib(nibName: "LibraryTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "LibraryTableViewCell")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToNoteViewController" {
            let controller = segue.destination as! NoteViewController
            controller.container = self.container
            if let card = fetchedResultsController?.object(at: selectedCellIndex!) {
                let passCard = MyBasicNoteInfo(id: Int(card.id), time: card.createTime as Date, type: card.type, name: card.name, numberOfCard: Int(card.numberOfCard))
                controller.passedInNodeInfo = passCard
                controller.container = container
            }
        }
    }
}

extension LibraryViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LibraryTableViewCell", for: indexPath) as! LibraryTableViewCell
        if let card = fetchedResultsController?.object(at: indexPath) {
            cell.awakeFromNib()
            cell.updateCell(with: card, lastCardType: lastType)
            lastType = card.type
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCellIndex = indexPath
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ToNoteViewController", sender: indexPath)
    }
}

extension LibraryViewController: NSFetchedResultsControllerDelegate {
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
