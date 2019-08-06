//
//  chessPiece.swift
//  Team Kookaburra Chess
//
//  Created by Christopher Blake Cassell Erquiaga on 3/18/19.
//  Copyright © 2019 Christopher Blake Cassell Erquiaga. All rights reserved.
// Originally created by Mikael Mukhsikaroyan on 11/1/16.
//  Used and modified under MIT License

import UIKit

enum PieceType: String,Codable {
    case dummy
    //tier 5
    case unicorn
    case superKing
    case griffin
    //tier 4
    case king
    case queen
    case mage
    case centaur
    case dragonRider
    case bombard
    case manticore
    //tier 3
    case ghostQueen
    case rook
    case knight
    case bishop
    case basilisk
    case fireDragon
    case iceDragon
    case minotaur
    case monopod
    case ship
    case ballista
    case batteringRam
    case trebuchet
    case leftElf
    case rightElf
    case camel
    case boar
    case thunderChariot
    //tier 2
    case scout
    case ogre
    case orcWarrior
    case elephant
    case manAtArms
    case swordsman
    case pikeman
    case archer
    case royalGuard
    case demon
    case doppel
    case scholar
    //tier 1
    case pawn
    case monk
    case dwarf
    case gargoyle
    case goblin
    case footSoldier
}

struct ChessPieceBasicInfo : Codable {
    
    var red : CGFloat = 42
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    
    var row: Int
    var col: Int
    
    
    // var color: UIColor
    var type: PieceType
    var advancingByTwo: Bool
    var firstMove: Bool
    
    
    
    init(uiColor:UIColor, r:Int, c: Int,t: PieceType, a:Bool, f:Bool) {
        uiColor.getRed( &red, green: &green, blue: &blue, alpha: &alpha)
        row = r
        col = c
        type = t
        advancingByTwo = a
        firstMove = f
    }
    
    var uiColor : UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}



class ChessPiece {
    
    /* critical info to encode in Match */
    
    var row: Int = 0 {
        didSet {
            updateIndex()
        }
    }
    var col: Int = 0 {
        didSet {
            updateIndex()
        }
    }
    
    var color: UIColor
    var type: PieceType
    var advancingByTwo = false // Only for pawn type
    var firstMove = true // Only for king type
    //var pawnFirstMove = true // only for pawn type
    
    /*--------------------------------------------*/
    
    var bIndex: BoardIndex
    var symbol: String
    var symbolImage: UIImage
    
    var summonCost: Int
    
    var playerColor: UIColor
    
    init(row: Int, column: Int, color: UIColor, type: PieceType, player: UIColor) {
        //print("ChessPiece init called")
        self.row = row
        self.col = column
        self.bIndex = BoardIndex(row: row, column: col)
        self.color = color
        self.type = type
        self.symbol = ""
        self.symbolImage = UIImage(named:"blackPawn.png")!
        self.playerColor = player
        self.summonCost = 0
        setupSymbol()
    }
    
    convenience init(pieceInfo: ChessPieceBasicInfo) {
        var color: UIColor
        if pieceInfo.uiColor == UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 1){
            color = UIColor.black
        } else {// if pieceInfo.uiColor == UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 1)
            color = UIColor.white
        }
        self.init(row: pieceInfo.row, column: pieceInfo.col, color: color, type: pieceInfo.type, player: color)
        self.firstMove = pieceInfo.firstMove
        self.advancingByTwo = pieceInfo.advancingByTwo
    }
    
    func getBasicInfo() -> ChessPieceBasicInfo {
        
        let info = ChessPieceBasicInfo.init(
            uiColor: self.color,
            r: self.row,
            c: self.col,
            t: self.type,
            a: self.advancingByTwo,
            f: self.firstMove
        )
        
        return info
        
    }
    
    func updateIndex() {
        let dir: BDirection = playerColor == .white ? .bottom : .top
        bIndex.updateValue(fromDirection: dir)
        //showPieceInfo()
    }
    
    func showPieceInfo() {
        print("PIECE============")
        print("Value Row: \(bIndex.valueRow.rawValue)")
        print("Value Col: \(bIndex.valueCol.rawValue)")
    }
    
    
    func setupSymbol() {
        //print("ChessPiece setupSymbol called")
        if color == .black{
            switch type {
            case .pawn:
                symbol = "blackPawn.png"
                summonCost = 10
            case .rook:
                symbol = "testRook.png"
                summonCost = 50
            case .knight:
                symbol = "blackKnight.png"
                summonCost = 30
            case .bishop:
                symbol = "blackBishop.png"
                summonCost = 35
            case .king:
                symbol = "blackKing.png"
                summonCost = 40
            case .queen:
                symbol = "blackQueen.png"
                summonCost = 100
            case .dummy:
                symbol = "blankPiece.png"
            case .ghostQueen:
                symbol = "blackGhostQueen.png"
                summonCost = 20
            case .dwarf:
                symbol = "blackDwarf.png"
                summonCost = 10
            case .footSoldier:
                symbol = "blackFootsoldier.png"
                summonCost = 12
            case .monk:
                symbol = "blackMonk.png"
                summonCost = 10
            case .gargoyle:
                symbol = "blackGargoyle.png"
                summonCost = 10
            case .goblin:
                symbol = "blackGoblin.png"
                summonCost = 15
            case .scout:
                symbol = "blackScout.png"
                summonCost = 25
            case .ogre:
                symbol = "blackOgre.png"
                summonCost = 18
            case .orcWarrior:
                symbol = "blackOrcWarrior.png"
                summonCost = 20
            case .elephant:
                symbol = "blackElephant.png"
                summonCost = 20
            case .manAtArms:
                symbol = "blackManAtArms.png"
                summonCost = 20
            case .swordsman:
                symbol = "blackSwordsman.png"
                summonCost = 15
            case .archer:
                symbol = "blackArcher.png"
                summonCost = 25
            case .pikeman:
                symbol = "blackPikeman.png"
                summonCost = 25
            case .royalGuard:
                symbol = "blackGuard.png"
                summonCost = 30
            case .demon:
                symbol = "blackDemon.png"
                summonCost = 20
            case .basilisk:
                symbol = "blackBasilisk.png"
                summonCost = 50
            case .fireDragon:
                symbol = "blackFireDragon.png"
                summonCost = 60
            case .iceDragon:
                symbol = "blackIceDragon.png"
                summonCost = 60
            case .minotaur:
                symbol = "blackMinotaur.png"
                summonCost = 75
            case .monopod:
                symbol = "blackMonopod.png"
                summonCost = 75
            case .ship:
                symbol = "blackShip.png"
                summonCost = 70
            case .batteringRam:
                symbol = "blackBatteringRam.png"
                summonCost = 25
            case .ballista:
                symbol = "blackBallista.png"
                summonCost = 30
            case .trebuchet:
                symbol = "blackTrebuchet.png"
                summonCost = 30
            case .leftElf:
                symbol = "blackLeftyElf.png"
                summonCost = 30
            case .rightElf:
                symbol = "blackRightyElf.png"
                summonCost = 30
            case .mage:
                symbol = "blackMage.png"
                summonCost = 80
            case .centaur:
                symbol = "blackCentaur.png"
                summonCost = 80
            case .camel:
                symbol = "blackCamel.png"
                summonCost = 45
            case .unicorn:
                symbol = "blackUnicorn.png"
                summonCost = 150
            case .superKing:
                symbol = "blackSuperking.png"
                summonCost = 120
            case .griffin:
                symbol = "blackGriffin.png"
                summonCost = 130
            case .dragonRider:
                symbol = "blackDragonRider.png"
                summonCost = 150
            case .bombard:
                symbol = "blackBombard.png"
                summonCost = 140
            case .manticore:
                symbol = "blackManticore.png"
                summonCost = 90
            case .boar:
                symbol = "blackBoar.png"
                summonCost = 70
            case .thunderChariot:
                symbol = "blackThunderChariot.png"
                summonCost = 60
            case .doppel:
                symbol = "blackDoppelsoldner.png"
                summonCost = 30
            case .scholar:
                symbol = "blackScholar.png"
                summonCost = 25
            }
        } else if color == .white{
            switch type {
            case .pawn:
                symbol = "whitePawn.png"
                summonCost = 10
            case .rook:
                symbol = "whiteRook.png"
                summonCost = 50
            case .knight:
                symbol = "whiteKnight.png"
                summonCost = 30
            case .bishop:
                symbol = "whiteBishop.png"
                summonCost = 35
            case .king:
                symbol = "whiteKing.png"
                summonCost = 40
            case .queen:
                symbol = "whiteQueen.png"
                summonCost = 100
            case .dummy:
                symbol = "blankPiece.png"
            case .ghostQueen:
                symbol = "whiteGhostQueen.png"
                summonCost = 20
            case .dwarf:
                symbol = "whiteDwarf.png"
                summonCost = 10
            case .footSoldier:
                symbol = "whiteFootsoldier.png"
                summonCost = 12
            case .monk:
                symbol = "whiteMonk.png"
                summonCost = 10
            case .gargoyle:
                symbol = "whiteGargoyle.png"
                summonCost = 10
            case .goblin:
                symbol = "whiteGoblin.png"
                summonCost = 15
            case .scout:
                symbol = "whiteScout.png"
                summonCost = 25
            case .ogre:
                symbol = "whiteOgre.png"
                summonCost = 18
            case .orcWarrior:
                symbol = "whiteOrcWarrior.png"
                summonCost = 20
            case .elephant:
                symbol = "whiteElephant.png"
                summonCost = 20
            case .manAtArms:
                symbol = "whiteManAtArms.png"
                summonCost = 20
            case .swordsman:
                symbol = "whiteSwordsman.png"
                summonCost = 15
            case .archer:
                symbol = "whiteArcher.png"
                summonCost = 25
            case .pikeman:
                symbol = "whitePikeman.png"
                summonCost = 25
            case .royalGuard:
                symbol = "whiteGuard.png"
                summonCost = 30
            case .demon:
                symbol = "whiteDemon.png"
                summonCost = 20
            case .basilisk:
                symbol = "whiteBasilisk.png"
                summonCost = 50
            case .fireDragon:
                symbol = "whiteFireDragon.png"
                summonCost = 60
            case .iceDragon:
                symbol = "whiteIceDragon.png"
                summonCost = 60
            case .minotaur:
                symbol = "whiteMinotaur.png"
                summonCost = 75
            case .monopod:
                symbol = "whiteMonopod.png"
                summonCost = 75
            case .ship:
                symbol = "whiteShip.png"
                summonCost = 70
            case .batteringRam:
                symbol = "whiteBatteringRam.png"
                summonCost = 25
            case .ballista:
                symbol = "whiteBallista.png"
                summonCost = 30
            case .trebuchet:
                symbol = "whiteTrebuchet.png"
                summonCost = 30
            case .leftElf:
                symbol = "whiteLeftyElf.png"
                summonCost = 30
            case .rightElf:
                symbol = "whiteRightyElf.png"
                summonCost = 30
            case .mage:
                symbol = "whiteMage.png"
                summonCost = 80
            case .centaur:
                symbol = "whiteCentaur.png"
                summonCost = 80
            case .camel:
                symbol = "whiteCamel.png"
                summonCost = 45
            case .unicorn:
                symbol = "whiteUnicorn.png"
                summonCost = 150
            case .superKing:
                symbol = "whiteSuperKing.png"
                summonCost = 120
            case .griffin:
                symbol = "whiteGriffin.png"
                summonCost = 130
            case .dragonRider:
                symbol = "whiteDragonRider.png"
                summonCost = 150
            case .bombard:
                symbol = "whiteBombard.png"
                summonCost = 140
            case .manticore:
                symbol = "whiteManticore.png"
                summonCost = 90
            case .boar:
                symbol = "whiteBoar.png"
                summonCost = 70
            case .thunderChariot:
                symbol = "whiteThunderChariot.png"
                summonCost = 60
            case .doppel:
                symbol = "whiteDoppelsoldner.png"
                summonCost = 30
            case .scholar:
                symbol = "whiteScholar.png"
                summonCost = 25
            }
        } else {
            symbol = "blankPiece.png"
        }
        //NSLog(symbol)
        self.symbolImage = UIImage(named:symbol)!
    }
    
    /** Checks to see if the direction the piece is moving is the way this piece type is allowed to move. Doesn't take into account the state of the board */
    func isMovementAppropriate(toIndex dest: BoardIndex) -> Bool {
        switch type {
        case .pawn:
            return checkPawn(dest: dest)
        case .rook:
            return checkRook(dest: dest)
        case .knight:
            return checkKnight(dest: dest)
        case .bishop:
            return checkBishop(dest: dest)
        case .queen:
            return checkQueen(dest: dest)
        case .king:
            return checkKing(dest: dest)
        case .dummy:
            return false
        case .ghostQueen:
            //difference is move validation
            return checkQueen(dest: dest)
        case .monk:
            return checkMonk(dest: dest)
        case .dwarf:
            //technically the movement pattern is the same as the swordsman (the difference is in move validation in cehssBoard.swift) so there's no need to write redundant code here
            return checkSwordsman(dest: dest)
        case .gargoyle:
            //just like the dwarf and swordsman, the difference here is the move validation, no need to write another function
            return checkKing(dest: dest)
        case .goblin:
            return checkGoblin(dest: dest)
        case .footSoldier:
            return checkFootSoldier(dest: dest)
        case .scout:
            return checkScout(dest: dest)
        case .ogre:
            return checkOgre(dest: dest)
        case .orcWarrior:
            return checkOrc(dest: dest)
        case .elephant:
            //differnce is in move validation
            return checkKing(dest: dest)
        case .manAtArms:
            //difference is move validation
            return checkKing(dest: dest)
        case .swordsman:
            return checkSwordsman(dest: dest)
        case .pikeman:
            return checkPike(dest: dest)
        case .archer:
            return checkArcher(dest: dest)
        case .royalGuard:
            return checkGuard(dest: dest)
        case .demon:
            //difference is move validation
            return checkKing(dest: dest)
        case .basilisk:
            return checkBasilisk(dest: dest)
        case .fireDragon:
            //difference is in validation
            return checkQueen(dest: dest)
        case .iceDragon:
            //difference is in validation
            return checkQueen(dest: dest)
        case .minotaur:
            return checkMinotaur(dest: dest)
        case .monopod:
            return checkMonopod(dest: dest)
        case .ship:
            return checkShip(dest: dest)
        case .batteringRam:
            return checkBatteringRam(dest: dest)
        case .ballista:
            return checkBallista(dest: dest)
        case .trebuchet:
            return checkTrebuchet(dest: dest)
        case .leftElf:
            return checkLeftyElf(dest: dest)
        case .rightElf:
            return checkRightyElf(dest: dest)
        case .mage:
            return checkMage(dest: dest)
        case .centaur:
            return checkCentaur(dest: dest)
        case .camel:
            return checkCamel(dest: dest)
        case .unicorn:
            return checkUnicorn(dest: dest)
        case .superKing:
            return checkSuperKing(dest: dest)
        case .griffin:
            return checkGriffin(dest: dest)
        case .dragonRider:
            return checkDragonRider(dest: dest)
        case .bombard:
            //difference is move validation
            return checkManticore(dest:dest)
        case .manticore:
            return checkManticore(dest: dest)
        case .boar:
            return checkBoar(dest: dest)
        case .thunderChariot:
            return checkChariot(dest: dest)
        case .doppel:
            return checkDoppel(dest: dest)
        case .scholar:
            return checkScholar(dest: dest)
        }
    }
    
    func checkPawn(dest: BoardIndex) -> Bool {
        // is it advancing by 2
        // check if the move is in the same column
        if self.col == dest.col {
            // can only move 2 forward if first time moving pawn
            if playerColor == .white{
                if color != playerColor {
                    if row == 1 && dest.row == 3 {
                        advancingByTwo = true
                        return true
                    } else if row == 0 && dest.row == 2{
                        advancingByTwo = true
                        return true
                    } else if row == 2 && dest.row == 4{
                        advancingByTwo = true
                        return true
                    }
                } else {
                    if row == 6 && dest.row == 4 {
                        advancingByTwo = true
                        return true
                    } else if row == 7 && dest.row == 5{
                        advancingByTwo = true
                        return true
                    } else if row == 5 && dest.row == 3{
                        advancingByTwo = true
                        return true
                    }
                }
            } else {
                if color == playerColor {
                    if row == 1 && dest.row == 3 {
                        advancingByTwo = true
                        return true
                    } else if row == 0 && dest.row == 2{
                        advancingByTwo = true
                        return true
                    } else if row == 2 && dest.row == 4{
                        advancingByTwo = true
                        return true
                    }
                } else {
                    if row == 6 && dest.row == 4 {
                        advancingByTwo = true
                        return true
                    } else if row == 7 && dest.row == 5{
                        advancingByTwo = true
                        return true
                    } else if row == 5 && dest.row == 3{
                        advancingByTwo = true
                        return true
                    }
                }
            }
        }
        advancingByTwo = false
        // the move direction depends on the color of the piece
        var moveDirection: Int
        if playerColor == .white{
            if color == playerColor {
                moveDirection = -1
            } else {
                moveDirection = 1
            }
        } else {
            if color == playerColor {
                moveDirection = 1
            } else {
                moveDirection = -1
            }
        }
        
        //let moveDirection = color == .black ? -1 : 1
        // if the movement is only 1 row up/down
        if dest.row == self.row + moveDirection {
            // check for diagonal movement and forward movement
            if (dest.col == self.col - 1) || (dest.col == self.col) || (dest.col == self.col + 1) {
                return true
            }
        }
        return false
    }
    
    func checkRook(dest: BoardIndex) -> Bool {
        if self.row == dest.row || self.col == dest.col {
            return true
        }
        return false
    }

    func checkDoppel(dest: BoardIndex) -> Bool {
        let validMoves = [(self.row + 2, self.col), (self.row + 1, self.col), (self.row - 2, self.col), (self.row - 1, self.col), (self.row, self.col - 2), (self.row, self.col - 1), (self.row, self.col + 2), (self.row, self.col + 1)]
        for (validRow, validCol) in validMoves {
            if dest.row == validRow && dest.col == validCol {
                return true
            }
        }
        return false
    }

    func checkScholar(dest: BoardIndex) -> Bool {
        let validMoves = [(self.row + 2, self.col + 2), (self.row + 1, self.col + 1), (self.row - 2, self.col - 2), (self.row - 1, self.col - 1), (self.row + 2, self.col - 2), (self.row + 1, self.col - 1), (self.row - 2, self.col + 2), (self.row - 1, self.col + 1)]
        for (validRow, validCol) in validMoves {
            if dest.row == validRow && dest.col == validCol {
                return true
            }
        }
        return false
    }
    
    func checkChariot(dest: BoardIndex) -> Bool {
        if dest.row > self.row + 1{//going down
            let validMoves = [(self.row + 1, self.col - 1), (self.row + 2, self.col), (self.row + 3, self.col - 1), (self.row + 4, self.col), (self.row + 5, self.col - 1), (self.row + 6, self.col), (self.row + 7, self.col - 1)]
            for (validRow, validCol) in validMoves {
                if dest.row == validRow && dest.col == validCol {
                    return true
                }
            }
            return false
        } else if dest.row < self.row - 1{//going up
            let validMoves = [(self.row - 1, self.col + 1), (self.row - 2, self.col), (self.row - 3, self.col + 1), (self.row - 4, self.col), (self.row - 5, self.col + 1), (self.row - 6, self.col), (self.row - 7, self.col + 1)]
            for (validRow, validCol) in validMoves {
                if dest.row == validRow && dest.col == validCol {
                    return true
                }
            }
            return false
        } else if dest.col > self.col + 1{//going right
            let validMoves = [(self.row + 1, self.col + 1), (self.row, self.col + 2), (self.row + 1, self.col + 3), (self.row, self.col + 4), (self.row + 1, self.col + 5), (self.row, self.col + 6), (self.row + 1, self.col + 7)]
            for (validRow, validCol) in validMoves {
                if dest.row == validRow && dest.col == validCol {
                    return true
                }
            }
            return false
        } else if dest.col < self.col - 1{//going left
            let validMoves = [(self.row - 1, self.col - 1), (self.row, self.col - 2), (self.row - 1, self.col - 3), (self.row, self.col - 4), (self.row - 1, self.col - 5), (self.row, self.col - 6), (self.row - 1, self.col - 7)]
            for (validRow, validCol) in validMoves {
                if dest.row == validRow && dest.col == validCol {
                    return true
                }
            }
            return false
        } else {//going close
            return checkOgre(dest: dest)
        }
    }
    
    //This function is public, unlike the others, to check for legal knight-type movements for hybrid pieces like the unicorn, centaur, and mage
    func checkKnight(dest: BoardIndex) -> Bool {
        let validMoves =  [(self.row - 1, self.col + 2), (self.row - 2, self.col + 1), (self.row - 2, self.col - 1), (self.row - 1, self.col - 2), (self.row + 1, self.col - 2), (self.row + 2, self.col - 1), (self.row + 2, self.col + 1), (self.row + 1, self.col + 2)]
        
        for (validRow, validCol) in validMoves {
            if dest.row == validRow && dest.col == validCol {
                return true
            }
        }
        return false
    }
    
    func checkBishop(dest: BoardIndex) -> Bool {
        if abs(dest.row - self.row) == abs(dest.col - self.col) {
            return true
        }
        return false
    }
    
    func checkQueen(dest: BoardIndex) -> Bool {
        // check diagonal move
        if abs(dest.row - self.row) == abs(dest.col - self.col) {
            return true
        }
        // check rook-like move
        if self.row == dest.row || self.col == dest.col {
            return true
        }
        return false
    }
    
    func checkKing(dest: BoardIndex) -> Bool {
        // king only moves one space at a time
        let rowDelta = abs(self.row - dest.row)
        let colDelta = abs(self.col - dest.col)
        if (rowDelta == 0 || rowDelta == 1) && (colDelta == 0 || colDelta == 1) {
            return true
        }
        //        if firstMove {
        //            if rowDelta == 0 && colDelta == 2 {
        //                return true
        //            }
        //        }
        return false
    }
    
    func checkSuperKing(dest: BoardIndex) -> Bool {
        return checkQueen(dest: dest)
    }
    
    func checkUnicorn(dest: BoardIndex) -> Bool {
        // check diagonal move
        if abs(dest.row - self.row) == abs(dest.col - self.col) {
            return true
        }
        // check rook-like move
        if self.row == dest.row || self.col == dest.col {
            return true
        }
        //check knight move
        let validMoves =  [(self.row - 1, self.col + 2), (self.row - 2, self.col + 1), (self.row - 2, self.col - 1), (self.row - 1, self.col - 2), (self.row + 1, self.col - 2), (self.row + 2, self.col - 1), (self.row + 2, self.col + 1), (self.row + 1, self.col + 2)]
        
        for (validRow, validCol) in validMoves {
            if dest.row == validRow && dest.col == validCol {
                return true
            }
        }
        return false
    }
    
    func checkCentaur(dest: BoardIndex) -> Bool {
        // check rook-like move
        if self.row == dest.row || self.col == dest.col {
            return true
        }
        //check knight move
        let validMoves =  [(self.row - 1, self.col + 2), (self.row - 2, self.col + 1), (self.row - 2, self.col - 1), (self.row - 1, self.col - 2), (self.row + 1, self.col - 2), (self.row + 2, self.col - 1), (self.row + 2, self.col + 1), (self.row + 1, self.col + 2)]
        
        for (validRow, validCol) in validMoves {
            if dest.row == validRow && dest.col == validCol {
                return true
            }
        }
        return false
    }
    
    func checkMage(dest: BoardIndex) -> Bool {
        // check diagonal move
        let bishopMove = checkBishop(dest: dest)
        //check knight move
        let knightMove = checkKnight(dest: dest)
        return bishopMove || knightMove
    }
    
    func checkCamel(dest: BoardIndex) -> Bool {
        let validMoves =  [(self.row - 1, self.col + 3), (self.row - 3, self.col + 1), (self.row - 3, self.col - 1), (self.row - 1, self.col - 3), (self.row + 1, self.col - 3), (self.row + 3, self.col - 1), (self.row + 3, self.col + 1), (self.row + 1, self.col + 3)]
        
        for (validRow, validCol) in validMoves {
            if dest.row == validRow && dest.col == validCol {
                return true
            }
        }
        return false
    }
    
    func checkMinotaur(dest: BoardIndex) -> Bool {
        let validMoves = [(self.row, self.col + 2), (self.row, self.col + 3), (self.row, self.col - 2 ), (self.row, self.col - 3), (self.row + 2, self.col), (self.row + 3, self.col), (self.row - 2, self.col), (self.row - 3, self.col), (self.row + 2, self.col + 2), (self.row + 2, self.col - 2), (self.row - 2, self.col + 2), (self.row - 2, self.col - 2), (self.row + 3, self.col + 3), (self.row + 3, self.col - 3), (self.row - 3, self.col + 3), (self.row - 3, self.col - 3)]
        for (validRow, validCol) in validMoves {
            if dest.row == validRow && dest.col == validCol {
                return true
            }
        }
        return false
    }
    
    func checkMonopod(dest: BoardIndex) -> Bool {
        let validMoves = [(self.row, self.col + 2), (self.row + 1, self.col + 2), (self.row + 2, self.col + 2), (self.row + 2, self.col + 1), (self.row + 2, self.col), (self.row + 2, self.col - 1), (self.row + 2, self.col - 2), (self.row + 1, self.col - 2), (self.row, self.col - 2), (self.row - 1, self.col - 2), (self.row - 2, self.col - 2), (self.row - 2, self.col - 1), (self.row - 2, self.col), (self.row - 2, self.col + 1), (self.row - 2, self.col + 2), (self.row - 1, self.col + 2)]
        for (validRow, validCol) in validMoves {
            if dest.row == validRow && dest.col == validCol {
                return true
            }
        }
        return false
    }
    
    func checkOgre(dest: BoardIndex) -> Bool {
        let validMoves = [(self.row + 1, self.col + 1), (self.row - 1, self.col + 1), (self.row - 1, self.col - 1), (self.row + 1, self.col - 1)]
        for (validRow, validCol) in validMoves {
            if dest.row == validRow && dest.col == validCol {
                return true
            }
        }
        return false
    }
    
    func checkOrc(dest: BoardIndex) -> Bool {
        let validMoves = [(self.row + 1, self.col), (self.row - 1, self.col), (self.row, self.col - 1), (self.row, self.col + 1)]
        for (validRow, validCol) in validMoves {
            if dest.row == validRow && dest.col == validCol {
                return true
            }
        }
        return false
    }
    
    func checkSwordsman(dest: BoardIndex) -> Bool {
        if color == .black {
            let validMoves = [(self.row + 1, self.col + 1), (self.row + 1, self.col), (self.row + 1, self.col - 1)]
            for (validRow, validCol) in validMoves {
                if dest.row == validRow && dest.col == validCol {
                    return true
                }
            }
        } else {//color == .white{
            let validMoves = [(self.row - 1, self.col + 1), (self.row - 1, self.col), (self.row - 1, self.col - 1)]
            for (validRow, validCol) in validMoves {
                if dest.row == validRow && dest.col == validCol {
                    return true
                }
            }
        }
        return false
    }
    
    func checkPike(dest: BoardIndex) -> Bool {
        let validMoves = [(self.row + 2, self.col), (self.row - 2, self.col), (self.row, self.col - 2), (self.row, self.col + 2)]
        for (validRow, validCol) in validMoves {
            if dest.row == validRow && dest.col == validCol {
                return true
            }
        }
        return false
    }
    
    func checkArcher(dest: BoardIndex) -> Bool {
        let validMoves = [(self.row + 2, self.col + 2), (self.row - 2, self.col + 2), (self.row - 2, self.col - 2), (self.row + 2, self.col - 2)]
        for (validRow, validCol) in validMoves {
            if dest.row == validRow && dest.col == validCol {
                return true
            }
        }
        return false
    }
    
    func checkScout(dest: BoardIndex) -> Bool {
        if color == .black{
            let validMoves = [(self.row + 2, self.col + 1), (self.row + 2, self.col - 1), (self.row - 1, self.col)]
            for (validRow, validCol) in validMoves {
                if dest.row == validRow && dest.col == validCol {
                    return true
                }
            }
        } else { //color == .white{
            let validMoves = [(self.row - 2, self.col + 1), (self.row - 2, self.col - 1), (self.row + 1, self.col)]
            for (validRow, validCol) in validMoves {
                if dest.row == validRow && dest.col == validCol {
                    return true
                }
            }
        }
        return false
    }
    
    func checkGuard(dest: BoardIndex) -> Bool {
        return checkKing(dest: dest)
    }
    
    func checkMonk(dest: BoardIndex) -> Bool {
        if color == .black{
            let validMoves = [(self.row + 1, self.col + 1), (self.row + 1, self.col - 1)]
            for (validRow, validCol) in validMoves {
                if dest.row == validRow && dest.col == validCol {
                    return true
                }
            }
        }else {//if color == .white{
            let validMoves = [(self.row - 1, self.col + 1), (self.row - 1, self.col - 1)]
            for (validRow, validCol) in validMoves {
                if dest.row == validRow && dest.col == validCol {
                    return true
                }
            }
        }
        return false
    }
    
    func checkGoblin(dest: BoardIndex) -> Bool {
        if color == .black{
            let validMoves = [(self.row + 1, self.col), (self.row + 2, self.col)]
            for (validRow, validCol) in validMoves {
                if dest.row == validRow && dest.col == validCol {
                    return true
                }
            }
        } else { //color == .white
            let validMoves = [(self.row - 1, self.col), (self.row - 2, self.col)]
            for (validRow, validCol) in validMoves {
                if dest.row == validRow && dest.col == validCol {
                    return true
                }
            }
        }
        return false
    }
    
    func checkFootSoldier(dest:BoardIndex) -> Bool{
        if color == .black{
            let validMoves = [(self.row + 1, self.col), (self.row + 2, self.col), (self.row, self.col - 1), (self.row, self.col + 1)]
            for (validRow, validCol) in validMoves {
                if dest.row == validRow && dest.col == validCol {
                    return true
                }
            }
        } else {//color == .white
            let validMoves = [(self.row - 1, self.col), (self.row - 2, self.col), (self.row, self.col - 1), (self.row, self.col + 1)]
            for (validRow, validCol) in validMoves {
                if dest.row == validRow && dest.col == validCol {
                    return true
                }
            }
        }
        return false
    }
    
    func checkDragonRider(dest: BoardIndex) -> Bool {
        let validMoves =  [(self.row + 6, self.col - 3), (self.row + 6, self.col + 3), (self.row + 4, self.col - 2),(self.row + 4, self.col + 2), (self.row + 3, self.col - 6), (self.row + 3, self.col + 6), (self.row + 2, self.col - 4), (self.row + 2, self.col - 1), (self.row + 2, self.col + 1), (self.row + 2, self.col + 4),(self.row + 1, self.col - 2), (self.row + 1, self.col + 2), (self.row - 6, self.col - 3), (self.row - 6, self.col + 3), (self.row - 4, self.col - 2),(self.row - 4, self.col + 2), (self.row - 3, self.col - 6), (self.row - 3, self.col + 6), (self.row - 2, self.col - 4), (self.row - 2, self.col - 1), (self.row - 2, self.col + 1), (self.row - 2, self.col + 4),(self.row - 1, self.col - 2), (self.row - 1, self.col + 2)]
        for (validRow, validCol) in validMoves {
            if dest.row == validRow && dest.col == validCol {
                return true
            }
        }
        return false
    }
    
    func checkManticore(dest: BoardIndex) -> Bool {
        return checkMonopod(dest: dest) || checkKing(dest: dest)
    }
    
    func checkBatteringRam(dest: BoardIndex) -> Bool{
        if color == .black{
            if checkQueen(dest: dest){
                if dest.row > row{
                    return true
                }
            }
        } else { //color == .white{
            if checkQueen(dest: dest){
                if dest.row < row{
                    return true
                }
            }
        }
        return false
    }
    
    func checkBasilisk(dest: BoardIndex) -> Bool{
        if dest.row == row{
            return checkRook(dest: dest)
        } else{
            return checkKing(dest: dest)
        }
    }
    
    func checkBallista(dest: BoardIndex) -> Bool {
        if color == .black{
            //can move like a rook towards the enemy
            if dest.row > row{
                return checkRook(dest: dest)
                //can move like a bishop away from the enemy
            } else if dest.row < row{
                return checkBishop(dest: dest)
            }
        } else {// if color == .white
            if dest.row < row{
                return checkRook(dest: dest)
            } else if dest.row > row{
                return checkBishop(dest: dest)
            }
        }
        return false
    }
    
    func checkTrebuchet(dest: BoardIndex) -> Bool{
        if color == .black{
            //can move like a bishop towards the enemy
            if dest.row > row{
                return checkBishop(dest: dest)
                //can move like a rook away from the enemy
            } else if dest.row < row{
                return checkRook(dest: dest)
            }
        } else {// if color == .white
            if dest.row < row{
                return checkBishop(dest: dest)
            } else if dest.row > row{
                return checkRook(dest: dest)
            }
        }
        return false
    }
    
    func checkLeftyElf(dest: BoardIndex) -> Bool{
        if color == .black{
            if dest.col > col{//to the right
                return checkBishop(dest: dest)
            } else if dest.col < col{//to the left
                return checkKnight(dest: dest)
            }
        } else {//if color == .white
            if dest.col > col{//to the right
                return checkKnight(dest: dest)
            } else if dest.col < col{//to the left
                return checkBishop(dest: dest)
            }
        }
        return false
    }
    
    func checkRightyElf(dest: BoardIndex) -> Bool{
        if color == .black{
            if dest.col > col{//to the right
                return checkKnight(dest: dest)
            } else if dest.col < col{//to the left
                return checkBishop(dest: dest)
            }
        } else {//if color == .white
            if dest.col > col{//to the right
                return checkBishop(dest: dest)
            } else if dest.col < col{//to the left
                return checkKnight(dest: dest)
            }
        }
        return false
    }
    
    func checkShip(dest: BoardIndex) -> Bool{
        if dest.col == (col + 1) || dest.col == (col - 1){
            if dest.row != row{
                return true
            }
        }
        return false
    }
    
    func checkGriffin(dest: BoardIndex) -> Bool{
        if dest.col == (col + 1) || dest.col == (col - 1){
            if dest.row != row{
                return true
            }
        } else if dest.row == (row + 1) || dest.row == (row - 1){
            if dest.col != col{
                return true
            }
        }
        return false
    }
    
    func checkBoar(dest: BoardIndex) -> Bool{
        let validMoves =  [(self.row + 2, self.col + 2), (self.row + 1, self.col), (self.row + 2, self.col), (self.row + 1, self.col + 1), (self.row + 2, self.col + 2), (self.row, self.col + 1), (self.row, self.col + 2), (self.row, self.col - 1), (self.row, self.col - 2), (self.row + 1, self.col - 1), (self.row + 2, self.col - 2), (self.row, self.col - 1), (self.row, self.col - 2), (self.row - 1, self.col - 1), (self.row - 2, self.col - 2), (self.row - 1, self.col + 1), (self.row + 2, self.col + 2), (self.row - 2, self.col), (self.row - 1, self.col), (self.row - 2, self.col - 2), (self.row + 2, self.col - 2), (self.row - 2, self.col + 2)]
        for (validRow, validCol) in validMoves {
            if dest.row == validRow && dest.col == validCol {
                return true
            }
        }
        return false
    }
    
    func printInfo() -> String {
        var pColor = "Clear"
        if color == .white {
            pColor = "White"
        } else if color == .black {
            pColor = "Black"
        }
        return "\(pColor) \(symbol)"
    }
    
}
