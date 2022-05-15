//
//  CommentDocumentController.swift
//  CSSE484GameBoard
//
//  Created by Yujie Zhang on 5/14/22.
//

import Foundation
import Firebase

class CommentDocumentManager{
    var _latestDocument: DocumentSnapshot?
    var gameDocumentId: String?
    var latestComment: Comment?
    static let shared = CommentDocumentManager()
    var _collectionRef: CollectionReference
    
    private init(){
        _collectionRef = Firestore.firestore().collection(kGamePath)
    }
    
    func startListening(for documentId: String, changeListener: @escaping (()-> Void))->ListenerRegistration{
        let query = _collectionRef.document(gameDocumentId!).collection(kCommentPath).document(documentId)
        return query.addSnapshotListener{documentSnapshot, error in
            guard let document = documentSnapshot else{
                return
            }
            guard let data = document.data() else{
                return
            }
            self.latestComment = Comment(documentSnapshot:document)
            self._latestDocument = document
            changeListener()
        }
    }
    
    func stopListening(_ listenerRegistration: ListenerRegistration?){
        listenerRegistration?.remove()
    }
}
    
    
