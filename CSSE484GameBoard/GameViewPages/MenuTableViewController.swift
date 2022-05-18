//
//  MenuTableViewController.swift
//  CSSE484GameBoard
//
//  Created by Yujie Zhang on 5/8/22.
//

import Foundation
import Firebase

class MenuGameTableCell: UITableViewCell{
    var gameDocumentId: String!

    @IBOutlet weak var MenuGameImage: UIImageView!
}

class MenuTableViewController: UITableViewController{
    var logoutHandle : AuthStateDidChangeListenerHandle?
    var gamesListenerRegistration: ListenerRegistration?
    var gameDocumentIdFromCellArr: [String] = []
    var gameDocumentIdFromCell: String = ""
    var showReleased = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.reloadData()
//        navigationController?.navigationBar.backgroundColor = UIColor(red: 52/255, green: 199/255, blue: 89/255, alpha: 1)
//        navigationController?.navigationBar.isTranslucent = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startListeningForGame()
        logoutHandle = AuthManager.shared.addLogoutObserver(callback: {print("Someone signed out")
            self.navigationController?.popViewController(animated: true)
        })
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopListeningForGame()
        AuthManager.shared.removeObserver(logoutHandle)
    }
    
    func startListeningForGame(){
        stopListeningForGame()
        gamesListenerRegistration = GameCollectionManager.shared.startListeningByGameReleased(filterBy: showReleased ? true : false){
            self.tableView.reloadData()
        }
       
    }
    
    func stopListeningForGame(){
        GameCollectionManager.shared.stopListening(gamesListenerRegistration)
    }
    
    func circleImage(MenuGameImage: UIImageView){
        MenuGameImage.layer.borderWidth = 1
        MenuGameImage.layer.masksToBounds = false
        MenuGameImage.layer.borderColor = UIColor.black.cgColor
        MenuGameImage.layer.cornerRadius = MenuGameImage.frame.height/4
        MenuGameImage.clipsToBounds = true
    }
    
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        let game = GameCollectionManager.shared.latestGames[indexPath.row]
//        return AuthManager.shared.currentUser?.uid == game.gameName
//    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("There are  \(GameCollectionManager.shared.latestGames.count) number of games now")
        return GameCollectionManager.shared.latestGames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kGameCell, for: indexPath) as! MenuGameTableCell
        let game = GameCollectionManager.shared.latestGames[indexPath.row]
        cell.gameDocumentId = game.documentId
        cell.MenuGameImage.tag = indexPath.row
        print("nOW THE ID IS \(cell.gameDocumentId)")
        gameDocumentIdFromCellArr.append(cell.gameDocumentId)
        self.loadCover(cell: cell, game: game)
        //cell.MenuGameImage.frame = CGRect(x:0.0,y:0.0,width:100.0,height:50.0)
        circleImage(MenuGameImage: cell.MenuGameImage)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //TODO: Implement delete
            let gameDelete = GameCollectionManager.shared.latestGames[indexPath.row]
            GameCollectionManager.shared.delete(gameDelete.documentId!)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200.0;//Choose your custom row height
    }
    
    func goback(){
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kshowGameDetail{
            let gd = segue.destination as! GameDetailViewController
            if let indexPath = tableView.indexPathForSelectedRow{
                let game = GameCollectionManager.shared.latestGames[indexPath.row]
                gd.gameDocumentId = game.documentId!
                CommentDocumentManager.shared.gameDocumentId = game.documentId
                CommentCollectionManager.shared.gameDocumentId = game.documentId

            }
        }
    }
    
    //helper function
    func loadCover(cell: MenuGameTableCell, game: Game){
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
                                            cell.MenuGameImage.image = UIImage(data: data)
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
    
    //helper function used in side Menu
    func guranteeReload(){
        self.tableView.reloadData()
    }
    
//    //helper function
//    @objc func imageTapped(gesture: UIGestureRecognizer) {
//            // if the tapped view is a UIImageView then set it to imageview
//            if (gesture.view as? UIImageView) != nil {
//                print("Image Tapped")
//                //Here you can initiate your new ViewController
//                self.tag
//            }
//        }
    
//TODO: Button change and button effects
    @IBAction func showReleasedGame(_ sender: Any) {
        self.showReleased = true
        self.startListeningForGame()
        //self.tableView.reloadData()
        print("Now the show relased is \(self.showReleased)")
    }
    @IBAction func showUpcomingGame(_ sender: Any) {
        print("Now show upcomingGame")
        self.showReleased = false
        self.startListeningForGame()
        //self.tableView.reloadData()
        print("Now the show relased is \(self.showReleased)")

    }
    @IBAction func showRanks(_ sender: Any) {
        self.performSegue(withIdentifier: kshowRankedGamesSegue, sender: self)
    }
    @IBAction func showGames(_ sender: Any) {
        self.performSegue(withIdentifier: kshowAllGamesSegue, sender: self)
    }
    @IBAction func showList(_ sender: Any) {
        self.performSegue(withIdentifier: kshowMyFavoriteSegue, sender: self)
    }
}
