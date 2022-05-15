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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateGameViews()
        
    }
    
    func showOrHideEditButton(){
        if(Auth.auth().currentUser?.email == "rykerzhang048109@gmail.com"){
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.edit, target: self, action: #selector(showEditGameIntroduction))
        }else{
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(showAddCommentDialogue))
        }
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
        cell.CommentLabel.text = comment.content
        print("So the comment is \(comment.content) and the username is \(comment.authorUsername) and the user profile url is \(UsersCollectionManager.shared.profilePhotoURL)")
        if !UsersCollectionManager.shared.profilePhotoURL.isEmpty{
            ImageUtils.load(imageView: cell.UserImage, from: UsersCollectionManager.shared.profilePhotoURL)
        }
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
    
    
    
    
}
