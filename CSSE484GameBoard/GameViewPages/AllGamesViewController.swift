//
//  AllGamesViewController.swift
//  CSSE484GameBoard
//
//  Created by Yujie Zhang on 5/14/22.
//

import Foundation
import Firebase
import SwiftUI


class TypeGamesTableCell: UITableViewCell{
    var gameDocumentId: String!
    
    @IBOutlet weak var gameCoverImageView: UIImageView!
}
class AllGamesTableViewConroller: UITableViewController{
    var currentType: String = "ACT"
    var gamesListenerRegistration: ListenerRegistration?
    var gameDocumentIdFromCellArr: [String] = []
    var gameDocumentIdFromCell: String = ""
    
    @IBOutlet weak var RPGButton: UIButton!
    @IBOutlet weak var SLGButton: UIButton!
    @IBOutlet weak var FPSButton: UIButton!
    @IBOutlet weak var ADVButton: UIButton!
    @IBOutlet weak var ACTButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "The Games"
        
        var swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.swipedRight))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        
        var swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.swipedLeft))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        
        self.view.addGestureRecognizer(swipeLeft)
        self.view.addGestureRecognizer(swipeRight)
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
        print("The current type is \(self.currentType)")
        stopListeningForGame()
        gamesListenerRegistration = GameCollectionManager.shared.startListeningByGameType(filterBy: currentType){
            self.tableView.reloadData()
        }
        buttonViewUpdate()
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
        return GameCollectionManager.shared.latestGames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ktypeGamesCell, for: indexPath) as! TypeGamesTableCell
        let game = GameCollectionManager.shared.latestGames[indexPath.row]
        cell.gameDocumentId = game.documentId
        cell.gameCoverImageView.tag = indexPath.row
        print("nOW THE ID IS \(cell.gameDocumentId)")
        gameDocumentIdFromCellArr.append(cell.gameDocumentId)
        self.loadCover(cell: cell, game: game)
        //cell.MenuGameImage.frame = CGRect(x:0.0,y:0.0,width:100.0,height:50.0)
        circleImage(gameCoverImageView: cell.gameCoverImageView)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200.0;//Choose your custom row height
    }
    
    func goback(){
        self.navigationController?.popViewController(animated: true)
    }
    
    //helper function
    func loadCover(cell: TypeGamesTableCell, game: Game){
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
                                cell.gameCoverImageView.image = UIImage(data: data)
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
        if segue.identifier == kshowGameDetailSegue{
            let gd = segue.destination as! GameDetailViewController
            if let indexPath = tableView.indexPathForSelectedRow{
                let game = GameCollectionManager.shared.latestGames[indexPath.row]
                gd.gameDocumentId = game.documentId!
                CommentDocumentManager.shared.gameDocumentId = game.documentId
                CommentCollectionManager.shared.gameDocumentId = game.documentId
                
            }
        }
    }
    
    @objc func swipedLeft()
    {
        if(self.currentType == "ACT"){
            self.currentType = "ADV"
        }else if(currentType == "ADV"){
            self.currentType = "FPS"
        }else if(currentType == "FPS"){
            self.currentType = "SLG"
        }else if(currentType == "SLG"){
            self.currentType = "RPG"
        }
        self.startListeningForGame()
        self.tableView.reloadData()
    }
    
    @objc func swipedRight()
    {
        if(self.currentType == "ADV"){
            self.currentType = "ACT"
        }else if(currentType == "FPS"){
            self.currentType = "ADV"
        }else if(currentType == "SLG"){
            self.currentType = "FPS"
        }else if(currentType == "RPG"){
            self.currentType = "SLG"
        }
        self.startListeningForGame()
        self.tableView.reloadData()
    }
    
    
    
    
    
    
    @IBAction func pressACT(_ sender: Any) {
        currentType = "ACT"
        self.startListeningForGame()
        self.tableView.reloadData()
    }
    
    @IBAction func pressADV(_ sender: Any) {
        currentType = "ADV"
        self.startListeningForGame()
        self.tableView.reloadData()
    }
    
    @IBAction func pressFPS(_ sender: Any) {
        currentType = "FPS"
        self.startListeningForGame()
        self.tableView.reloadData()
    }
    @IBAction func pressSLG(_ sender: Any) {
        currentType = "SLG"
        self.startListeningForGame()
        self.tableView.reloadData()
    }
    @IBAction func pressRPG(_ sender: Any) {
        currentType = "RPG"
        self.startListeningForGame()
        self.tableView.reloadData()
    }
    
    func buttonViewUpdate(){
        ACTButton.backgroundColor = UIColor(red: 199/255, green: 199/255, blue: 199/255, alpha: 1)
        ADVButton.backgroundColor = UIColor(red: 199/255, green: 199/255, blue: 199/255, alpha: 1)
        FPSButton.backgroundColor = UIColor(red: 199/255, green: 199/255, blue: 199/255, alpha: 1)
        SLGButton.backgroundColor = UIColor(red: 199/255, green: 199/255, blue: 199/255, alpha: 1)
        RPGButton.backgroundColor = UIColor(red: 199/255, green: 199/255, blue: 199/255, alpha: 1)
        
        ACTButton.titleLabel?.tintColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.3)
        ADVButton.titleLabel?.tintColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.3)
        FPSButton.titleLabel?.tintColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.3)
        SLGButton.titleLabel?.tintColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.3)
        RPGButton.titleLabel?.tintColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.3)
        
        if(self.currentType == "ACT"){
            ACTButton.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 0.8)
            ACTButton.titleLabel?.tintColor = UIColor.white
            
        }else if(self.currentType == "ADV"){
            ADVButton.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 0.8)
            ADVButton.titleLabel?.tintColor = UIColor.white
            
        }else if(self.currentType == "FPS"){
            FPSButton.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 0.8)
            FPSButton.titleLabel?.tintColor = UIColor.white
            
        }else if(self.currentType == "SLG"){
            SLGButton.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 0.8)
            SLGButton.titleLabel?.tintColor = UIColor.white
            
        }else if(self.currentType == "RPG"){
            RPGButton.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 0.8)
            RPGButton.titleLabel?.tintColor = UIColor.white
            
        }
    }
    
}
