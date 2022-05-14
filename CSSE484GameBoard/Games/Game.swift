//
//  Game.swift
//  CSSE484GameBoard
//
//  Created by Yujie Zhang on 5/8/22.
//

import Foundation
import Firebase
class Game{
    
    var coverPhotoURL: String
    var gameName: String
    var releasedDate: String
    var gameType: [String]
    var documentId: String?
    var isReleased: Bool?
    var gameIntroduction: String?
    let date = NSDate()
    
    init(coverPhotoURL: String, gameName: String, releasedDate: String, gameType: [String]){
        self.coverPhotoURL = coverPhotoURL
        self.gameName = gameName
        self.releasedDate = releasedDate
        self.gameType = gameType
        self.isReleased = checkIsReleased()
        self.documentId = self.gameName
    }
    
    init(documentSnapshot: DocumentSnapshot){
        self.documentId = documentSnapshot.documentID
        let data = documentSnapshot.data()
        self.coverPhotoURL = data?[kCoverPhotoURL] as! String
        self.gameName = data?[kGameName] as! String
        self.releasedDate = data?[kReleasedDate] as! String
        self.gameType = data?[kGameType] as! [String]
        //self.gameIntroduction = data? [kGameIntroduction] as! String

    }
    
    func checkIsReleased() -> Bool{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let releasedDate = dateFormatter.date(from:self.releasedDate)!
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: date as Date)
        let currentDate = calendar.date(from:components)
        
        if(releasedDate > currentDate!){
            return false
        }else{
            return true
        }

    }
}
