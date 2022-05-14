//
//  GameCollectionManager.swift
//  CSSE484GameBoard
//
//  Created by Yujie Zhang on 5/8/22.
//
import Foundation
import Firebase

class GameCollectionManager{
   
    static let shared = GameCollectionManager()
    var _collectionRef: CollectionReference
    var latestGames = [Game]()
    private init(){
        _collectionRef = Firestore.firestore().collection(kGamePath)
       
    }
 
    func startListeningByGameType(filterBy GameType: String!, changeListener: @escaping (()-> Void))->ListenerRegistration{
            var query = _collectionRef.order(by: kReleasedDate, descending: true).limit(to:50)
            if let gameTypeFilter = GameType{
                print("TODO: FILTER by game type ")
                query = query.whereField(kGameType, arrayContains: gameTypeFilter)
            }
            
        return query.addSnapshotListener{querySnapshot, error in
            guard let documents = querySnapshot?.documents else{
                print("error")
                return
            }
            self.latestGames.removeAll()
            for document in documents{
                self.latestGames.append(Game(documentSnapshot:document))
            }
            changeListener()
        }
    }
    
    func startListeningByGameReleased(filterBy isReleased: Bool!, changeListener: @escaping (()-> Void))->ListenerRegistration{
            var query = _collectionRef.order(by: kReleasedDate, descending: true).limit(to:50)
            if let gameTypeFilter = isReleased{
                print("TODO: FILTER by release time ")
                query = query.whereField(kisReleased, isEqualTo: isReleased)
            }
            
        return query.addSnapshotListener{querySnapshot, error in
            guard let documents = querySnapshot?.documents else{
                print("error")
                return
            }
            self.latestGames.removeAll()
            for document in documents{
                self.latestGames.append(Game(documentSnapshot:document))
            }
            changeListener()
        }
    }
    
    func stopListening(_ listenerRegistration: ListenerRegistration?){
        listenerRegistration?.remove()
    }
    
    func addNewGame(uid:String, gameName:String?, coverPhotoURL:String?, gameType: [String], releasedDate: String){
        let docRef = _collectionRef.document(uid)
        docRef.getDocument{(document, error) in
            if let document = document, document.exists{
                print("Document exists, do nothing")
            }else{
                print("Document does not exist, create one")
                docRef.setData([
                    kGameName: gameName ?? "",
                    kCoverPhotoURL: coverPhotoURL ?? "",
                    kGameType: gameType,
                    kReleasedDate:releasedDate
                ])
            }
        }
    }
    
    func add(_ game: Game){
        let docRef = _collectionRef.document(game.documentId!)
        docRef.getDocument{(document, error) in
            if let document = document, document.exists{
                print("Document exists, do nothing")
            }else{
                print("Document does not exist, create one")
                docRef.setData([
                    kGameName: game.gameName,
                    kCoverPhotoURL: game.coverPhotoURL,
                    kGameType: game.gameType,
                    kReleasedDate: game.releasedDate,
                    kisReleased: game.isReleased
                ])
            }
        }
    }
    
    
    
    func delete(_ documentId: String){
        _collectionRef.document(documentId).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
}

extension Date {
    static var currentTimeStamp: Int64{
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
}

