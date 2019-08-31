/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import GameKit

final class GameCenterHelper: NSObject, GKGameCenterControllerDelegate {
    
    var numberOfTotalWins = Int()
    var numberOfTotalLoses = Int()
    var winStreak = Int()
    var loseStreaks = Int()
    var totalGamesPlayed = Int()
    
    typealias CompletionBlock = (Error?) -> Void
    
    static let helper = GameCenterHelper()
    
    static var isAuthenticated: Bool {
        return GKLocalPlayer.local.isAuthenticated
    }
    
    var viewController: UIViewController?
    var currentMatchmakerVC: GKTurnBasedMatchmakerViewController?
    
    enum GameCenterHelperError: Error {
        case matchNotFound
    }
    
    var currentMatch: GKTurnBasedMatch?
    
    var canTakeTurnForCurrentMatch: Bool {
        guard let match = currentMatch else {
            return true
        }

        return match.isLocalPlayersTurn
    }
    
    override init() {
        super.init()
        
        GKLocalPlayer.local.authenticateHandler = { gcAuthVC, error in
            NotificationCenter.default.post(name: .authenticationChanged, object: GKLocalPlayer.local.isAuthenticated)
            
            if GKLocalPlayer.local.isAuthenticated {
                GKLocalPlayer.local.register(self)
            } else if let vc = gcAuthVC {
                print("init viewcont: \(String(describing: self.viewController))")
                self.viewController?.present(vc, animated: true)
            }
            else {
                print("Error authentication to GameCenter: \(error?.localizedDescription ?? "none")")
            }
        }
    }
    
    func presentMatchmaker() {
        guard GKLocalPlayer.local.isAuthenticated else {
            return
        }
        
        let request = GKMatchRequest()
        
        request.minPlayers = 2
        request.maxPlayers = 2
        request.inviteMessage = "Would you like to play Alchemist Chess?"
        let rank = UserDefaults.standard.integer(forKey: "rank")
        if winStreak > 5{
            request.playerGroup = 0//anybody
        }
        if rank == 0{//bronze
            request.playerGroup = 1 | 2//bronze and silver only
        } else if rank == 1{//silver
            request.playerGroup = 1|2|3 //bronze, silver, or gold
        } else if rank == 2{//gold
            request.playerGroup = 2|3|4 //silver, gold, or diamond
        } else if rank == 3{//diamond
            request.playerGroup = 3|4 //only gold and diamond
        }
        let vc = GKTurnBasedMatchmakerViewController(matchRequest: request)
        vc.turnBasedMatchmakerDelegate = self
        
        currentMatchmakerVC = vc
        print("mm viewcont: \(String(describing: self.viewController))")

        viewController?.present(vc, animated: true)
    }
    
    func endTurn(_ model: GameModel, completion: @escaping CompletionBlock) {
        print("helper.endTurn called")
        guard let match = currentMatch else {
            completion(GameCenterHelperError.matchNotFound)
            return
        }

        do {
            match.message = model.messageToDisplay

            match.endTurn(
                withNextParticipants: match.others,
                turnTimeout: GKExchangeTimeoutDefault,
                match: try JSONEncoder().encode(model),
                completionHandler: completion
            )
        } catch {
            completion(error)
        }
        print("helper.endTurn completed")
    }
    
    func win(completion: @escaping CompletionBlock) {
        guard let match = currentMatch else {
            completion(GameCenterHelperError.matchNotFound)
            return
        }

        match.currentParticipant?.matchOutcome = .won
        match.message = "Game Completed"
        match.others.forEach { other in
            other.matchOutcome = .lost
        }
        
        //keeps track of number of total wins and loses
        if match.currentParticipant?.matchOutcome == .won {
            numberOfTotalWins += 1
        } else {
            numberOfTotalLoses += 1
        }

        match.endMatchInTurn(
            withMatch: match.matchData ?? Data(),
            completionHandler: completion
        )
    }
    
    func winStreaks(completion: @escaping CompletionBlock, number: Int){
        guard let match = currentMatch else {
            completion(GameCenterHelperError.matchNotFound)
            return
        }
        
        if match.currentParticipant?.matchOutcome == .won {
            winStreak += 1
        }
        
        //this created the array of all players win streaks and creates the leaderboard
        if GKLocalPlayer.local.isAuthenticated {
            let my_leaderboard_id = "Win_Streaks"
            
            let winStreakReporter = GKScore(leaderboardIdentifier: my_leaderboard_id)
            
            winStreakReporter.value = Int64(number)
            
            let winStreakArray : [GKScore] = [winStreakReporter]
            
            GKScore.report(winStreakArray, withCompletionHandler: nil)
        }
        
    }
    
    func loseStreaks(completion: @escaping CompletionBlock, number: Int){
        guard let match = currentMatch else {
            completion(GameCenterHelperError.matchNotFound)
            return
        }
        
        if match.currentParticipant?.matchOutcome != .won {
            loseStreaks += 1
        }
        
        //this created the array of all players win streaks and creates the leaderboard
        if GKLocalPlayer.local.isAuthenticated {
            let my_leaderboard_id = "Lose_Streak"
            
            let loseStreakReporter = GKScore(leaderboardIdentifier: my_leaderboard_id)
            
            loseStreakReporter.value = Int64(number)
            
            let loseStreakArray : [GKScore] = [loseStreakReporter]
            
            GKScore.report(loseStreakArray, withCompletionHandler: nil)
        }
    }
    
    //this method conects the number of total wins to the leader board Wins
    func saveTotalWinsToLeaderBoard(number: Int){
        
        if GKLocalPlayer.local.isAuthenticated {
            let my_leaderboard_id = "Wins"
            
            let winReporter = GKScore(leaderboardIdentifier: my_leaderboard_id)
            
            winReporter.value = Int64(number)
            
            let winArray : [GKScore] = [winReporter]
            
            GKScore.report(winArray, withCompletionHandler: nil)
        }
    }
    
    func totalGamesPlayedLeaderBoard(number: Int){
        if GKLocalPlayer.local.isAuthenticated {
            let my_leaderboard_id = "Most_Games_Played"
            
            let mostGamesPlayedReporter = GKScore(leaderboardIdentifier: my_leaderboard_id)
            
            mostGamesPlayedReporter.value = Int64(number)
            
            let mostGamesPlayedArray : [GKScore] = [mostGamesPlayedReporter]
            
            GKScore.report(mostGamesPlayedArray, withCompletionHandler: nil)
        }
    }
    
    //thismethod was also taken from the tutorial and is explained in this link //https://www.youtube.com/watch?v=TziN1O2x7pM
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    //This function I got from a tutorial and needs some fixes and editing in order for us to be able to use in our game
    func showLeaderBoard(){
        let gkGCViewController = GKGameCenterViewController()

        gkGCViewController.gameCenterDelegate = self

        viewController?.present(gkGCViewController, animated: true, completion: nil)
    }
    
}

extension GameCenterHelper: GKTurnBasedMatchmakerViewControllerDelegate {
    func turnBasedMatchmakerViewControllerWasCancelled(_ viewController: GKTurnBasedMatchmakerViewController) {
        viewController.dismiss(animated: true)
    }
    
    func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController, didFailWithError error: Error) {
        print("Matchmaker vc did fail with error: \(error.localizedDescription).")
    }
}

extension GameCenterHelper: GKLocalPlayerListener {
    func player(_ player: GKPlayer, wantsToQuitMatch match: GKTurnBasedMatch) {
        let activeOthers = match.others.filter { other in
            return other.status == .active
        }
        
        match.currentParticipant?.matchOutcome = .lost
        activeOthers.forEach { participant in
            participant.matchOutcome = .won
        }
        
        match.endMatchInTurn(
            withMatch: match.matchData ?? Data()
        )
    }
    
    func player(_ player: GKPlayer, receivedTurnEventFor match: GKTurnBasedMatch, didBecomeActive: Bool) {
        if let vc = currentMatchmakerVC {
            currentMatchmakerVC = nil
            vc.dismiss(animated: true)
        }

         // ignore guard, go ahead and display the game, even if not our turn?
//        guard didBecomeActive else {
//            return
//        }
        print("receivedTurnEvent for me \(didBecomeActive)");
        NotificationCenter.default.post(name: .presentGame, object: match)
    }
}

extension Notification.Name {
    static let presentGame = Notification.Name(rawValue: "presentGame")
    static let authenticationChanged = Notification.Name(rawValue: "authenticationChanged")
}
