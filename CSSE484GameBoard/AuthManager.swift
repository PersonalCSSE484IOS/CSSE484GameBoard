//
//  AuthManager.swift
//  CSSE484GameBoard
//
//  Created by Yujie Zhang on 5/8/22.
//
import Foundation
import Firebase

class AuthManager{
    static let shared = AuthManager()
    private init(){
        
    }
    
    var currentUser: User?{
        Auth.auth().currentUser
    }
    
    var isSignedIn: Bool{
      currentUser != nil
    }
    
    func addLoginObserver(callback:@escaping (()->Void))->AuthStateDidChangeListenerHandle{
        return Auth.auth().addStateDidChangeListener{ auth, user in
            if(user != nil){
                callback()
            }
        }
    }
    
    func addLogoutObserver(callback:@escaping (()->Void))->AuthStateDidChangeListenerHandle{
        return Auth.auth().addStateDidChangeListener{ auth, user in
            if(user == nil){
                callback()
            }
        }
    }
    
    func removeObserver(_ authDidChangeHandle: AuthStateDidChangeListenerHandle?){
        if let authHandle = authDidChangeHandle{
            Auth.auth().removeStateDidChangeListener(authHandle)
        }
    }
    
    func createNewEmailPasswordUser(email: String, password: String){
        Auth.auth().createUser(withEmail: email, password: password){authResult, error in
            if let error = error{
                print("There was an error during create: \(error) \n")
                return
            }
            print("User created")
        }
    }
    
    func signinExistingEmailPasswordUser(email: String, password: String){
        Auth.auth().signIn(withEmail: email, password: password){
            authResult, error in
            if let error = error {
                print("There was an error in te creating user:\(error) \n")
                return
            }
            print("User created \n")
        }
    }
    
    func signInWithGoogleCredential(_ googleCredential: AuthCredential){
        Auth.auth().signIn(with: googleCredential)
    }
    
    func signOut(){
        do{
            try Auth.auth().signOut()
            print("You logged out")
        }catch{
            print("Sign out failed: \(error) \n")
        }
    }
}
