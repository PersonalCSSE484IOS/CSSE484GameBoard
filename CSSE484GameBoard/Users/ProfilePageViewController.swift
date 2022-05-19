//
//  ProfilePageViewController.swift
//  CSSE484GameBoard
//
//  Created by Yujie Zhang on 5/13/22.
//

import Foundation
import Firebase
import FirebaseStorage
class ProfilePageViewController: UIViewController{
    
    @IBOutlet weak var displayUsernameTextField: UITextField!
    @IBOutlet weak var profilePhotoImageView: UIImageView!
    
    var userListenerRegistration: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()
        displayUsernameTextField.text = UsersCollectionManager.shared.username
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped(gesture:)))
        // add it to the image view;
        profilePhotoImageView.addGestureRecognizer(tapGesture)
        // make sure imageView can be interacted with by user
        profilePhotoImageView.isUserInteractionEnabled = true
        
        self.circleImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        displayUsernameTextField.text = UsersCollectionManager.shared.username
        userListenerRegistration = UsersCollectionManager.shared.startListening(for: (Auth.auth().currentUser?.email)!){
            self.updateView()
        }
    }
    
    
    
    override func viewDidDisappear(_ animated: Bool){
        super.viewDidDisappear(animated)
        UsersCollectionManager.shared.stopListening(userListenerRegistration)
    }
    
    func updateView(){
       // print("TODO: Show the name\(UserManager.shared.name)")
        displayUsernameTextField.text = UsersCollectionManager.shared.username
        if !UsersCollectionManager.shared.profilePhotoURL.isEmpty{
            ImageUtils.load(imageView: profilePhotoImageView, from: UsersCollectionManager.shared.profilePhotoURL)
        }
    }
    
    @IBAction func nameChange(_ sender: Any) {
        UsersCollectionManager.shared.update(name: displayUsernameTextField.text!)
    }
    
    @objc func imageTapped(gesture: UIGestureRecognizer) {
            // if the tapped view is a UIImageView then set it to imageview
            if (gesture.view as? UIImageView) != nil {
                print("Image Tapped")
                //Here you can initiate your new ViewController
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
                    imagePicker.sourceType = .camera
                }else{
                    imagePicker.sourceType = .photoLibrary
                }
                present(imagePicker, animated: true )
            }
        }
}

extension ProfilePageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                if let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage?{
                    StorageManager.shared.uploadProfilePhoto(uid: (Auth.auth().currentUser?.email)!, image: image)
                }
                picker.dismiss(animated: true)
    }
    
    func circleImage(){
        profilePhotoImageView.layer.borderWidth = 1
        profilePhotoImageView.layer.masksToBounds = false
        profilePhotoImageView.layer.borderColor = UIColor.black.cgColor
        profilePhotoImageView.layer.cornerRadius = profilePhotoImageView.frame.height/2
        profilePhotoImageView.clipsToBounds = true
    }
}
