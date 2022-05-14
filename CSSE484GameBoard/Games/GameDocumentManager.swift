//
//  GameDocumentManager.swift
//  CSSE484GameBoard
//
//  Created by Yujie Zhang on 5/8/22.
//
import Foundation
import Firebase

class GameDocumentManager{
    var latestGame: Game?
    var _collectionRef: CollectionReference
    static let shared = GameDocumentManager()
    var _latestDocument: DocumentSnapshot?

    
    private init(){
        _collectionRef = Firestore.firestore().collection(kGamePath)
    }
    
    func startListening(for documentId: String, changeListener: @escaping (()-> Void))->ListenerRegistration{
        let query = _collectionRef.document(documentId)
        return query.addSnapshotListener{documentSnapshot, error in
            guard let document = documentSnapshot else{
                return
            }
            guard let data = document.data() else{
                return
            }
            self.latestGame = Game(documentSnapshot:document)
            self._latestDocument = document

            changeListener()
        }
    }
    
    func stopListening(_ listenerRegistration: ListenerRegistration?){
        listenerRegistration?.remove()
    }
    
    func update(gamename: String){
        _collectionRef.document(latestGame!.documentId!).updateData([
            kGameName: gamename]){
                err in
                if let err = err{
                    print("Error updateing: \(err)")
                }else{
                    print("Document updated")
                }
            }
    }
    
    func updateGameIntroduction(gameIntro: String){
        _collectionRef.document(latestGame!.documentId!).updateData([
            kGameIntroduction: gameIntro]){
                err in
                if let err = err{
                    print("Error updateing: \(err)")
                }else{
                    print("Document updated")
                }
            }
    }
    
    func updateGameType(gameTypes: [String]){
        _collectionRef.document(latestGame!.documentId!).updateData([
            kGameType: gameTypes]){
                err in
                if let err = err{
                    print("Error updateing: \(err)")
                }else{
                    print("Document updated")
                }
            }
    }

    func returnGameType() -> [String]{
        if let lastDoc = latestGame{
            return lastDoc.gameType
        }
        return []
    }
    
    var coverPhotoURL: String{
        if let coverphotoURL = _latestDocument?.get(kCoverPhotoURL) {
            return coverphotoURL as! String
        }
        return ""
    }
    
    var gameType: [String]{
        if let gameType = _latestDocument?.get(kGameType) {
            return gameType as! [String]
        }
        return []
    }
    
    var gameName: String{
        if let gamename = _latestDocument?.get(kGameName){
            return gamename as! String
        }
        return ""
    }
    
    var isReleased: Bool{
        if let isReleased = _latestDocument?.get(kisReleased){
            return isReleased as! Bool
        }
        return false
    }
    
    var gameIntroduction: String{
        if let gameIntro = _latestDocument?.get(kGameIntroduction){
            return gameIntro as! String
        }
        return "jjj"
    }
    
}

