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
    @IBOutlet weak var labelMinus10: UILabel!
    @IBOutlet weak var label15: UILabel!
    @IBOutlet weak var rankImage: UIImageView!
    @IBOutlet weak var demotionImage: UIImageView!
    @IBOutlet weak var promotionImage: UIImageView!
    @IBOutlet weak var levelUpBar: UIProgressView!
    @IBOutlet weak var levelDownBar: UIProgressView!
    @IBOutlet weak var banner: UIImageView!
    var goingUp = true //only for testing
    var timer = Timer() //only for testing
   // var currentAlert = UIAlertController()
    var bannerTimer = Timer() //for closing the banners that pop up
    var imageView = UIImageView()
    
    override func viewDidLoad(){
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
        labelMinus10.text = "-10"
        label15.text = "15"
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
        rankPointsLabel.text = ("Ranking points: \(points)")
        let transform = CGAffineTransform(rotationAngle: 3.14159); // Flip view horizontally?
        levelDownBar.transform = transform;
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
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: Selector("updateCounting"), userInfo: nil, repeats: true)
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
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: Selector("hideBanner"), userInfo: nil, repeats: true)
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
    
    
    @IBOutlet weak var rankPointsLabel: UILabel!
    
    @IBAction func myFriendButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "MyFriendsBtSegue", sender: self)
    }
    
    @IBAction func storeButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "StoreSegue", sender: self)
    }
    
    @IBAction func myStatsButtonPressed(_ sender: Any) {
        let gc = GameCenterHelper()
        gc.showLeaderBoard()
    }
    
    @IBAction func playButtonPressed(_ sender: Any) {
        GameCenterHelper.helper.presentMatchmaker()
        //self.performSegue(withIdentifier: "PlayBtOpeningScreenSegue", sender: self)
    }
    
    @IBAction func quickTestButtonPressed(_ sender: Any) {
        //self.performSegue(withIdentifier: "QuickTestSegue", sender: self)
        performSegue(withIdentifier: "PlacePiecesSegue", sender: nil)
    }
    
    @IBAction func rankPointsTest(_ sender: Any) {
        NSLog("Points please")
        var points = UserDefaults.standard.integer(forKey: "rankingPoints")
        points = points + 2
        UserDefaults.standard.set(points, forKey: "rankingPoints")
        UserDefaults.standard.synchronize()
        self.viewDidLoad()
    }
    
    @objc private func presentGame(_ notification: Notification) {
        // 1
        guard let match = notification.object as? GKTurnBasedMatch else {
            return
        }
        
        loadAndDisplay(match: match)
    }
    
    // MARK: - Helpers
    
    private func loadAndDisplay(match: GKTurnBasedMatch) {
        // 2
        match.loadMatchData { data, error in
            let model: GameModel
            
            if let data = data {
                do {
                    // 3
                    model = try JSONDecoder().decode(GameModel.self, from: data)
                } catch {
                    model = GameModel()
                }
            } else {
                model = GameModel()
            }
            
            //convert UIView to SKView
            let gameVC = ChessVC(model: model)
            let skView = gameVC.view as! SKView
            skView.presentScene(GameScene(model: model))
            //To do: add transition between views
            //work on OnlineGameScene to use that class instead
            
            //maybe try segue to gameVC instead of converting to skView
            //need to fix GameScene for this to work anyway
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
    //
    //            // 4
    //            self.view?.presentScene(GameScene(model: model), transition: self.transition)
    //        }
    //    }
    
}
