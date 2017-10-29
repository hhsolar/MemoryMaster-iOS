//
//  PersonEditTableViewController.swift
//  MemoryMaster
//
//  Created by apple on 19/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit
import Photos

class PersonEditTableViewController: UITableViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var nameTextView: UITextField!
    @IBOutlet weak var mottoTextView: UITextView!
    @IBOutlet weak var avatarButton: UIButton!
    
    var cellHeight: CGFloat = 120
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "My Profile"
        nameTextView.delegate = self
        mottoTextView.delegate = self
    
        avatarButton.layer.cornerRadius = avatarButton.bounds.width / 2
        avatarButton.layer.masksToBounds = true
        avatarButton.layer.borderWidth = 2
        avatarButton.layer.borderColor = CustomColor.weakGray.cgColor
        
        let userInfo = UserInfo.shared
        let image = userInfo.portraitPhotoImage ?? UIImage(named: "avatar")
        avatarButton.setImage(image, for: .normal)
        
        if userInfo.userName != "" {
            nameTextView.text = userInfo.userName
        } else {
            nameTextView.placeholder = "Nickname"
        }
        mottoTextView.text = userInfo.userMotto
        
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(returnKeyBoard))
        swipeRecognizer.direction = .down
        swipeRecognizer.numberOfTouchesRequired = 1
        tableView.addGestureRecognizer(swipeRecognizer)
        
        swipeRecognizer.delegate = self
    }
    
    private func saveImage(image: UIImage) {
        if let data = UIImageJPEGRepresentation(image, 0.5) {
            do {
                try data.write(to: UserInfo.shared.portraitPhotoURL, options: .atomic)
            } catch {
                print("Error writing file: \(error)")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let image = avatarButton.image(for: .normal)
        saveImage(image: image!)
        
        let userInfo = UserInfo.shared
        userInfo.userName = nameTextView.text ?? ""
        userInfo.userMotto = mottoTextView.text
    }
    
    @objc func returnKeyBoard(byReactionTo swipeRecognizer: UISwipeGestureRecognizer) {
        if swipeRecognizer.state == .ended {
            if mottoTextView.isFirstResponder {
                mottoTextView.resignFirstResponder()
            } else {
                nameTextView.resignFirstResponder()
            }
        }
    }

    @IBAction func editAvatar(_ sender: UIButton) {
        showPhotoMenu()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if mottoTextView.isFirstResponder || nameTextView.isFirstResponder {
            tableView.isScrollEnabled = false
            return true
        } else {
            tableView.isScrollEnabled = true
            return false
        }
    }
}

extension PersonEditTableViewController {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
}

extension PersonEditTableViewController: UITextViewDelegate, UITextFieldDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let textViewHeight = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat(MAXFLOAT))).height
        var frame = textView.frame
        let oldTextViewHeight = frame.size.height
        frame.size.height = textViewHeight
        textView.frame = frame
        cellHeight += (textViewHeight - oldTextViewHeight)
        if cellHeight < 120 {
            cellHeight = 120
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension PersonEditTableViewController: TOCropViewControllerDelegate {
    func cropViewController(_ cropViewController: TOCropViewController, didCropToImage image: UIImage, rect cropRect: CGRect, angle: Int)
    {
        avatarButton.setImage(image, for: .normal)
        cropViewController.dismiss(animated: true, completion: nil)
    }
}

extension PersonEditTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func showPhotoMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: { _ in self.takePhotoWithCamera() })
        alertController.addAction(takePhotoAction)
        let chooseFormLibraryAction = UIAlertAction(title: "Choose From Library", style: .default, handler: { _ in self.choosePhotoFromLibrary() })
        alertController.addAction(chooseFormLibraryAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func takePhotoWithCamera() {
        let oldStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        AVCaptureDevice.requestAccess(for: .video) { [weak self] isPermit in
            if isPermit {
                DispatchQueue.main.async {
                    let imagePicker = UIImagePickerController()
                    imagePicker.sourceType = .camera
                    imagePicker.delegate = self
                    imagePicker.allowsEditing = true
                    self?.present(imagePicker, animated: true, completion: nil)
                }
            } else {
                if oldStatus == .notDetermined {
                    return
                }
                DispatchQueue.main.async {
                    self?.showAlert(title: "Alert!", message: "Please allow us to use your phone camera. You can set the permission at Setting -> Privacy -> Camera")
                }
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        let controller = TOCropViewController.init(croppingStyle: .circular, image: image!)
        controller.delegate = self
        dismiss(animated: true, completion: { [weak self] in
            self?.present(controller, animated: true, completion: nil)
        })
    }
    
    func choosePhotoFromLibrary() {
        let oldStatus = PHPhotoLibrary.authorizationStatus()
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            switch status {
            case .authorized:
                DispatchQueue.main.async {
                    let controller = ImagePickerViewController.init(nibName: "ImagePickerViewController", bundle: nil)
                    controller.personController = self
                    self?.present(controller, animated: true, completion: nil)
                }
            case .denied:
                if oldStatus == .notDetermined {
                    return
                }
                DispatchQueue.main.async {
                    self?.showAlert(title: "Alert!", message: "Please allow us to access your photo library. You can set the permission at Setting -> Privacy -> Photos")
                }
            default:
                break
            }
        }
    }
}
