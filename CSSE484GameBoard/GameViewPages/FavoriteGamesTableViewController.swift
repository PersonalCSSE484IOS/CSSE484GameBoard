//
//  FavoriteGamesTableViewController.swift
//  CSSE484GameBoard
//
//  Created by Yujie Zhang on 5/15/22.
//

import Foundation
import Firebase


class FavoriteGamesTableCell: UITableViewCell{
    var gameDocumentId: String!

    @IBOutlet weak var FavoriteGamesImageView: UIImageView!
}
class FavoriteGamesTableViewContoller: UITableViewController{
    var gamesListenerRegistration: ListenerRegistration?
    var gameDocumentIdFromCellArr: [String] = []
    var gameDocumentIdFromCell: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startListeningForGame()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopListeningForGame()
    }
    
    func startListeningForGame(){
        stopListeningForGame()
        gamesListenerRegistration = GameCollectionManager.shared.startListeningByLikedBy(filterBy: Auth.auth().currentUser?.email){
            self.tableView.reloadData()
        }
    }
    
    func stopListeningForGame(){
        GameCollectionManager.shared.stopListening(gamesListenerRegistration)
    }
    
    func circleImage(gameCoverImageView: UIImageView){
        gameCoverImageView.layer.borderWidth = 1
        gameCoverImageView.layer.masksToBounds = false
        gameCoverImageView.layer.borderColor = UIColor.black.cgColor
        gameCoverImageView.layer.cornerRadius = gameCoverImageView.frame.height/4
        gameCoverImageView.clipsToBounds = true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("There are now \(GameCollectionManager.shared.latestGames.count) items")
        return GameCollectionManager.shared.latestGames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kFavoriteGamesCell, for: indexPath) as! FavoriteGamesTableCell
        let game = GameCollectionManager.shared.latestGames[indexPath.row]
        cell.gameDocumentId = game.documentId
        cell.FavoriteGamesImageView.tag = indexPath.row
        print("nOW THE ID IS \(cell.gameDocumentId)")
        gameDocumentIdFromCellArr.append(cell.gameDocumentId)
        self.loadCover(cell: cell, game: game)
        //cell.MenuGameImage.frame = CGRect(x:0.0,y:0.0,width:100.0,height:50.0)
        circleImage(gameCoverImageView: cell.FavoriteGamesImageView)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200.0;//Choose your custom row height
    }
    
    func goback(){
        self.navigationController?.popViewController(animated: true)
    }
    
    //helper function
    func loadCover(cell: FavoriteGamesTableCell, game: Game){
        //TODO: Update the view using the manager's data
        let docRef = Firestore.firestore().collection(kGamePath).document(cell.gameDocumentId)
        docRef.getDocument(source: .cache) { (document, error) in
            if let document = document {
                if let imgUrl = URL(string: document.get(kCoverPhotoURL) as! String) {
                    DispatchQueue.global().async { // Download in the background
                        do {
                            //print("The url is :\(game.coverPhotoURL)")
                            let data = try Data(contentsOf: imgUrl)
                            DispatchQueue.main.async { // Then update on main thread
                                cell.FavoriteGamesImageView.image = UIImage(data: data)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kshowGameDetailFromFavSegue{
            let gd = segue.destination as! GameDetailViewController
            if let indexPath = tableView.indexPathForSelectedRow{
                let game = GameCollectionManager.shared.latestGames[indexPath.row]
                gd.gameDocumentId = game.documentId!
                CommentDocumentManager.shared.gameDocumentId = game.documentId
                CommentCollectionManager.shared.gameDocumentId = game.documentId
                
            }
        }
    }
}
