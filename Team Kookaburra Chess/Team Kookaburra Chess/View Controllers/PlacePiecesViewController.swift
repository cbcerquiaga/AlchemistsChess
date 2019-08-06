//
//  PlacePiecesViewController.swift
//  Team Kookaburra Chess
//
//  Created by Meghan Stovall on 3/30/19.
//  Copyright © 2019 Christopher Blake Cassell Erquiaga. All rights reserved.
//

import Foundation

import UIKit
import SpriteKit

class PlacePiecesViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, ChessBoardDelegate {
    //ChessBoard Delegate functions
    
    func boardUpdated() {
        //print("Board updated")
        for row in 0...2 {
            for col in 0...7 {
                let cell = boardCells[row][col]
                let piece = chessBoard.board[row][col]
                cell.configureCell(forPiece: piece)
            }
        }
        
    }
    
    //@IBOutlet SKView: skView;
    
    func gameOver(withWinner winner: UIColor) {
        //only here to fill protocol
    }
    
    func gameTied() {
        //only here to fill protocol
    }
    
    func promote(pawn: ChessPiece) {
        //only here to fill protocol
    }
    
    var playerColor = UIColor.white
    
    //var player: GameModel.Player = GameModel.Player("white")
    var playerPoints: Int = 0
    var chessBoard = ChessBoard(playerColor: .white)
    var boardCells = [[BoardCell]]()
    //var boardCells = Array(repeating: Array(repeating: BoardCell(row: 5, column: 5, piece: ChessPiece(row: 5, column: 5, color: .clear, type: .dummy, player: UIColor.white), color: .clear), count: 8), count: 8)
    var pieceBeingMoved: ChessPiece? = nil
    var possibleMoves = [BoardIndex]()
    var playerTurn = UIColor.white
    var pickerData: [String] = [String]()
    var highlightedCell: BoardCell = BoardCell(row: 0, col: 0, piece: ChessPiece(row: 0, column: 0, color: .clear, type: .dummy, player: .white), color: .white)
    var p2BoardCells = [[BoardCell]]()
    var isLocalMatch = true
    var model: GameModel = GameModel()
    
    @IBOutlet weak var placeButton: UIButton!
    @IBOutlet weak var quantLabel: UILabel!
    @IBOutlet weak var pointsRemaining: UILabel!
    @IBOutlet weak var yourColor: UILabel!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var pieceCost: UILabel!
    @IBOutlet weak var piecePicture: UIImageView!
    @IBOutlet weak var pieceInfo: UILabel!
    @IBOutlet weak var piecePicker: UIPickerView!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var readyButton: UIButton!
    @IBOutlet weak var homeButton: UIButton!
    
    var pickerString: String = ""
    var chosenPieces = [[ChessPiece]]()
    
    override func viewDidLoad(){
        print("place pieces viewDidLoad called. model.blackHasPlacedPieces = \(model.blackHasSetPieces). model.whiteHasPlacedPieces = \(model.whiteHasSetPieces)")
        
        super.viewDidLoad()
        // TODO: reset from self.model if !isLocalMatch
        
        if (!isLocalMatch) {
            playerColor =  self.model.localPlayerUIColor()
        }
        
        setLabels()
        drawBoard()
        addStarterKing()
        piecePicker.delegate = self
        piecePicker.dataSource = self
        pickerData = ["Empty", "King"]
        var ownedPieces: [String]
        ownedPieces = UserDefaults.standard.array(forKey: "ownedPieces") as! [String]
        ownedPieces.sort()
        for piece in ownedPieces{
            pickerData.append(piece)
        }
        piecePicker.selectRow(0, inComponent: 0, animated: true)
        piecePicker.selectRow(0, inComponent: 0, animated: true)
        //get the string from the picker
        pickerString = pickerData[0]
        //compare that string to the piece types
        let piece = getPiece(string: pickerString)
        //assign the .png file to the UIImageview
        piece.setupSymbol()
        piecePicture.image = piece.symbolImage
        //assign info text to the info label
        pieceInfo.text = getInfo(piece: piece)
        pieceInfo.contentMode = .scaleToFill
        pieceInfo.numberOfLines = 0
        //assign cost to the top label
        pieceCost.text = "\(piece.summonCost) points to summon"
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "LocalMatchSegue") {
            let vc = segue.destination as! ChessVC
            vc.model = model
            //vc.playerColor = playerColor
            vc.playerColor = .white
            vc.isLocalMatch = true
            //            if playerColor == .white{
            //                vc.whiteFormation = boardCells
            //                vc.blackFormation = p2BoardCells
            //            } else {//playerColor == .black
            //                vc.blackFormation = boardCells
            //                vc.whiteFormation = p2BoardCells
            //            }
            vc.chessBoard.board = combineFormations()
        }
        if (segue.identifier == "OnlineMatchSegue") {
            let vc = segue.destination as! ChessVC
            vc.model = model
            vc.isLocalMatch = false
        }
        if (segue.identifier == "ReturnToMenuSegue") {
            
            let vc = segue.destination as! OpeningScreen
            
        }
    }
    
    /* needed for local match */
    func combineFormations() -> [[ChessPiece]]{
        var whiteFormation = [[BoardCell]]()
        var blackFormation = [[BoardCell]]()
        if (!isLocalMatch) {
            if playerColor == .white{
                whiteFormation = boardCells
                if model.blackHasSetPieces{
                    blackFormation = p2BoardCells
                } else {
                    blackFormation = Array(repeating: Array(repeating: BoardCell(row: 5, col: 5, piece: ChessPiece(row: 5, column: 5, color: .clear, type: .dummy, player: UIColor.white), color: .clear), count: 8), count: 8)
                }
            } else {//playerColor == .black
                blackFormation = boardCells
                if model.whiteHasSetPieces{
                    whiteFormation = p2BoardCells
                } else {
                    whiteFormation = Array(repeating: Array(repeating: BoardCell(row: 5, col: 5, piece: ChessPiece(row: 5, column: 5, color: .clear, type: .dummy, player: UIColor.white), color: .clear), count: 8), count: 8)
                }
            }
        } else { //local match
            print("local match takeFormations called")
            if playerColor == .white{
                whiteFormation = boardCells
                blackFormation = p2BoardCells
            } else {
                blackFormation = boardCells
                whiteFormation = p2BoardCells
            }
            
        }
        let fullBoard = ChessBoard(playerColor: UIColor.white)
        fullBoard.board = fullBoard.takeFormations(black: blackFormation, white: whiteFormation)
        return fullBoard.board
    }
    
    /* needed for online */
    
    func goToMain(){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "OpeningScreen") as UIViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    func setLabels(){
        quantLabel.text = "/450"
        pointsRemaining.text = "Points spent: \(playerPoints)"
        if playerColor == .white{
            yourColor.text = "You are white this match"
        } else {
            yourColor.text = "You are black this match"
        }
        tipLabel.text = "Tap a square to select a space and start placing pieces!"
        let piece = getPiece(string: pickerString)
        pieceInfo.text = getInfo(piece: piece)
    }
    
    //players get confused, so we should have a king out there to start. Having it in the regular chess position makes the most sense
    func addStarterKing(){
        var king = ChessPiece(row: 0, column: 0, color: playerColor, type: .king, player: playerColor)
        king.setupSymbol()
        if playerColor == .white{
            king.row = 2
            king.col = 3
            //print(boardCells)
            boardCells[2][3].piece = king
            boardCells[2][3].configureCell(forPiece: king)
        } else if playerColor == .black{
            print("addStarterKing black called")
            king.row = 2
            king.col = 4
            boardCells[2][4].piece = king
            boardCells[2][4].configureCell(forPiece: king)
        }
        playerPoints = calculateCost()
        pointsRemaining.text = "Points spent: \(playerPoints)"
    }
    
    func drawBoard(){
        print("place pieces drawBoard called.")
        if (playerColor == UIColor.white) {
            print("playerColor = white at drawBoard")
        } else {
            print("playerColor = black at drawBoard")
        }
        let numRows:Int = 8
        let numCols:Int = 8
        let oneRow = Array(repeating: BoardCell(row: 5, col: 5, piece: ChessPiece(row: 5, column: 5, color: .clear, type: .dummy, player: playerColor), color: .clear), count: 8)
        self.boardCells = Array(repeating: oneRow, count: numRows)
        let cellDimension = (view.frame.size.width - 0) / CGFloat(numCols)
        var xOffset: CGFloat = 0
        var yOffset: CGFloat = 0
        let start_row = 0
        let end_row = 2
        for row in start_row...end_row {
            
            yOffset = (CGFloat(row - start_row) * cellDimension) + cellDimension*3//200
            
            for col in 0...7 {
                
                xOffset = (CGFloat(col) * cellDimension) + 0
                
                // create a piece
                let piece = ChessPiece(row: row, column: col, color: .white, type: .dummy, player: .white)
                
                // create a cell at this location with this piece, and set color
                let cell = BoardCell(row: row, col: col, piece: piece, color: .white)
                
                // NSLog("Board cells at row, col: \(boardCells[row][col])")
                
                cell.frame = CGRect(x: xOffset, y: yOffset, width: cellDimension, height: cellDimension)
                if (row % 2 == 0 && col % 2 == 0) || (row % 2 != 0 && col % 2 != 0) {
                    cell.color = #colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)
                } else {
                    cell.color = #colorLiteral(red: 0.5787474513, green: 0.3215198815, blue: 0, alpha: 1)
                }
                
                cell.removeHighlighting()
                
                // wire up the cell
                cell.delegate = self
                //print("place pieces- drawBoard at row: \(row), col: \(col)")
                chessBoard.board[row][col] = piece
                self.boardCells[row][col] = cell
                
                
                view.addSubview(cell)
            }
        }
    }
    
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) ->Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func clearPieces(){
        drawBoard()
        playerPoints = calculateCost()
        pointsRemaining.text = "Points spent: \(playerPoints)"
    }
    
    
    @IBAction func placeButtonPressed(_ sender: Any) {
        //check that for chess piece type
        let chosenPiece = getPiece(string: pickerString)
        chosenPiece.setupSymbol()
        //check if the piece is illegally placed
        var cost = chosenPiece.summonCost
        if chosenPiece.type == .king{
            //NSLog("All hail!")
            if numKings(color: playerColor) > 0{
                cost = cost + 20
            }
        }
        if (playerPoints + cost) > 450 {
            //NSLog("Too many points spent")
            tipLabel.text = "Not enough points for that piece"
            let ac = UIAlertController(title: "Points", message: "You don't have enough points for that piece", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            ac.addAction(ok)
            present(ac, animated: true, completion: nil)
        } else{
            //NSLog("check if the piece is illegally placed")
            //check if the piece is illegally placed
            if ((chosenPiece.type == .dragonRider)){
                
                if  highlightedCell.row != 2{
                    //NSLog("Dragonriders can only be in the back row")
                    tipLabel.text = "Dragonriders can only be in the back row."
                    let ac = UIAlertController(title: "Rule", message: "Dragon Riders can only be placed in the back row", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    ac.addAction(ok)
                    present(ac, animated: true, completion: nil)
                    return
                } //else if highlightedCell.row == 2 && !secondRowFull(){
                //change the tip label
                //show a notification, "piece can't be placed because of rule"
                //}
            }
            if highlightedCell.row == 0{
                //print("front row")
                if chosenPiece.type != .dummy{
                    //print("not empty piece")
                    if secondRowFull() == false{
                        tipLabel.text = "Can't place in front row until 2nd row is full."
                        let ac = UIAlertController(title: "Rule", message: "You can't place pieces in the front row until you fill the middle row.", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                        ac.addAction(ok)
                        present(ac, animated: true, completion: nil)
                        return
                    }
                }
            } else if highlightedCell.row == 1{
                if chosenPiece.type == .dummy{
                    self.clearFrontRow()
                    self.tipLabel.text = "Fill the second row to be able place in the front row"
                }
            }
            chosenPiece.row = highlightedCell.row
            chosenPiece.col = highlightedCell.col
            highlightedCell.configureCell(forPiece: chosenPiece)
            //var changedBoardCell = self.boardCells[highlightedCell.row][highlightedCell.column]
            //NSLog("boardcell changed: \(changedBoardCell.piece.type)")
            //add summon points
            //print("points before: \(playerPoints)")
            playerPoints = calculateCost()
            //print("points after: \(playerPoints)")
            pointsRemaining.text = "Points spent: \(playerPoints)"
            //chosenPieces[highlightedCell.row][highlightedCell.column] = chosenPiece
            //NSLog("chosen pieces: \(chosenPieces)")
            //}
            //}
            didSelect(cell: highlightedCell, atRow: highlightedCell.row, andColumn: highlightedCell.col)
        }
        
    }
    
    //returns if the highlighted cell is in the front row
    func isFrontRow() -> Bool{
        if ((highlightedCell.row == 2) || (highlightedCell.row == 5)){
            return true
        }
        return false
    }
    
    func secondRowFull() -> Bool{
        for col in 0...7 {
            let piece = boardCells[1][col].piece
            if (piece.type == .dummy) {
                return false
            }
        }
        return true
    }
    
    //    func clearFrontRow(){
    //        let numRows:Int = 8
    //        let numCols:Int = 8
    //        let oneRow = Array(repeating: BoardCell(row: 5, column: 5, piece: ChessPiece(row: 5, column: 5, color: .clear, type: .dummy, player: playerColor), color: .clear), count: 8)
    //        self.boardCells = Array(repeating: oneRow, count: numRows)
    //        let cellDimension = (view.frame.size.width - 0) / CGFloat(numCols)
    //        var xOffset: CGFloat = 0
    //        var yOffset: CGFloat = 0
    //        let start_row = 0
    //        let end_row = 0
    //        for row in start_row...end_row {
    //
    //            yOffset = (CGFloat(row - start_row) * cellDimension) + 200
    //
    //            for col in 0...7 {
    //
    //                xOffset = (CGFloat(col) * cellDimension) + 0
    //
    //                // create a piece
    //                var piece = ChessPiece(row: row, column: col, color: .white, type: .dummy, player: .white)
    //
    //                // create a cell at this location with this piece, and set color
    //                let cell = BoardCell(row: row, column: col, piece: piece, color: .white)
    //
    //                // NSLog("Board cells at row, col: \(boardCells[row][col])")
    //
    //                cell.frame = CGRect(x: xOffset, y: yOffset, width: cellDimension, height: cellDimension)
    //                if (row % 2 == 0 && col % 2 == 0) || (row % 2 != 0 && col % 2 != 0) {
    //                    cell.color = #colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)
    //                } else {
    //                    cell.color = #colorLiteral(red: 0.5787474513, green: 0.3215198815, blue: 0, alpha: 1)
    //                }
    //
    //                cell.removeHighlighting()
    //
    //                // wire up the cell
    //                cell.delegate = self
    //                chessBoard.board[row][col] = piece
    //                self.boardCells[row][col] = cell
    //
    //
    //                view.addSubview(cell)
    //            }
    //        }
    //    }
    
    func clearFrontRow(){
        let chosenPiece = getPiece(string: "Empty")
        chosenPiece.setupSymbol()
        let row = 0//front row
        for col in 0...7{
            chosenPiece.row = row
            chosenPiece.col = col
            boardCells[row][col].configureCell(forPiece: chosenPiece)
        }
        playerPoints = calculateCost()
        pointsRemaining.text = "Points spent: \(playerPoints)"
    }
    
    func calculateCost() -> Int{
        var cost = 0
        var allPieces = [ChessPiece]()
        var kingCount = 0
        for row in 0...7 {
            for col in 0...7 {
                let piece = boardCells[row][col].piece
                if (piece.type != .dummy) {
                    allPieces.append(piece)
                }
            }
        }
        
        for piece in allPieces {
            if piece.type == .king{
                if kingCount > 0{
                    cost = cost + 60
                } else {
                    cost = cost + 40
                }
                kingCount = kingCount + 1
            } else {
                cost = cost + piece.summonCost
            }
        }
        return cost
    }
    
    
    func numKings(color: UIColor) -> Int {
        var numKings = 0
        //iterate through pieces of each color
        // let allPieces = boardCells.getAllPieces(forPlayer: color)
        // replace by iterating through all self.boardCells, and asking the cell what piece it has
        var allPieces = [ChessPiece]()
        for row in 0...7 {
            for col in 0...7 {
                let piece = boardCells[row][col].piece
                if (piece.type != .dummy) {
                    allPieces.append(piece)
                }
            }
        }
        
        for piece in allPieces {
            if piece.type == .king{
                numKings = numKings + 1
            } else if piece.type == .superKing{
                numKings = numKings + 1
            }
        }
        return numKings
    }
    
    //TODO: rename this function and the button to options
    @IBAction func resetButtonPressed(_ sender: Any) {
        //put up an "are you sure?" popup
        let ac = UIAlertController(title: "More Options", message: nil, preferredStyle: .actionSheet)
        //if yes, clear all the pieces
        let reset = UIAlertAction(title: "Reset", style: .default, handler: { action in
            self.clearPieces()
        })
        let save = UIAlertAction(title: "Save Formation", style: .default, handler: {action in self.saveFormation()})
        let load = UIAlertAction(title: "Load Formation", style: .default, handler: {action in self.loadFormation()})
        let random = UIAlertAction(title: "Random Formation", style: .default, handler: {action in self.randFormation(numIterations: 0)})
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        ac.addAction(reset)
        ac.addAction(random)
        ac.addAction(save)
        ac.addAction(load)
        ac.addAction(cancel)
        present(ac, animated: true, completion: nil)
        //if no, do nothing
    }
    
    
    /*-----------------------------------------------------------------------------*/
    /* READY BUTTON PRESSEd  ------------------------------------------------------------*/
    
    
    @IBAction func readyButtonPressed(_ sender: Any) {
        //check if the player has at least one king
        
        if !checkNumKings() { return; }
        
        checkPlayerPoints()
        
    }
    
    
    
    func checkNumKings() -> Bool {
        if numKings(color: playerColor) == 0 {
            tipLabel.text = "Place a king, then you can play!"
            let ac = UIAlertController(title: "Rule", message: "You need to place at least one king before you can play", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            ac.addAction(ok)
            present(ac, animated: true, completion: nil)
            return false
        }
        
        return true
        
    }
    
    
    func checkPlayerPoints(){
        //check if the player has used up enough points (at least 440)
        if playerPoints < 440{
            //if not, ask them if they're sure they want to ready up
            let ac = UIAlertController(title: "Points remaining", message: "You still have points to spend, ready anyway?", preferredStyle: .alert)
            let yes = UIAlertAction(title: "Ready!", style: .default, handler:
            { action in
                self.placePieces()
            }
            )
            let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

            ac.addAction(yes)
            ac.addAction(no)
            present(ac, animated: true, completion: nil)
            return
        }

        self.placePieces()
        
    }
    
    func placePieces() {
        
        model.setInitialPieces(playerColor: playerColor,boardCells: boardCells)
        // model.setInitialPieces will flip the position of the black pieces coming from PlacePiecesOnlyViewController
        
        if isLocalMatch {
            print("local match ready button pressed")
            if playerColor == .white {
                p2BoardCells = boardCells
                playerColor = .black
                clearPieces()
                setLabels()
                piecePictureSetup()
                addStarterKing()
            } else {
                localMatchReady()
            }
        } else {
            onlineMatchReady()
        }
        
        
    }
    
    func onlineMatchReady(){
        
        print("onlineMatchReady called")
        
        if (playerColor == .white && self.model.piecesAreSet && self.model.isWhiteTurn) {
            self.performSegue(withIdentifier: "OnlineMatchSegue", sender: self)//start the game with the current piece placement
        }
        GameCenterHelper.helper.endTurn(self.model) { error in
            defer {
                print("self.isSendingTurn = false")
            }
            
            if let e = error {
                print("Error ending turn: \(e.localizedDescription)")
                return
            }
            
            self.performSegue(withIdentifier: "ReturnToMenuSegue", sender: self)
        }
        
        
        
        
        
        
        // tell GameCenterHelper ? that you're ready to play
        
        // GameCenterHelper will probably tell you when other player is ready...
        
    }
    
    func localMatchReady(){
        print("localMatchReady called")
        self.performSegue(withIdentifier: "LocalMatchSegue", sender: self)//start the game with the current piece placement
    }
    
    
    //
    //    func returnPieces() {
    //
    //        // return boardcells to calling view controller, or GameModel.boardcells to these pieces
    //
    //        model.setPieces(playerColor: playerColor,boardCells: boardCells)
    ////        self.dismiss(animated: true, completion: {() in
    ////                self.navigationController?.popViewController( animated: true)
    ////            }
    ////        )
    //
    //
    //
    ////        if (local) {
    ////            // set playercolor to white
    ////            self.performSegue(withIdentifier: "PlacePiecesOnlyViewController", sender: self)
    ////            //set playcolor to black
    ////            self.performSegue(withIdentifier: "PlacePiecesOnlyViewController", sender: self)
    ////            self.performSegue(withIdentifier: "LocalMatchSegue", sender: self)//start the game with the current piece placement
    ////
    ////        }
    //
    //
    //
    ////
    ////        // if online
    ////        self.processGameUpdate() //Do I still need this or just an endTurn?
    ////        self.goToMain()
    //
    //    }
    
    
    
    /*-----------------------------------------------------------------------------*/
    /* SAVE FORMATIONS ------------------------------------------------------------*/
    
    func saveFormation(){
        let ac = UIAlertController(title: "Save Formation", message: nil, preferredStyle: .actionSheet)
        let slot1 = UIAlertAction(title: "Slot 1", style: .default, handler: {action in self.saveSlot(slot: 1)})
        let slot2 = UIAlertAction(title: "Slot 2", style: .default, handler: {action in self.saveSlot(slot: 2)})
        let slot3 = UIAlertAction(title: "Slot 3", style: .default, handler: {action in self.saveSlot(slot: 3)})
        let back = UIAlertAction(title: "Back", style: .cancel, handler: {action in self.resetButtonPressed(self)})
        ac.addAction(slot1)
        ac.addAction(slot2)
        ac.addAction(slot3)
        ac.addAction(back)
        present(ac, animated: true, completion: nil)
    }
    
    func loadFormation(){
        let ac = UIAlertController(title: "Load Formation", message: nil, preferredStyle: .actionSheet)
        let slot1 = UIAlertAction(title: "Slot 1", style: .default, handler: {action in self.loadSlot(slot: 1)})
        let slot2 = UIAlertAction(title: "Slot 2", style: .default, handler: {action in self.loadSlot(slot: 2)})
        let slot3 = UIAlertAction(title: "Slot 3", style: .default, handler: {action in self.loadSlot(slot: 3)})
        let back = UIAlertAction(title: "Back", style: .cancel, handler: {action in self.resetButtonPressed(self)})
        ac.addAction(slot1)
        ac.addAction(slot2)
        ac.addAction(slot3)
        ac.addAction(back)
        present(ac, animated: true, completion: nil)
    }
    
    func randFormation(numIterations: Int) -> [[BoardCell]]{
        print("Interations: \(numIterations)")
        var formation = boardCells
        var numKings = checkKings(formation: formation)
        var randIndex = 0
        //place some pieces in the first 2 rows
        for row in 1...2{
            for col in 0...7{
                randIndex = Int.random(in: 1...(pickerData.count - 1))
                let string = pickerData[randIndex]
                var piece = getPiece(string: string)
                //                if row == 1{
                //                    if piece.type == .dragonRider{
                //                        piece = notDragonRider()
                //                    }
                //                }
                piece.row = row
                piece.col = col
                piece.color = playerColor
                piece.setupSymbol()
                formation[row][col].row = row
                formation[row][col].col = col
                formation[row][col].piece.type = piece.type
                formation[row][col].configureCell(forPiece: piece)
            }
        }
        playerPoints = calculateCost()
        pointsRemaining.text = "Points spent: \(playerPoints)"
        //check if the formation is legal
        numKings = checkKings(formation: formation)
        if numKings < 1 || playerPoints > 450{//if not, recurse
            formation = randFormation(numIterations: numIterations + 1)
        }
        //if we've got points to spare, add pieces in the third row
        //        if playerPoints < 440{
        //            while playerPoints < 440{
        //                let col = Int.random(in: 0...7)
        //                randIndex = Int.random(in: 0...(pickerData.count - 1))
        //                let string = pickerData[randIndex]
        //                var piece = getPiece(string: string)
        ////                if piece.type == .dragonRider{
        ////                    piece = notDragonRider()
        ////                }
        //                piece.row = 0
        //                piece.col = col
        //                piece.color = playerColor
        //                piece.setupSymbol()
        //                formation[0][col].row = 0
        //                formation[0][col].column = col
        //                formation[0][col].piece.type = piece.type
        //                formation[0][col].configureCell(forPiece: piece)
        //            }
        //        }
        boardCells = formation
        return formation
    }
    
    
    
    func checkKings(formation: [[BoardCell]]) -> Int{
        for row in 0...2{
            for col in 0...7{
                if formation[row][col].piece.type == .king || formation[row][col].piece.type == .superKing{
                    return 1
                }
            }
        }
        return 0
    }
    
    //recurses until a piece that isn't a dragon rider is found
    func notDragonRider() -> ChessPiece{
        let randIndex = Int.random(in: 0...(pickerData.count - 1))
        let string = pickerData[randIndex]
        var piece = getPiece(string: string)
        if piece.type == .dragonRider{
            piece = notDragonRider()
        }
        return piece
    }
    
    func saveSlot(slot: Int){
        let row0 = boardCellRowToStringArray(row: 0)
        let row1 = boardCellRowToStringArray(row: 1)
        let row2 = boardCellRowToStringArray(row: 2)
        if slot < 2{
            UserDefaults.standard.set(row0, forKey: "slot1Row0")
            UserDefaults.standard.set(row1, forKey: "slot1Row1")
            UserDefaults.standard.set(row2, forKey: "slot1Row2")
        } else if slot == 2{
            UserDefaults.standard.set(row0, forKey: "slot2Row0")
            UserDefaults.standard.set(row1, forKey: "slot2Row1")
            UserDefaults.standard.set(row2, forKey: "slot2Row2")
        } else { //if slot == 3
            UserDefaults.standard.set(row0, forKey: "slot3Row0")
            UserDefaults.standard.set(row1, forKey: "slot3Row1")
            UserDefaults.standard.set(row2, forKey: "slot3Row2")
        }
    }
    
    
    func loadSlot(slot: Int){
        //load piece information
        if slot < 2{
            let string0 = UserDefaults.standard.array(forKey: "slot1Row0")
            if string0 != nil{
                clearPieces()
                tipLabel.text = "Formation 1 loaded"
                print("\(string0)")
            } else {
                tipLabel.text = "No formation is saved to Slot 1"
                return
            }
            stringArrayToBoardCellRow(row: 0, array: string0 as! [String])
            let string1 = UserDefaults.standard.array(forKey: "slot1Row1")
            stringArrayToBoardCellRow(row: 1, array: string1 as! [String])
            let string2 = UserDefaults.standard.array(forKey: "slot1Row2")
            stringArrayToBoardCellRow(row: 2, array: string2 as! [String])
        } else if slot == 2{
            let string0 = UserDefaults.standard.array(forKey: "slot2Row0")
            if string0 != nil{
                tipLabel.text = "Formation 2 loaded"
                clearPieces()
            } else {
                tipLabel.text = "No formation is saved to Slot 2"
                return
            }
            stringArrayToBoardCellRow(row: 0, array: string0 as! [String])
            let string1 = UserDefaults.standard.array(forKey: "slot2Row1")
            stringArrayToBoardCellRow(row: 1, array: string1 as! [String])
            let string2 = UserDefaults.standard.array(forKey: "slot2Row2")
            stringArrayToBoardCellRow(row: 2, array: string2 as! [String])
        } else { //if slot == 3
            let string0 = UserDefaults.standard.array(forKey: "slot3Row0")
            if string0 != nil{
                tipLabel.text = "Formation 3 loaded"
                clearPieces()
            } else {
                tipLabel.text = "No formation is saved to Slot 3"
                return
            }
            stringArrayToBoardCellRow(row: 0, array: string0 as! [String])
            let string1 = UserDefaults.standard.array(forKey: "slot3Row1")
            stringArrayToBoardCellRow(row: 1, array: string1 as! [String])
            let string2 = UserDefaults.standard.array(forKey: "slot3Row2")
            stringArrayToBoardCellRow(row: 2, array: string2 as! [String])
        }
        displayLoadedFormation()
    }
    
    func displayLoadedFormation(){
        for row in 0...2{
            for col in 0...7{
                if boardCells[row][col].piece.type != .dummy{
                    boardCells[row][col].piece.setupSymbol()
                    var piece = ChessPiece(row: 0, column: 0, color: playerColor, type: boardCells[row][col].piece.type, player: playerColor)
                    piece.row = row
                    piece.col = col
                    piece.setupSymbol()
                    boardCells[row][col].piece = piece
                    boardCells[row][col].configureCell(forPiece: piece)
                }
            }
        }
        playerPoints = calculateCost()
        pointsRemaining.text = "Points spent: \(playerPoints)"
    }
    
    /*-----------------------------------------------------------------------------*/
    
    
    
    //updates the screen when the uipicker changes
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        NSLog("Picker Changed")
        //get the string from the picker
        pickerString = pickerData[row]
        //compare that string to the piece types
        let piece = getPiece(string: pickerString)
        //assign the .png file to the UIImageview
        piece.setupSymbol()
        piecePicture.image = piece.symbolImage
        //assign info text to the info label
        pieceInfo.text = getInfo(piece: piece)
        pieceInfo.contentMode = .scaleToFill
        pieceInfo.numberOfLines = 0
        //assign cost to the top label
        pieceCost.text = "\(piece.summonCost) points to summon"
        if piece.type == .king{
            pieceCost.text = "40 points for the 1st, 60 after"
        }
    }
    
    //quickly resets the selected piece picture. Mostly useful for local matches when
    //the players switch colors
    func piecePictureSetup(){
        pickerString = pickerData[pickerData.firstIndex(of: pickerString)!]
        let piece = getPiece(string: pickerString)
        piece.setupSymbol()
    }
    
    func getPiece(string: String) -> ChessPiece {
        //NSLog("getting piece")
        var piece = ChessPiece(row: -1, column: -1, color: playerColor, type: .dummy, player: playerColor)
        switch string{
        case "Empty":
            piece.type = .dummy
        case "King":
            piece.type = .king
        case "Archer":
            piece.type = .archer
        case "Ballista":
            piece.type = .ballista
        case "Basilisk":
            piece.type = .basilisk
        case "Battering Ram":
            piece.type = .batteringRam
        case "Bishop":
            piece.type = .bishop
        case "Boar":
            piece.type = .boar
        case "Bombard":
            piece.type = .bombard
        case "Camel":
            piece.type = .camel
        case "Centaur":
            piece.type = .centaur
        case "Demon":
            piece.type = .demon
        case "Doppelsoldner":
            piece.type = .doppel
        case "Dragon Rider":
            piece.type = .dragonRider
        case "Dwarf":
            piece.type = .dwarf
        case "Elephant":
            piece.type = .elephant
        case "Fire Dragon":
            piece.type = .fireDragon
        case "Footsoldier":
            piece.type = .footSoldier
        case "Gargoyle":
            piece.type = .gargoyle
        case "Ghost Queen":
            piece.type = .ghostQueen
        case "Goblin":
            piece.type = .goblin
        case "Griffin":
            piece.type = .griffin
        case "Ice Dragon":
            piece.type = .iceDragon
        case "Knight":
            piece.type = .knight
        case "Left Handed Elf Warrior":
            piece.type = .leftElf
        case "Mage":
            piece.type = .mage
        case "Man at Arms":
            piece.type = .manAtArms
        case "Manticore":
            piece.type = .manticore
        case "Minotaur":
            piece.type = .minotaur
        case "Monk":
            piece.type = .monk
        case "Monopod":
            piece.type = .monopod
        case "Ogre":
            piece.type = .ogre
        case "Orc Warrior":
            piece.type = .orcWarrior
        case "Pawn":
            piece.type = .pawn
        case "Pikeman":
            piece.type = .pikeman
        case "Queen":
            piece.type = .queen
        case "Right Handed Elf Warrior":
            piece.type = .rightElf
        case "Rook":
            piece.type = .rook
        case "Royal Guard":
            piece.type = .royalGuard
        case "Scholar":
            piece.type = .scholar
        case "Scout":
            piece.type = .scout
        case "Ship":
            piece.type = .ship
        case "Superking":
            piece.type = .superKing
        case "Swordsman":
            piece.type = .swordsman
        case "Thunder Chariot":
            piece.type = .thunderChariot
        case "Trebuchet":
            piece.type = .trebuchet
        case "Unicorn":
            piece.type = .unicorn
        default:
            piece.type = .dummy
        }
        return piece
    }
    
    func getInfo(piece: ChessPiece) -> String {
        //NSLog("getting info")
        var string = ""
        
        switch piece.type{
        case .king:
            string = "Can move and attack one space in every direction. The game ends when a player runs out of kings. You need to place at least one of them or a superking to begin the game."
        case .dummy:
            string = "Removes any pieces from the highlighted space and lets you spend its summoning points on another piece."
        case .unicorn:
            string = "Can move as both a queen and a knight, making it very difficult for opponents to capture."
        case .superKing:
            string = "Counts as a king, but can move like a queen. You need to place at least one of them or a king to begin the game."
        case .griffin:
            string = "Moves one space diagonally, then infinitely vertically and horizontally away from that space. Very powerfuly in the end game with lots of open space."
        case .queen:
            string = "Can move infinitely vertically, horizontally, and diagonally. The most powerful piece in standard chess."
        case .mage:
            string = "Can move like both a bishop and a knight."
        case .centaur:
            string = "Can move like both a rook and a knight."
        case .dragonRider:
            string = "Moves like a knight, but can continue in that direction infinitely. This piece is so powerful that it can only be placed in the back row."
        case .bombard:
            string = "Can move to any space one or two spaces away, but can only attack two spaces away."
        case .manticore:
            string = "Can move one or two spaces in any direction, but can only attack one space away, like a king."
        case .ghostQueen:
            string = "Moves like a queen, but can't attack enemy pieces. Useful for protecting more valuable pieces."
        case .rook:
            string = "Can move infinitely in horizontal and vertical lines. Placed in the corners in regular chess."
        case .knight:
            string = "Jumps to spaces that are two spaces up and one space over, or two spaces over and one space up. Placed next to the corners in regular chess."
        case .bishop:
            string = "Can move infinitely in diagonal lines. Placed next to the king and queen in regular chess."
        case .basilisk:
            string = "Can move and attack one space away like a king, and can also move infinitely in a horizontal line."
        case .fireDragon:
            string = "Moves like a bishop, but attacks like a rook."
        case .iceDragon:
            string = "Moves like a rook, but attacks like a bishop."
        case .minotaur:
            string = "Jumps two or three spaces away vertically or diagonally."
        case .monopod:
            string = "Jumps to any space two spaces away."
        case .ship:
            string = "Can move one space diagonally, then infinitely vertically from that space."
        case .ballista:
            string = "Moves vertically towards the opposing side but diagonally towards yours."
        case .batteringRam:
            string = "Moves vertically and diagonally, but only towards the opposing side. Good at taking out high-value opposing pieces early in the game."
        case .trebuchet:
            string = "Moves diagonally towards the opposing side and vertically towards yours."
        case .leftElf:
            string = "Going left, it moves like a bishop. Going right, it moves like a knight."
        case .rightElf:
            string = "Going right, it moves like a bishop. Going left, it moves like a knight."
        case .camel:
            string = "Moves like a knight, but jumping 3 spaces and over at a time instead of 2."
        case .scout:
            string = "Jumps like a knight towards the opposing side and can move one space backwards. Can't jump backwards or laterally."
        case .ogre:
            string = "Moves one space diagonally."
        case .orcWarrior:
            string = "Moves one space vertically or horizontally."
        case .elephant:
            string = "Moves one space vertically or horizontally, but attacks one space diagonally."
        case .manAtArms:
            string = "Moves one space diagonally, but attacks one space vertically or horizontally."
        case .swordsman:
            string = "Can move one space directly forward or diagonally towads the opposing side."
        case .pikeman:
            string = "Jumps two spaces horizontally or vertically."
        case .archer:
            string = "Jumps two spaces diagonally."
        case .royalGuard:
            string = "Moves just like a king, but doesn't count as a king."
        case .demon:
            string = "Can move one space horizontally, but attacks diagonally and verticlly one space."
        case .pawn:
            string = "Can move two spaces on its first turn. After that, it can move one space forward. Attacks one space diagonally forward. The basic piece in standard chess. If it reaches the far end of the game board, it can be turned into a more powerful piece"
        case .monk:
            string = "Like a pawn, but both moves and attacks diagonally."
        case .dwarf:
            string = "Like a pawn, but moves diagonally and attacks forward."
        case .gargoyle:
            string = "Can't move unless attacking, but can attack any adjacent space."
        case .goblin:
            string = "Like a pawn, but moves and attacks forwards."
        case .footSoldier:
            string = "Like a pawn, but moves two spaces at a time and attacks horizontally instead of diagonally."
        case .boar:
            string = "Moves like a queen, but can only travel 2 spaces."
        case .thunderChariot:
            string = "Moves like a rook, but zig-zags around the board. It always zig-zags right, then left no matter which direction it moves."
        case .doppel:
            string = "Moves like a rook, but only two spaces."
        case .scholar:
            string = "Moves like a bishop, but only two spaces."
        default:
            string = ""
        }
        return string
    }
    
    func processGameUpdate() {
        print("place pieces processGameUpdate called")
        let updatedBoard = combineFormations()
        //let updatedPieceNamesArray = model.updatePieceNamesArray(chessPieceArray: updatedBoard)
        
        model.piecesArray.removeAll()
        for r in 0...7 {
            for c in 0...7 {
                var pieceBasicInfo = boardCells[r][c].piece.getBasicInfo()
                if pieceBasicInfo.type != .dummy {
                    model.piecesArray.append(pieceBasicInfo)
                }
            }
        }
        
        if self.playerColor == UIColor.white{
            model.whiteHasSetPieces = true
        } else {
            model.blackHasSetPieces = true
        }
        model.switchCurrentPlayer()
        if model.winner != nil {
            GameCenterHelper.helper.win { error in
                
                if let e = error {
                    print("Error winning match: \(e.localizedDescription)")
                    return
                }
                
                self.goToMain()
            }
        } else {
            GameCenterHelper.helper.endTurn(model) { error in
                
                if let e = error {
                    print("Error ending turn: \(e.localizedDescription)")
                    return
                }
                
                self.goToMain()
            }
        }
    }
    
    func boardCellRowToStringArray(row: Int) -> [String]{
        var newArray = [String]()
        for col in 0...7{
            newArray.append(typeToString(piece: boardCells[row][col].piece))
        }
        return newArray
    }
    
    func stringArrayToBoardCellRow(row: Int, array: [String]){
        for col in 0...7{
            boardCells[row][col].piece = getPiece(string: array[col])
            //print("Type at \(row), \(col): \(boardCells[row][col].piece.type)")
        }
    }
    
    func typeToString(piece: ChessPiece) -> String{
        switch piece.type{
        case .archer:
            return "Archer"
        case .dummy:
            return "Empty"
        case .unicorn:
            return "Unicorn"
        case .superKing:
            return "Superking"
        case .griffin:
            return "Griffin"
        case .king:
            return "King"
        case .queen:
            return "Queen"
        case .mage:
            return "Mage"
        case .centaur:
            return "Centaur"
        case .dragonRider:
            return "Dragon Rider"
        case .bombard:
            return "Bombard"
        case .manticore:
            return "Manticore"
        case .ghostQueen:
            return "Ghost Queen"
        case .rook:
            return "Rook"
        case .knight:
            return "Knight"
        case .bishop:
            return "Bishop"
        case .basilisk:
            return "Basilisk"
        case .fireDragon:
            return "Fire Dragon"
        case .iceDragon:
            return "Ice Dragon"
        case .minotaur:
            return "Minotaur"
        case .monopod:
            return "Monopod"
        case .ship:
            return "Ship"
        case .ballista:
            return "Ballista"
        case .batteringRam:
            return "Battering Ram"
        case .trebuchet:
            return "Trebuchet"
        case .leftElf:
            return "Left Handed Elf Warrior"
        case .rightElf:
            return "Right Handed Elf Warrior"
        case .camel:
            return "Camel"
        case .boar:
            return "Boar"
        case .thunderChariot:
            return "Thunder Chariot"
        case .scout:
            return "Scout"
        case .ogre:
            return "Ogre"
        case .orcWarrior:
            return "Orc Warrior"
        case .elephant:
            return "Elephant"
        case .manAtArms:
            return "Man at Arms"
        case .swordsman:
            return "Swordsman"
        case .pikeman:
            return "Pikeman"
        case .royalGuard:
            return "Royal Guard"
        case .demon:
            return "Demon"
        case .pawn:
            return "Pawn"
        case .monk:
            return "Monk"
        case .dwarf:
            return "Dwarf"
        case .gargoyle:
            return "Gargoyle"
        case .goblin:
            return "Goblin"
        case .footSoldier:
            return "Footsoldier"
        case .doppel:
            return "Doppelsoldner"
        case .scholar:
            return "Scholar"
        }
    }
}



extension PlacePiecesViewController: BoardCellDelegate {
    
    func didSelect(cell: BoardCell, atRow row: Int, andColumn col: Int) {
        //NSLog("I have been chosen! \(row), \(col)")
        //print("Selected cell at: \(row), \(col)")
        //chessBoard.board[row][col].showPieceInfo()
        // Check if making a move (if had selected piece before)
        //clear the other highlighted pieces
        highlightedCell.removeHighlighting()
        piecePicture.backgroundColor = cell.backgroundColor //change the square to be the same color as the current space. Small touch
        cell.backgroundColor = cell.hexStringToUIColor(hex:"6DAFFB")
        highlightedCell = cell
        
        
    }
    
}
