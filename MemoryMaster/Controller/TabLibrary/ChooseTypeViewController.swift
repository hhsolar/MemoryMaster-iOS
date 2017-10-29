//
//  ChooseTypeViewController.swift
//  MemoryMaster
//
//  Created by apple on 1/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit
import CoreData

class ChooseTypeViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var popView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var chooseNoteLabel: UILabel!
    @IBOutlet weak var singleCardButton: UIButton!
    @IBOutlet weak var qaCardButton: UIButton!
    
    // public api
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    fileprivate let playSound = SystemAudioPlayer()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    @IBAction func backAction(_ sender: UIButton)
    {
        playSound.playClickSound(SystemSound.buttonClick)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func toSingleNoteEditPage(_ sender: UIButton)
    {
        playSound.playClickSound(SystemSound.buttonClick)
        presentNoteEditController(noteType: NoteType.single)
    }
    
    @IBAction func toQANoteEditPage(_ sender: UIButton)
    {
        playSound.playClickSound(SystemSound.buttonClick)
        presentNoteEditController(noteType: NoteType.qa)
    }
    
    private func presentNoteEditController(noteType: NoteType) {
        if let name = nameTextField.text, name.characters.count > 0 {
            let context = container?.viewContext
            let isUesdName = BasicNoteInfo.isNoteExist(name: name, type: noteType.rawValue, in: context!)
            if isUesdName {
                showAlert(title: "Used Name!", message: "Please choose another name, or edit the exist note.")
                return
            }
            
            let noteInfo = MyBasicNoteInfo(id: MyBasicNoteInfo.nextNoteID(), time: Date(), type: noteType.rawValue, name: name, numberOfCard: 1)
            let controller = EditNoteViewController.init(nibName: "EditNoteViewController", bundle: nil)
            controller.passedInNoteInfo = noteInfo
            controller.container = self.container
            controller.isFirstTimeEdit = true
            present(controller, animated: true, completion: {
                self.view.alpha = 0
            })
            return
        }
        showAlert(title: "Error!", message: "Please give a name for the note.")
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
        nameTextField.delegate = self
        
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
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
