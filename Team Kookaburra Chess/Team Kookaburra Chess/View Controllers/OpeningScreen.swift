//
//  LaunchScreen.swift
//  Team Kookaburra Chess
//
//  Created by Meghan Stovall on 3/19/19.
//  Copyright © 2019 Christopher Blake Cassell Erquiaga. All rights reserved.
//

import UIKit
import Foundation
import GameKit


class OpeningScreen: UIViewController {
    
    @IBOutlet weak var gameTitle: UILabel!
    @IBOutlet weak var rankImage: UIImageView!
    @IBOutlet weak var demotionImage: UIImageView!
    @IBOutlet weak var promotionImage: UIImageView!
    @IBOutlet weak var levelUpBar: UIProgressView!
    @IBOutlet weak var levelDownBar: UIProgressView!
    @IBOutlet weak var banner: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    
    var goingUp = true //only for testing
    var timer = Timer() //only for testing
    // var currentAlert = UIAlertController()
    var bannerTimer = Timer() //for closing the banners that pop up
    var imageView = UIImageView()
    var model: GameModel
    
    var currentPlayerColor : UIColor =  .white
    
    required init?(coder aDecoder: NSCoder) {
        self.model = GameModel()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad(){
        model = GameModel()
        levelUpBar.transform.scaledBy(x: 1, y: 9)
        levelDownBar.transform.scaledBy(x: 1, y: 9)
        UserDefaults.standard.setValue(false, forKey:"_UIConstraintBasedLayoutLogUnsatisfiable")
        imageView = UIImageView(frame: CGRect(x: 0, y: view.frame.size.width/2, width: view.frame.size.width, height: view.frame.size.width/2.25))
        // scheduledTimerWithTimeInterval()//only for testing
        //        UserDefaults.standard.set(0, forKey: "playerGold")
        //        UserDefaults.standard.set(0, forKey: "playerRank")
        //        UserDefaults.standard.set(0, forKey: "rankingPoints")
        let owned = UserDefaults.standard.array(forKey: "ownedPieces")
        if owned?.count ?? 0 <= 0{
            let pieceArray = ["Archer", "Ballista", "Basilisk", "Battering Ram", "Bishop", "Bombard", "Camel", "Centaur", "Demon", "Dragon Rider", "Dwarf", "Elephant", "Fire Dragon", "Footsoldier", "Gargoyle", "Ghost Queen", "Goblin", "Griffin", "Ice Dragon", "Knight", "Left Handed Elf Warrior", "Mage", "Man at Arms", "Manticore", "Minotaur", "Monk", "Monopod", "Ogre", "Orc Warrior", "Pawn", "Pikeman", "Queen", "Right Handed Elf Warrior", "Rook", "Royal Guard", "Scout", "Ship", "Superking", "Swordsman", "Trebuchet", "Unicorn"]
            UserDefaults.standard.set(pieceArray, forKey: "ownedPieces")
        }
        super.viewDidLoad()
        UserDefaults.standard.synchronize()
        demotionImage.image = UIImage(named: "demotionSymbol.png")
        let points = UserDefaults.standard.integer(forKey: "rankingPoints")
        let rank = UserDefaults.standard.integer(forKey: "playerRank")
        if points < 0 && rank == 0 {//bronze players can't have negaative points
            UserDefaults.standard.set(0, forKey: "rankingPoints")
        }
        //levels the player up if they get enough points
        if points > 14{
            promotionPopup()
            if rank == 3{
                //gold + 1000
            } else {
                var rank = UserDefaults.standard.integer(forKey: "playerRank")
                rank = rank + 1
                UserDefaults.standard.set(rank, forKey: "playerRank")
            }
            UserDefaults.standard.set(0, forKey: "rankingPoints")
        } else if points < -10{//level player down if they don't have enough points
            if rank > 0{
                var rank = UserDefaults.standard.integer(forKey: "playerRank")
                rank = rank - 1
                UserDefaults.standard.set(rank, forKey: "playerRank")
                demotionPopup()
            }
            UserDefaults.standard.set(0, forKey: "rankingPoints")
        } else if rank == 1{
            if points < 0 {//bronze players can't have negaative points
                UserDefaults.standard.set(0, forKey: "rankingPoints")
            }
        }
        if rank == 3{//diamond
            promotionImage.image = UIImage(named: "championTrophy.png")
            rankImage.image = UIImage(named: "rankDiamond.png")
        } else { //bronze, silver, or gold
            promotionImage.image = UIImage(named: "promotionSymbol.png")
            if rank == 0{
                rankImage.image = UIImage(named: "rankBronze.png")
            } else if rank == 1{
                rankImage.image = UIImage(named: "rankSilver.png")
            } else {
                rankImage.image = UIImage(named: "rankGold.png")
            }
        }
        let transform = CGAffineTransform(rotationAngle: 3.14159)// Flip view horizontally?
        levelDownBar.transform = transform
        //levelDownBar.progress = 0.75 //for test
        if points < 0 {
            levelDownBar.progress = Float(points)/(-10.0)
            levelUpBar.progress = 0.01
        } else if points > 0 {
            levelUpBar.progress = Float(points)/15.0
            levelDownBar.progress = 0.01
        } else {
            levelDownBar.progress = 0.01
            levelUpBar.progress = 0.01
        }
        GameCenterHelper.helper.viewController = self
        didMove()
    }
    
    func promotionPopup(){
        let rank = UserDefaults.standard.integer(forKey: "playerRank")
        var image = UIImage(named: "silverPromotionBanner.png")
        if rank == 1{
            image = UIImage(named: "goldPromotionBanner.png")
        } else if rank == 2{
            image = UIImage(named: "diamondPromotionBanner.png")
        } else if rank == 3{
            image = UIImage(named: "championBanner.png")
            goingUp = false//only for testing
        }
        imageView.image = image
        view.addSubview(imageView)
        closeBannerTimer()
    }
    
    func demotionPopup(){
        let rank = UserDefaults.standard.integer(forKey: "playerRank")
        var image = UIImage(named: "bronzeDemotionBanner.png")
        if rank == 0{
            image = UIImage(named: "bronzeDemotionBanner.png")
        } else if rank == 1{
            image = UIImage(named: "silverDemotionBanner.png")
        } else if rank == 2{
            image = UIImage(named: "goldDemotionBanner.png")
            goingUp = false//only for testing
        }
        imageView.image = image
        view.addSubview(imageView)
        closeBannerTimer()
    }
    
    
    //thanks, StackOverflow users Mohammad Nurdin and David Zorychta
    //only called in testing
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: Selector(("updateCounting")), userInfo: nil, repeats: true)
    }
    
    //only called in testing
    @objc func updateCounting(){
        var points = UserDefaults.standard.integer(forKey: "rankingPoints")
        if goingUp{
            points = points + 1
        } else {
            points = points - 1
        }
        UserDefaults.standard.set(points, forKey: "rankingPoints")
        UserDefaults.standard.synchronize()
        self.viewDidLoad()
    }
    
    func closeBannerTimer(){
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: Selector(("hideBanner")), userInfo: nil, repeats: true)
        print("closing time")
    }
    
    @objc func hideBanner(){
        print("you don't have to go home but you can't stay here")
        //currentAlert.dismiss(animated: true, completion: nil)
        imageView.image = nil
        bannerTimer.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func storeButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "StoreSegue", sender: self)
    }
    
    @IBAction func myStatsButtonPressed(_ sender: Any) {
        GameCenterHelper.helper.showLeaderBoard()
    }
    
    @IBAction func playButtonPressed(_ sender: Any) {
        GameCenterHelper.helper.presentMatchmaker()
    }
    
    @IBAction func quickTestButtonPressed(_ sender: Any) {
        //self.performSegue(withIdentifier: "QuickTestSegue", sender: self)
        
        currentPlayerColor = .white
        performSegue(withIdentifier: "PlacePiecesSegue", sender: nil)
        
        currentPlayerColor = .black
        performSegue(withIdentifier: "PlacePiecesSegue", sender: nil)
        
        // performSegue(withIdentifier: "LocalMatchSegue", sender: self)
    }
    
    
    @IBAction func rankPointsTest(_ sender: Any) {
        NSLog("Points please")
        var points = UserDefaults.standard.integer(forKey: "rankingPoints")
        points = points + 2
        UserDefaults.standard.set(points, forKey: "rankingPoints")
        UserDefaults.standard.synchronize()
        self.viewDidLoad()
    }
    
    func didMove() {
        print("didMove called")
        //feedbackGenerator.prepare()
        GameCenterHelper.helper.currentMatch = nil
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(authenticationChanged(_:)),
            name: .authenticationChanged,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(presentGame(_:)),
            name: .presentGame,
            object: nil
        )
        
        //self.viewDidLoad()
    }
    
    //original from Nine Knights
    //    override func didMove(to view: SKView) {
    //        super.didMove(to: view)
    //
    //        feedbackGenerator.prepare()
    //        GameCenterHelper.helper.currentMatch = nil
    //
    //        NotificationCenter.default.addObserver(
    //            self,
    //            selector: #selector(authenticationChanged(_:)),
    //            name: .authenticationChanged,
    //            object: nil
    //        )
    //
    //        NotificationCenter.default.addObserver(
    //            self,
    //            selector: #selector(presentGame(_:)),
    //            name: .presentGame,
    //            object: nil
    //        )
    //
    //        setUpScene(in: view)
    //    }
    @objc private func authenticationChanged(_ notification: Notification) {
        playButton.isEnabled = notification.object as? Bool ?? false
    }
    
    @objc private func presentGame(_ notification: Notification) {
        print("presentGame called")
        // 1
        guard let match = notification.object as? GKTurnBasedMatch else {
            return
        }
        
        loadAndDisplay(match: match)
    }
    
    // MARK: - Helpers
    
    private func loadAndDisplay(match: GKTurnBasedMatch) {
        // 2 try loading current game data, or start new game if no data
        
        var noMatchData: Bool = false
        
        match.loadMatchData { data, error in
            if let data = data {
                do {
                    // 3
                    print("tried jsondecoding")
                    self.model = try JSONDecoder().decode(GameModel.self, from: data)
                } catch {
                    print("creating blank gamemodel since decoding failed")
                    noMatchData = true
                }
            } else {
                print("creating blank gamemodel since data is nil")
                noMatchData = true
            }
            
            if (noMatchData) {
                // need to start a new Match
                self.model = GameModel()
                
                
                
            }
            // make sure we are added to the game (no harm if already added)
            self.model.addPlayer()
            
            
            
            GameCenterHelper.helper.currentMatch = match
            
            if ( self.model.localPlayerUIColor() == .white) {
                print("Local Player is White")
            } else {
                
                print("Local Player is BLACK")
                
            }
            
            // set up pieces for player's initial position, or go to board for your turn
            if (self.model.piecesAreSet) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.performSegue(withIdentifier: "OnlineChessVCSegue", sender: self)
                }
                
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.performSegue(withIdentifier: "OnlinePlacePiecesSegue", sender: self)
                }
            }
            
            
            return
            
            
            
            
            //
            //            print("piecesAreSet: \(self.model.piecesAreSet)")
            //            //if self.model.piecesAreSet{
            //            print("online segue attempted")
            //            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            //                print("opening screen model.piecesAreSet = \(self.model.piecesAreSet). model.blackHasPlacedPieces = \(self.model.blackHasSetPieces). model.whiteHasPlacedPieces = \(self.model.whiteHasSetPieces)")
            //                if (self.model.piecesAreSet){
            //                    self.performSegue(withIdentifier: "OnlineChessVCSegue", sender: self)
            //                } else {
            //                    self.self.performSegue(withIdentifier: "PlacePiecesSegue", sender: self)
            //                }
            //            }
            
            //            } else {
            //                self.performSegue(withIdentifier: "PlacePiecesSegue", sender: self)
            //            }
            
            
            //convert UIView to SKView
            //let gameVC = ChessVC(coder: <#NSCoder#>)
            //            print("about to segue into online")
            //            self.performSegue(withIdentifier: "OnlineChessVCSegue", sender: self)
            //self.present(gameVC, animated: true, completion: nil)
            //self.dismiss(animated: true, completion: nil)//maybe use this to dismiss the openingScreen instead of stacking more viewcontrollers
            
            //don't think I actually need to make GameScene like in Nine Knights
            //            let skView = gameVC.view as! SKView
            //            skView.presentScene(GameScene(model: model))
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "OnlineChessVCSegue") {
            print("prepare for onlineChessVCSegue called")
            let vc = segue.destination as! ChessVC
            vc.model = self.model
            vc.isLocalMatch = false
        } else if (segue.identifier == "OnlinePlacePiecesSegue") {
            print("prepare for OnlinePlacePiecesSegue called")
            let vc = segue.destination as! PlacePiecesViewController
            vc.model = self.model
            vc.isLocalMatch = false
            // print("model being passed in to OnlinePlacePiecesSegue. currentPlayer = \(model.currentPlayer) and isWhiteTurn = \(model.isWhiteTurn)")
        }
        else if segue.identifier == "PlacePiecesSegue" {
            let vc = segue.destination as! PlacePiecesViewController
            vc.playerColor = currentPlayerColor
        }
    }
    
    //original code from tutorial
    //    private func loadAndDisplay(match: GKTurnBasedMatch) {
    //        // 2
    //        match.loadMatchData { data, error in
    //            let model: GameModel
    //
    //            if let data = data {
    //                do {
    //                    // 3
    //                    model = try JSONDecoder().decode(GameModel.self, from: data)
    //                } catch {
    //                    model = GameModel()
    //                }
    //            } else {
    //                model = GameModel()
    //            }
    //              GameCenterHelper.helper.currentMatch = match
    //            // 4
    //            self.view?.presentScene(GameScene(model: model), transition: self.transition)
    //        }
    //    }
    //    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
    //        print("Match found")
    //        if match.expectedPlayerCount == 0 {
    //            viewController.dismiss(animated: true, completion: {self.goToGame(match: match)})
    //        }
    //    }
    
    //    func goToGame(match: GKMatch) {
    //        let gameScreenVC = self.storyboard?.instantiateViewController(withIdentifier: "mainGame") as! ViewController
    //        gameScreenVC.providesPresentationContextTransitionStyle = true
    //        gameScreenVC.definesPresentationContext = true
    //        gameScreenVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
    //        gameScreenVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
    //        gameScreenVC.match = match
    //        self.present(gameScreenVC, animated: true, completion: nil)
    
}
