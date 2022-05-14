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
    
}
class GameDetailViewController: UITableViewController{
    @IBOutlet weak var gameImageView: UIImageView!
    @IBOutlet weak var gameNameLabel: UILabel!
    @IBOutlet weak var gameTypeLabel: UILabel!
    @IBOutlet weak var gameIntroductionLabel: UILabel!
    var gameDocumentId: String!
    var gameListenerRegistration: ListenerRegistration?
    var userListenerRegistration: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateGameViews()
        
    }
    
    func showOrHideEditButton(){
        if(Auth.auth().currentUser?.email == "rykerzhang048109@gmail.com"){
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.edit, target: self, action: #selector(showEditGameIntroduction))
        }else{
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gameListenerRegistration = GameDocumentManager.shared.startListening(for: gameDocumentId){
            self.updateGameViews()
            self.showOrHideEditButton()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
