//
//  GameDetailViewController.swift
//  CSSE484GameBoard
//
//  Created by Yujie Zhang on 5/12/22.
//

import Foundation
import UIKit
import Firebase
class GameCommentTableViewCell: UITableViewCell{
    
    @IBOutlet weak var CommentLabel: UILabel!
    @IBOutlet weak var UsernameLabel: UILabel!
    @IBOutlet weak var UserImage: UIImageView!
}
class GameDetailViewController: UITableViewController{
    @IBOutlet weak var gameImageView: UIImageView!
    @IBOutlet weak var gameNameLabel: UILabel!
    @IBOutlet weak var gameTypeLabel: UILabel!
    @IBOutlet weak var gameIntroductionLabel: UILabel!
    var gameDocumentId: String!
    var gameListenerRegistration: ListenerRegistration?
    var userListenerRegistration: ListenerRegistration?
    var commentListenerRegistration: ListenerRegistration?
    var likedUsersArr: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateGameViews()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 400
    }
    
    func showOrHideEditButton(){
        if(Auth.auth().currentUser?.email == "rykerzhang048109@gmail.com"){
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.edit, target: self, action: #selector(showEditGameIntroduction))
        }else{
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(showAddCommentDialogue))
        }
        //self.starButtonViewSet()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gameListenerRegistration = GameDocumentManager.shared.startListening(for: gameDocumentId){
            self.updateGameViews()
            self.showOrHideEditButton()
        }
        startListeningForComments()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopListeningForComments()
    }
    
    func startListeningForComments(){
        stopListeningForComments()
        commentListenerRegistration = CommentCollectionManager.shared.startListening(filterByAuthor: nil){
            self.tableView.reloadData()
        }
    }
    
    func stopListeningForComments(){
        CommentCollectionManager.shared.stopListening(commentListenerRegistration)
    }
    
    func goBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let comment = CommentCollectionManager.shared.latestComments[indexPath.row]
        return (AuthManager.shared.currentUser?.email==comment.authorEmail)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CommentCollectionManager.shared.latestComments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kgameCommentCell, for: indexPath) as! GameCommentTableViewCell
        let comment = CommentCollectionManager.shared.latestComments[indexPath.row]
        cell.UsernameLabel.text = comment.authorUsername
        print("So the comment is \(comment.content) and the username is \(comment.authorUsername) and the user profile url is \(UsersCollectionManager.shared.profilePhotoURL)")
        cell.CommentLabel.text = comment.content
        self.loadUserImage(cell: cell)
        self.circleImage(cell: cell)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if(Auth.auth().currentUser?.email == "rykerzhang048109@gmail.com"){
            if editingStyle == .delete {
                //TODO: Implement delete
                let commentDelete = CommentCollectionManager.shared.latestComments[indexPath.row]
                CommentCollectionManager.shared.delete(commentDelete.documentId!)
            }
        }
    }
    
    @objc func showAddCommentDialogue(){
        let alertController = UIAlertController(title: "Add Your Comment", message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField{ textField in
            textField.placeholder = "Comment here"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { action in
        }
        alertController.addAction(cancelAction)
        let addComment = UIAlertAction(title: "Submit", style: UIAlertAction.Style.default) { action in
            let commentContent = alertController.textFields![0] as UITextField
            let newComment = Comment(content: commentContent.text!, authorEmail: (Auth.auth().currentUser?.email)!, authorUsername: UsersCollectionManager.shared.username)
            CommentCollectionManager.shared.add(newComment)
        }
        alertController.addAction(addComment)
        present(alertController, animated: true)
    }
    
    
    @objc func showEditGameIntroduction(){
        let alertController = UIAlertController(title: "Edit game introduction", message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField{ textField in
            textField.placeholder = "Game introduction here"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { action in
        }
        alertController.addAction(cancelAction)
        let editIntroduction = UIAlertAction(title: "Edit Introduction", style: UIAlertAction.Style.default) { action in
            let introField = alertController.textFields![0] as UITextField
            GameDocumentManager.shared.updateGameIntroduction(gameIntro: introField.text!)
        }
        alertController.addAction(editIntroduction)
        present(alertController, animated: true)
    }
    
    func updateGameViews(){
        if let game = GameDocumentManager.shared.latestGame{
            gameNameLabel.text = game.gameName
            let stringRepresentationOfType = game.gameType.joined(separator: "   ")
            gameTypeLabel.text = stringRepresentationOfType
            loadParameters()
            starButtonViewSet()
        }
        
    }
    
    func loadUserImage(cell: GameCommentTableViewCell){
        let docRef = Firestore.firestore().collection(kUserPath).document((Auth.auth().currentUser?.email)!)
                docRef.getDocument(source: .cache) { (document, error) in
                    if let document = document {
                        if let imgUrl = URL(string: document.get(kProfilePhotoURL) as! String) {
                                    DispatchQueue.global().async { // Download in the background
                                      do {
                                        let data = try Data(contentsOf: imgUrl)
                                        DispatchQueue.main.async { // Then update on main thread
                                            cell.UserImage.image = UIImage(data: data)
                                        }
                                      } catch {
                                        print("Error downloading image: \(error)")
                                      }
                                    }
                            }
                    } else {
                        print("Document does not exist in cache")
                    }
                }
    }
    func loadParameters(){
       //TODO: Update the view using the manager's data
        let docRef = Firestore.firestore().collection(kGamePath).document(gameDocumentId)
                docRef.getDocument(source: .cache) { (document, error) in
                    if let document = document {
                        if let intro = document.get(kGameIntroduction){
                            self.gameIntroductionLabel.text = intro as! String
                        }
                        if let imgUrl = URL(string: document.get(kCoverPhotoURL) as! String) {
                                    DispatchQueue.global().async { // Download in the background
                                      do {
                                          //print("The url is :\(game.coverPhotoURL)")
                                        let data = try Data(contentsOf: imgUrl)
                                        DispatchQueue.main.async { // Then update on main thread
                                            self.gameImageView.image = UIImage(data: data)
                                        }
                                      } catch {
                                        print("Error downloading image: \(error)")
                                      }
                                    }
                            }
                    } else {
                        print("Document does not exist in cache")
                    }
                }
            }
    
    func starButtonViewSet(){
        var currentUserFavoriteList = GameDocumentManager.shared.likedUserEmails
        print("So the currentUserFavoriteList is \(currentUserFavoriteList)")
        if(currentUserFavoriteList == []){
            starButtonLabel.setTitle("☆", for: .normal)
        }else if(currentUserFavoriteList.contains((Auth.auth().currentUser?.email)!)){
            starButtonLabel.setTitle("★", for: .normal)
        }else{
            starButtonLabel.setTitle("☆", for: .normal)
        }
    }
    @IBOutlet weak var starButtonLabel: UIButton!
    
    @IBAction func pressStarButton(_ sender: Any) {
        let docRef = Firestore.firestore().collection(kGamePath).document(self.gameDocumentId)
                    docRef.getDocument(source: .cache) { (document, error) in
                        if let document = document {
                            var likedBy = document.get(klikedBy) as! [String]
                            print("The current user fav list is \(likedBy)")
                            if(likedBy == []){
                                likedBy.append((Auth.auth().currentUser?.email)!)
                                GameDocumentManager.shared.updateGameLikedBy(UserEmails: likedBy)
                                self.starButtonLabel.setTitle("★", for: .normal)
                            }else if(likedBy.contains((Auth.auth().currentUser?.email)!)){
                                let newLikedBy = likedBy.filter {$0 != Auth.auth().currentUser?.email}
                                GameDocumentManager.shared.updateGameLikedBy(UserEmails: newLikedBy)
                                self.starButtonLabel.setTitle("☆", for: .normal)
                            }else{
                                likedBy.append((Auth.auth().currentUser?.email)!)
                                GameDocumentManager.shared.updateGameLikedBy(UserEmails: likedBy)
                                self.starButtonLabel.setTitle("★", for: .normal)
                            }
                        } else {
                            print("Document does not exist in cache")
                        }
                    }
        
    }
    
    @IBAction func PressBackToPreviousPage(_ sender: Any) {
        self.goBack()
    }
    
    func circleImage(cell: GameCommentTableViewCell){
        cell.UserImage.layer.borderWidth = 1
        cell.UserImage.layer.masksToBounds = false
        cell.UserImage.layer.borderColor = UIColor.black.cgColor
        cell.UserImage.layer.cornerRadius = cell.UserImage.frame.height/2
        cell.UserImage.clipsToBounds = true
    }
}
