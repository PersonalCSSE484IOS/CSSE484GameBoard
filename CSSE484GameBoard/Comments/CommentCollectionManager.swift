//
//  CommentCollectionManager.swift
//  CSSE484GameBoard
//
//  Created by Yujie Zhang on 5/14/22.
//

import Foundation
import Firebase

class CommentCollectionManager{
    static let shared = CommentCollectionManager()
    var _collectionRef: CollectionReference
    var gameDocumentId: String?
    var latestComments = [Comment]()
    
    private init(){
        _collectionRef = Firestore.firestore().collection(kGamePath)
    }
    
    func startListening(filterByAuthor authorFilter: String?, changeListener: @escaping (()-> Void))->ListenerRegistration{
        var query = _collectionRef.document(gameDocumentId!).collection(kCommentPath).order(by: kCommentCreatedTime, descending: true).limit(to:50)
        return query.addSnapshotListener{querySnapshot, error in
            guard let documents = querySnapshot?.documents else{
                print("error")
                return
            }
            self.latestComments.removeAll()
            for document in documents{
                print("\(document.documentID) => \(document.data())")
                self.latestComments.append(Comment(documentSnapshot:document))
            }
            changeListener()
        }
    }
    
    func stopListening(_ listenerRegistration: ListenerRegistration?){
        listenerRegistration?.remove()
    }
    
    func add(_ comment: Comment){
        var ref: DocumentReference? = nil
        ref = _collectionRef.document(gameDocumentId!).collection(kCommentPath).addDocument(data:[
            kCommentAuthorEmail: comment.authorEmail,
            kCommentAuthorUsername: comment.authorUsername,
            kCommentCreatedTime: Timestamp.init(),
            kCommentContent: comment.content
        ]){ err in
            if let err = err{
                print("Error adding document \(err)")
            }
        }
    }
    
    func delete(_ documentId: String){
        _collectionRef.document(gameDocumentId!).collection(kCommentPath).document(documentId).delete() { err in
            if let err = err {
               // print("Error removing document: \(err)")
            } else {
                //print("Document successfully removed!")
            }
        }
    }
}
