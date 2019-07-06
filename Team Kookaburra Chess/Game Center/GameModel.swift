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

enum PlayerColor: String, Codable {
    case white, black
}


//struct GameModel {
struct GameModel: Codable{
    
    
    /* ChessVC has boardCells as 2 dimensional array of BoardCell views
     each BoardCell view contains important data, which can be retrieved with
     
     BoardCell.piece.getBasicInfo -> ChessPieceBasicInfo
     
     
     */
    
    //var lastMove: Move?
    
    var piecesArray = [ChessPieceBasicInfo]()
    //var pieceNamesArray = [[String]](repeating: [String](repeating: 0, count: 8), count: 8) //8 by 8 array of Strings
    
    var winner: PlayerColor? = nil
    var forfeited: Bool = false
    var tied: Bool = false

    
    var playerColors = [PlayerColor](repeating:.white,count:2)
    
    var playerIDs = [String?]()
    
    var messageToDisplay: String {
        return ""
    }
    
    //    var isCapturingPiece: Bool {
    //        return currentMill != nil
    //    }
    
    //ignore all of this for now. I thought about going down a rabbit hole where placing pieces didn't get
    //determined based off a blank chessboard but were saved here instead.
    var whiteHasSetPieces: Bool = false
    var blackHasSetPieces: Bool = false
    var piecesAreSet: Bool = false
    //var neitherHasSetPieces = Bool() / not sure if need this. See initializer and update turn
    
    var isWhiteTurn = Bool() //pay attention to how this is used in Nine Knights
    
    init() {
        
        
        // assign random colors
        playerColors[0] = Bool.random() ? .white : .black
        playerColors[1] = (playerColors[0] == .white) ?  .black : .white
        
        
        
        //self.currentPlayer = randomPlayer()
        //neitherHasSetPieces = true
        // self.isWhiteTurn = randomPlayer() //this pattern of having this set from the parameter was in Nine Knights. Not sure why or if I should use it for other fields.
        //print("GameModel init called. isWhiteTurn = \(self.isWhiteTurn). currentPlayer = \(self.currentPlayer)")
        
        //boardCells = [BoardCell]()
        
        // chessBoard = ChessBoard(playerColor: UIColor.white)
        
    }
    
    
    mutating func addPlayer() {
        if (GKLocalPlayer.local.isAuthenticated) {
            if (!playerIDs.contains(GKLocalPlayer.local.playerID)){
                playerIDs.append(GKLocalPlayer.local.playerID)
            }
        }
    }
    
    
    func playerPiecesAreSet() -> Bool {
        
        if (!GKLocalPlayer.local.isAuthenticated || !playerIDs.contains(GKLocalPlayer.local.playerID) ) {
            print("Checking peices are set for unknown player!")
            return false
            // TODO: should throw error
        }
        
        let index = playerIDs.firstIndex(of:GKLocalPlayer.local.playerID )
        let pcolor : PlayerColor = playerColors[index!]
        
        if (pcolor == .white) {  return whiteHasSetPieces } else { return blackHasSetPieces }
        
    }
    
    func localPlayerUIColor() -> UIColor {
        
        if (!GKLocalPlayer.local.isAuthenticated || !playerIDs.contains(GKLocalPlayer.local.playerID) ) {
            print("getting color for unknown player!")
            return .white
            // TODO: should throw error
        }
        
        let pcolor : PlayerColor = playerColors[ playerIDs.firstIndex(of:GKLocalPlayer.local.playerID )!]
        
        if (pcolor == .white) {  return .white } else { return .black }
    }


    func currentPlayerTurnColor() -> UIColor {
        return isWhiteTurn ? .white : .black
    }


    func isLocalPlayerTurn() -> Bool {

        return localPlayerUIColor() == currentPlayerTurnColor();
    }



    mutating func setPlayerPiecesAreSet(piecesColor: UIColor ) {
    
        let previousPiecesAreSet = piecesAreSet
        
        if (.white == piecesColor) {
            whiteHasSetPieces = true
        }
        if (.black == piecesColor) {
            blackHasSetPieces = true
        }
        piecesAreSet = whiteHasSetPieces && blackHasSetPieces
        
        if (!previousPiecesAreSet && piecesAreSet) {
             isWhiteTurn = true
        }
    
    }
    
    mutating func checkPiecesAreSet(){
        piecesAreSet = whiteHasSetPieces && blackHasSetPieces
        if (piecesAreSet){
            isWhiteTurn = true
        }
    }


    
    func randomPlayer() -> Bool {
        //print("randomPlayer called")
        let number = Int.random(in: 0...1)
        if number == 0 {
            return isWhiteTurn
        } else {
            return !isWhiteTurn
        }
    }
    
    mutating func switchCurrentPlayer() {
    
        self.isWhiteTurn = !isWhiteTurn

        print("end of gameModel.updateturn. isWhiteTurn = \(self.isWhiteTurn)")
    }
    
    func updatePieceNamesArray(chessPieceArray: [[ChessPiece]]) -> [[String]]{
        print("updatePieceNamesArray called")
        var pieceNamesArray = [[String]]()
        for row in 0...7{
            for col in 0...7{
                //print("row: \(row), col: \(col)")
                let currentPiece = chessPieceArray[row][col]
                //print("read currentPiece")
                currentPiece.setupSymbol()
                let pieceName = currentPiece.symbol
                pieceNamesArray.append([pieceName])
            }
        }
        return pieceNamesArray
    }
    
    mutating func setInitialPieces(playerColor: UIColor, boardCells: [[BoardCell]] ) {
        
        // need to flip the position of the black pieces coming from PlacePiecesOnlyViewController
        for r in 0...7 {
            for c in 0...7 {
                var pieceBasicInfo = boardCells[r][c].piece.getBasicInfo()
                if (playerColor == .white) { //put put white at the bottom of the screen
                    pieceBasicInfo.row = 7 -  (2 - pieceBasicInfo.row)
                    pieceBasicInfo.col = 7 -  pieceBasicInfo.col
                } else { //playerColor == .black
                    //pieces need to be flipped vertically by 2 rows and horizontally by 7
                    pieceBasicInfo.row = 2 - pieceBasicInfo.row
                    pieceBasicInfo.col = 7 -  pieceBasicInfo.col
                }
                if pieceBasicInfo.type != .dummy {
                    piecesArray.append(pieceBasicInfo)
               }
            }
        }
        
       setPlayerPiecesAreSet(piecesColor: playerColor)
        
    }
    //    mutating func advance() {
    //        if tokensPlaced == maxTokenCount && state == .placement {
    //            state = .movement
    //        }
    //
    //        turn += 1
    //        currentMill = nil
    //
    //        if state == .movement {
    //            if tokenCount(for: currentOpponent) == 2 || !canMove(currentOpponent) {
    //                winner = currentPlayer
    //            } else {
    //                isKnightTurn = !isKnightTurn
    //            }
    //        } else {
    //            isKnightTurn = !isKnightTurn
    //        }
    //    }
    
    
    
    //    func canMove(_ player: Player) -> Bool {
    //        let playerTokens = tokens.filter { token in
    //            return token.player == player
    //        }
    //
    //        for token in playerTokens {
    //            let emptyNeighbors = neighbors(at: token.coord).filter({ emptyCoordinates.contains($0) })
    //            if !emptyNeighbors.isEmpty {
    //                return true
    //            }
    //        }
    //
    //        return false
    //    }


    mutating func setWinner(winning_color: UIColor) {

        winner = .white == winning_color ? .white : .black;


    }

    func isGameOver() -> Bool {

       return (nil != winner || forfeited || tied )

    }


}


