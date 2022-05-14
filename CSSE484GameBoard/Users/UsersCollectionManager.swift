//
//  UsersCollectionManager.swift
//  CSSE484GameBoard
//
//  Created by Yujie Zhang on 5/8/22.
//

import Foundation
import Firebase

class UsersCollectionManager{
    var _latestDocument: DocumentSnapshot?
    static let shared = UsersCollectionManager()
    var _collectionRef: CollectionReference
    
    private init(){
        _collectionRef = Firestore.firestore().collection(kUserPath)
    }
    
    func addNewUser(uid:String, Username:String?, photoUrl:String?){
        let docRef = _collectionRef.document(uid)
        docRef.getDocument{(document, error) in
            if let document = document, document.exists{
                print("Document exists, do nothing")
            }else{
                print("Document does not exist, create one")
                docRef.setData([
                    kUsername: Username ?? "",
                    kProfilePhotoURL: photoUrl ?? "",
                ])
            }
        }
    }
    
    func startListening(for documentId: String, changeListener: @escaping (()-> Void))->ListenerRegistration{
        let query = _collectionRef.document(documentId)
        return query.addSnapshotListener{documentSnapshot, error in
            self._latestDocument = nil
            guard let document = documentSnapshot else{
                return
            }
            guard document.data() != nil else{
                print("document was empty")
                return
            }
            self._latestDocument = document
            changeListener()
        }
    }
    
    func stopListening(_ listenerRegistration: ListenerRegistration?){
        listenerRegistration?.remove()
    }
    
    var username: String{
        if let name = _latestDocument?.get(kUsername){
            return name as! String
        }
        return ""
    }
    
    var profilePhotoURL: String{
        if let profilephotourl = _latestDocument?.get(kProfilePhotoURL){
            return profilephotourl as! String
        }
        return ""
    }
    
    func update(name: String){
        _collectionRef.document(_latestDocument!.documentID).updateData([
            kUsername: name,
        ]){err in
            if let err = err{
                print("Error updating document:\(err)")
            }else{
                print("Name successfully updated")
            }
        }
    }
    
    func updateProfilePhoto(PhotoUrl: String){
        _collectionRef.document(_latestDocument!.documentID).updateData([
            kProfilePhotoURL: PhotoUrl,
        ]){err in
            if let err = err{
                print("Error updating document:\(err)")
            }else{
                print("Name successfully updated")
            }
        }
    }
}
