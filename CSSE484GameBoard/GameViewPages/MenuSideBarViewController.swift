//
//  MenuSideBarViewController.swift
//  CSSE484GameBoard
//
//  Created by Yujie Zhang on 5/8/22.
//

import Foundation
import Firebase

class MenuSideBarViewController: UIViewController{
    var isAdmin: Bool?
    var showIsReleased: Bool = true
    @IBOutlet weak var ProfilePhotoImageView: UIImageView!
    @IBOutlet weak var AdminAddGameLabel: UIButton!
    @IBOutlet weak var UsernameLabel: UILabel!
    
    var tableView: MenuTableViewController{
        let navController = presentingViewController as! UINavigationController
        return navController.viewControllers.last as! MenuTableViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.circleImage()
        self.loadProfilePhoto()

        
        if(Auth.auth().currentUser?.email == "rykerzhang048109@gmail.com"){
            self.isAdmin = true
        }else{
            self.isAdmin = false
        }
        if(self.isAdmin == true){
            AdminAddGameLabel.isHidden = false
        }else{
            AdminAddGameLabel.isHidden = true
        }
        UsernameLabel.text = Auth.auth().currentUser?.email
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.circleImage()
        self.loadProfilePhoto()
    }
    
    @IBAction func pressPersonalSettingsButton(_ sender: Any) {
        dismiss(animated: true)
        print("Press Personal Settings Button")
        self.performSegue(withIdentifier: kshowProfilePage, sender: self)
    }
    @IBAction func pressLogOutButton(_ sender: Any) {
        dismiss(animated: true)
        AuthManager.shared.signOut()
    }
    
    @IBAction func pressAdminAddGame(_ sender: Any) {
       // dismiss(animated: true)
        self.showAddGameDialog()
        self.tableView.guranteeReload()
    }
    
    @objc func showAddGameDialog(){
        let alertController = UIAlertController(title: "Add new Games",
                                                message: "",
                                                preferredStyle: UIAlertController.Style.alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Name"//the grey word
        }
        
        alertController.addTextField { textField in
            textField.placeholder = "Game Type (comma separated)"//the grey word
        }
        
        alertController.addTextField { textField in
            textField.placeholder = "Released Date"//the grey word
        }
        
        alertController.addTextField { textField in
            textField.placeholder = "Cover Photo URL"//the grey word
        }
        
        //create an action and add it to the controller
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { action in        }
        alertController.addAction(cancelAction)
        let AddGameAction = UIAlertAction(title: "Add Game", style: UIAlertAction.Style.default) { action in
            let gameNameField = alertController.textFields![0] as UITextField
            let gameTypeField = alertController.textFields![1] as UITextField
            let gameTypeArr = gameTypeField.text?.components(separatedBy: ",")
            let gameReleasedDateTime = alertController.textFields![2] as UITextField
            let gameCoverPhotoURL = alertController.textFields![3] as UITextField
            let newGame = Game(coverPhotoURL: gameCoverPhotoURL.text!, gameName: gameNameField.text!, releasedDate: gameReleasedDateTime.text!, gameType: gameTypeArr!)
            GameCollectionManager.shared.add(newGame)
        }
        alertController.addAction(AddGameAction)
        present(alertController, animated: true)//to show the thing
    }
    
    func circleImage(){
        ProfilePhotoImageView.layer.borderWidth = 1
        ProfilePhotoImageView.layer.masksToBounds = false
        ProfilePhotoImageView.layer.borderColor = UIColor.black.cgColor
        ProfilePhotoImageView.layer.cornerRadius = ProfilePhotoImageView.frame.height/2
        ProfilePhotoImageView.clipsToBounds = true
    }
    
    func loadProfilePhoto(){
       // if !UsersCollectionManager.shared.profilePhotoURL.isEmpty{
        //ImageUtils.load(imageView: ProfilePhotoImageView, from: UsersCollectionManager.ge)
        //}
        
        let docRef = Firestore.firestore().collection(kUserPath).document((Auth.auth().currentUser?.email)!)
                    docRef.getDocument(source: .cache) { (document, error) in
                        if let document = document {
                            if let imgUrl = URL(string: document.get(kProfilePhotoURL) as! String) {
                                        DispatchQueue.global().async { // Download in the background
                                          do {
                                              print("The current email is \(Auth.auth().currentUser?.email) The url is :\(imgUrl)")
                                            let data = try Data(contentsOf: imgUrl)
                                            DispatchQueue.main.async { // Then update on main thread
                                                self.ProfilePhotoImageView.image = UIImage(data: data)
                                            }
                                          } catch {
                                            print("Error downloading image: \(error)")
                                          }
                                        }
                                }
                        } else {
                            print("Document does not exist in cache")
                        }
                    }
    }
   
}
