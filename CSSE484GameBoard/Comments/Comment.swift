//
//  Comment.swift
//  CSSE484GameBoard
//
//  Created by Yujie Zhang on 5/14/22.
//


import Foundation
import Firebase
class Comment{
    var documentId: String?
    var content: String
    var authorUsername: String
    var authorEmail: String
    
    init(content: String, authorEmail: String, authorUsername: String){
        self.content = content
        self.authorEmail = authorEmail
        self.authorUsername = authorUsername
    }
    
    init(documentSnapshot: DocumentSnapshot){
        self.documentId = documentSnapshot.documentID
        let data = documentSnapshot.data()
        self.content = data?[kCommentContent] as! String
        self.authorUsername = data?[kCommentAuthorUsername] as! String
        self.authorEmail = data?[kCommentAuthorEmail] as! String
    }
}
