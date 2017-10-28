//
//  SettingsTableViewController.swift
//  MemoryMaster
//
//  Created by apple on 20/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit
import CoreData

class SettingsTableViewController: UITableViewController {

    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            showAlertWithAction(title: "Clear All Notes", message: "Do you really want to remove all notes?", hasNo: false, yesHandler: {
                [weak self] _ in self?.deleteAllNotes()
            }, noHandler: nil)
        case (0, 1):
            showAlertWithAction(title: "Clear All Bookmarks", message: "Do you really want to remove all bookmarks?", hasNo: false, yesHandler: {
                [weak self] _ in self?.deleteAllBookmarks()
            }, noHandler: nil)
        default:
            break
        }
    }
    
    private func deleteAllNotes() {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "BasicNoteInfo")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetch)
        let context: NSManagedObjectContext! = container?.viewContext
        do {
            try context.execute(deleteRequest)
        } catch {
            print("SettingTableViewController -- deleteAllNotes - error: \(error)")
        }
        deleteAllBookmarks()
    }
    
    private func deleteAllBookmarks() {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "BookMark")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetch)
        let context: NSManagedObjectContext! = container?.viewContext
        do {
            try context.execute(deleteRequest)
        } catch {
            print("SettingTableViewController -- deleteAllBookmarks - error: \(error)")
        }
    }
}
