//
//  GameRankTableViewController.swift
//  CSSE484GameBoard
//
//  Created by Yujie Zhang on 5/16/22.
//

import Foundation
import Firebase

class RankedGameTableCell: UITableViewCell{
    var gameDocumentId: String!
    
    @IBOutlet weak var rankedImageView: UIImageView!
}
class GameRankTableViewController: UITableViewController{
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
        gamesListenerRegistration = GameCollectionManager.shared.startListeningByLikedByCount(filterBy: 0){
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
        let cell = tableView.dequeueReusableCell(withIdentifier: krankedGameCell, for: indexPath) as! RankedGameTableCell
        let game = GameCollectionManager.shared.latestGames[indexPath.row]
        cell.gameDocumentId = game.documentId
        cell.rankedImageView.tag = indexPath.row
        print("nOW THE ID IS \(cell.gameDocumentId)")
        gameDocumentIdFromCellArr.append(cell.gameDocumentId)
        self.loadCover(cell: cell, game: game)
        //cell.MenuGameImage.frame = CGRect(x:0.0,y:0.0,width:100.0,height:50.0)
        circleImage(gameCoverImageView: cell.rankedImageView)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200.0;//Choose your custom row height
    }
    
    func goback(){
        self.navigationController?.popViewController(animated: true)
    }
    
    //helper function
    func loadCover(cell: RankedGameTableCell, game: Game){
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
                                cell.rankedImageView.image = UIImage(data: data)
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
        if segue.identifier == kshowGameDetailFromRankSegue{
            let gd = segue.destination as! GameDetailViewController
            if let indexPath = tableView.indexPathForSelectedRow{
                let game = GameCollectionManager.shared.latestGames[indexPath.row]
                gd.gameDocumentId = game.documentId!
                CommentDocumentManager.shared.gameDocumentId = game.documentId
                CommentCollectionManager.shared.gameDocumentId = game.documentId
                
            }
        }
    }
    
    @IBAction func pressRankingRuleQuestionMarkButton(_ sender: Any) {
        self.showGameRankRulesDialogue()
    }
    
    @objc func showGameRankRulesDialogue(){
        let alertController = UIAlertController(title: "Game Rank Rules:\nThis game rank is based on the number of times a game is 'liked'.\n Games that are not liked by any users will not be included in this rank.", message: "", preferredStyle: UIAlertController.Style.alert)
        let cancelAction = UIAlertAction(title: "Understand", style: UIAlertAction.Style.cancel) { action in
        }
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
}
