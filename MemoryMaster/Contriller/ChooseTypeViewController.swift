//
//  ChooseTypeViewController.swift
//  MemoryMaster
//
//  Created by apple on 1/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit
import CoreData

class ChooseTypeViewController: UIViewController {

    @IBOutlet weak var popView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var chooseNoteLabel: UILabel!
    @IBOutlet weak var singleCardButton: UIButton!
    @IBOutlet weak var qaCardButton: UIButton!
    
    @IBAction func backAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func toSingleNoteEditPage(_ sender: UIButton) {
    }
    
    @IBAction func toQANoteEditPage(_ sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


}
