//
//  MenuSideBarViewController.swift
//  CSSE484GameBoard
//
//  Created by Yujie Zhang on 5/8/22.
//

import Foundation
import Firebase

class MenuSideBarViewController: UIViewController{
    
    
    @IBOutlet weak var ProfilePhotoImageView: UIImageView!
    
    @IBOutlet weak var UsernameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UsernameLabel.text = Auth.auth().currentUser?.email
    }
    @IBAction func pressPersonalSettingsButton(_ sender: Any) {
        print("Press Personal Settings Button")
    }
    @IBAction func pressMyListButton(_ sender: Any) {
        print("Press My List Button")
    }
    @IBAction func pressLogOutButton(_ sender: Any) {
        dismiss(animated: true)
        AuthManager.shared.signOut()
    }
}
