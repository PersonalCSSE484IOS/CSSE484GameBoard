//
//  LoginMenuViewController.swift
//  CSSE484GameBoard
//
//  Created by Yujie Zhang on 5/8/22.
//

import Foundation
import Firebase
import GoogleSignIn


class LoginMenuViewController: UIViewController{
    var loginHandle: AuthStateDidChangeListenerHandle?
    @IBOutlet weak var PasswordLabel: UITextField!
    @IBOutlet weak var EmailLabel: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        EmailLabel.placeholder = "Email"
        PasswordLabel.placeholder = "Password"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loginHandle = AuthManager.shared.addLoginObserver {
            self.performSegue(withIdentifier: kshowMenuSegue, sender: self)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AuthManager.shared.removeObserver(loginHandle)
    }

    @IBAction func pressCreateNewUserButton(_ sender: Any) {
        let email = EmailLabel.text!
        let password = PasswordLabel.text!
        AuthManager.shared.createNewEmailPasswordUser(email: email, password: password)
        UsersCollectionManager.shared.addNewUser(uid: email , Username: email, photoUrl: "https://www.kindpng.com/picc/m/24-248253_user-profile-default-image-png-clipart-png-download.png")
    }
    
    @IBAction func pressLoginButton(_ sender: Any) {
        let email = EmailLabel.text!
        let password = PasswordLabel.text!
        AuthManager.shared.signinExistingEmailPasswordUser(email: email, password: password)
    }
}

