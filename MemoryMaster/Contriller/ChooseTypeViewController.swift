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
    
    // public api
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    @IBAction func backAction(_ sender: UIButton)
    {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func toSingleNoteEditPage(_ sender: UIButton)
    {
        if let name = nameTextField.text, name.characters.count > 0 {
            let context = container?.viewContext
            let isUesdName = BasicNoteInfo.isNoteExist(name: name, type: NoteType.single.rawValue, in: context!)
            if isUesdName {
                showAlert(title: "Used Name!", message: "Please choose another name, or edit the exist note.")
            }
            
            let noteInfo = MyBasicNoteInfo(id: MyBasicNoteInfo.nextNoteID(), time: Date(), type: NoteType.single.rawValue, name: name, numberOfCard: 1)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "SingleEditViewController") as! SingleEditViewController
            controller.passedInNoteInfo = noteInfo
            controller.container = self.container
            present(controller, animated: true, completion: {
                self.view.alpha = 0
            })
            return
        }
        showAlert(title: "Error!", message: "Please give a name for the note.")
    }
    
    @IBAction func toQANoteEditPage(_ sender: UIButton) {
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI()
    {
        popView.layer.cornerRadius = 15
        popView.layer.masksToBounds = true
        
        nameLabel.textColor = CustomColor.wordGray
        
        nameTextField.placeholder = "Note name"
        nameTextField.clearButtonMode = UITextFieldViewMode.whileEditing
        nameTextField.layer.cornerRadius = 10
        nameTextField.layer.masksToBounds = true
        nameTextField.layer.borderWidth = 1
        nameTextField.layer.borderColor = UIColor.lightGray.cgColor
        nameTextField.becomeFirstResponder()
        
        // right move the cursor
        let leftView = UILabel.init(frame: CGRect(x: 5, y: 0, width: 10, height: 25))
        nameTextField.leftView = leftView
        nameTextField.leftViewMode = UITextFieldViewMode.always
        nameTextField.leftView?.backgroundColor = UIColor.clear
        
        chooseNoteLabel.textColor = CustomColor.wordGray
        
        singleCardButton.setTitleColor(UIColor.white, for: .normal)
        singleCardButton.backgroundColor = CustomColor.medianBlue
        singleCardButton.layer.cornerRadius = 10
        singleCardButton.layer.masksToBounds = true
        
        qaCardButton.backgroundColor = CustomColor.medianBlue
        qaCardButton.setTitleColor(UIColor.white, for: .normal)
        qaCardButton.layer.cornerRadius = 10
        qaCardButton.layer.masksToBounds = true
    }
}

extension ChooseTypeViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BounceAnimationController()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideOutAnimationController()
    }
}
