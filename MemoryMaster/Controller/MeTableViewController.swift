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
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.borderWidth = 1
        avatarImageView.layer.borderColor = CustomColor.weakGray.cgColor
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let theImage = portraitPhotoImage {
            avatarImageView.image = theImage
        } else {
            avatarImageView.image = UIImage(named: "avatar")
        }
        
        let userDefault = UserDefaults.standard
        if let personInfo = userDefault.dictionary(forKey: UserDefaultsKeys.personInfo) {
            let nickname = personInfo[UserDefaultsDictKey.nickname] as? String
            if let nickname = nickname, nickname != "" {
                nicknameLabel.text = nickname
            } else {
                nicknameLabel.text = "Nickname"
            }
        }
    }
    
    @IBAction func shouldSoundOpened(_ sender: UISwitch) {
    }
}

extension MeTableViewController
{
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch (indexPath.section, indexPath.row) {
        case (1, 0):
            let controller = BookmarkTableViewController.init(nibName: "BookmarkTableViewController", bundle: nil)
            controller.hidesBottomBarWhenPushed = true
            controller.tabBarController?.tabBar.isHidden = true
            controller.title = "Bookmark"
            self.navigationController?.pushViewController(controller, animated: true)
        default:
            break
        }
    }
    
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
