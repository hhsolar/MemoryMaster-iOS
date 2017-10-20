//
//  MeTableViewController.swift
//  MemoryMaster
//
//  Created by apple on 19/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit

class MeTableViewController: UITableViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var soundSwitch: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func shouldSoundOpened(_ sender: UISwitch) {
    }
}

extension MeTableViewController
{
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 1
        case 3:
            return 60
        default:
            return 20
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
}
