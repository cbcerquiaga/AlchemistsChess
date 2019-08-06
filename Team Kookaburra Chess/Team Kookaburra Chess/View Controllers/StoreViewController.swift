//
//  StoreViewController.swift
//  Team Kookaburra Chess
//
//  Created by Meghan Stovall on 3/29/19.
//  Copyright © 2019 Christopher Blake Cassell Erquiaga. All rights reserved.
//

import UIKit

class StoreViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    
    
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var goldLabel: UILabel!
    @IBOutlet weak var piecePic: UIImageView!
    @IBOutlet weak var pieceInfo: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var buyOrSellButton: UIButton!
    @IBOutlet weak var getMoreGoldButton: UIButton!
    var gold: Int = 0
    var pickerString = ""
    let pickerData =  ["Archer", "Ballista", "Basilisk", "Battering Ram", "Bishop", "Boar", "Bombard", "Camel", "Centaur", "Demon", "Doppelsoldner", "Dragon Rider", "Dwarf", "Elephant", "Fire Dragon", "Footsoldier", "Gargoyle", "Ghost Queen", "Goblin", "Griffin", "Ice Dragon", "Knight", "Left Handed Elf Warrior", "Mage", "Man at Arms", "Manticore", "Minotaur", "Monk", "Monopod", "Ogre", "Orc Warrior", "Pawn", "Pikeman", "Queen", "Right Handed Elf Warrior", "Rook", "Royal Guard", "Scholar", "Scout", "Ship", "Superking", "Swordsman", "Thunder Chariot", "Trebuchet", "Unicorn"]
    var owned: [String] = [String]()
    
    override func viewDidLoad(){
        owned = UserDefaults.standard.array(forKey: "ownedPieces") as! [String]
        gold = UserDefaults.standard.integer(forKey: "playerGold")
        goldLabel.text = "\(gold)"
        picker.delegate = self
        picker.dataSource = self
        picker.selectRow(0, inComponent: 0, animated: true)
        //get the string from the picker
        pickerString = pickerData[0]
        //compare that string to the piece types
        let piece = getPiece(string: pickerString)
        //assign the .png file to the UIImageview
        piece.setupSymbol()
        piecePic.image = piece.symbolImage
        //assign info text to the info label
        pieceInfo.text = getInfo(piece: piece)
        pieceInfo.contentMode = .scaleToFill
        pieceInfo.numberOfLines = 0
        //assign cost to the top label
        statusLabel.text = getStatus()
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "BackFromStoreSegue", sender: self)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    //updates the screen when the uipicker changes
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        NSLog("Picker Changed")
        //get the string from the picker
        pickerString = pickerData[row]
        //compare that string to the piece types
        let piece = getPiece(string: pickerString)
        //assign the .png file to the UIImageview
        piece.setupSymbol()
        piecePic.image = piece.symbolImage
        //assign info text to the info label
        pieceInfo.text = getInfo(piece: piece)
        pieceInfo.contentMode = .scaleToFill
        pieceInfo.numberOfLines = 0
        //assign cost to the top label
        statusLabel.text = getStatus()
    }
    
    func getStatus() -> String{
        let cost = getCost()
        if owned.contains(pickerString){
            buyOrSellButton.setTitle("Sell!", for: .normal)
            return "You own this piece and can sell it for \(cost) gold"
        } else {
            buyOrSellButton.setTitle("Buy!", for: .normal)
            return "This piece costs \(cost) gold"
        }
    }
    
    func getCost() -> Int{
        let piece = getPiece(string: pickerString)
        if piece.type == .pawn || piece.type == .dwarf || piece.type == .goblin || piece.type == .monk || piece.type == .footSoldier || piece.type == .gargoyle{
            return 100
        } else if piece.type == .ogre || piece.type == .orcWarrior || piece.type == .elephant || piece.type == .manAtArms || piece.type == .swordsman || piece.type == .pikeman || piece.type == .archer || piece.type == .royalGuard || piece.type == .scout || piece.type == .demon || piece.type == .scholar || piece.type == .doppel{
            return 150
        } else if piece.type == .rook || piece.type == .bishop || piece.type == .knight || piece.type == .basilisk || piece.type == .minotaur || piece.type == .fireDragon || piece.type == .iceDragon || piece.type == .monopod || piece.type == .batteringRam || piece.type == .ballista || piece.type == .trebuchet || piece.type == .ghostQueen || piece.type == .leftElf || piece.type == .rightElf || piece.type == .camel || piece.type == .ship || piece.type == .boar || piece.type == .thunderChariot{
            return 250
        } else if piece.type == .queen || piece.type == .centaur || piece.type == .mage || piece.type == .manticore{
            return 400
        } else if piece.type == .bombard || piece.type == .dragonRider || piece.type == .unicorn || piece.type == .superKing || piece.type == .griffin{
            return 600
        } else {
            return 0
        }
    }
    
    func sellPiece(){
        print("It's a bull market")
        owned.remove(at: owned.firstIndex(of: pickerString)!)
        gold = gold + getCost()
        goldLabel.text = "\(gold)"
        UserDefaults.standard.set(gold, forKey: "playerGold")
        UserDefaults.standard.set(owned, forKey: "ownedPieces")
        buyOrSellButton.setTitle("Buy!", for: .normal)
    }
    
    func buyPiece(){
        if gold >= getCost(){
            owned.append(pickerString)
            owned.sort()
            gold = gold - getCost()
            goldLabel.text = "\(gold)"
            UserDefaults.standard.set(gold, forKey: "playerGold")
            UserDefaults.standard.set(owned, forKey: "ownedPieces")
            buyOrSellButton.setTitle("Sell!", for: .normal)
        } else {
            tipLabel.text = "You don't have enough gold to buy this piece"
        }
        print("It's a bear market")
    }
    
    func getPiece(string: String) -> ChessPiece {
        NSLog("getting piece")
        var piece = ChessPiece(row: -1, column: -1, color: .black, type: .dummy, player: .black)
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
        NSLog("getting info")
        var string = ""
        
        switch piece.type{
        case .king:
            string = "Can move and attack one space in every direction. The game ends when a player runs out of kings. You need to place at least one of them or a superking to begin the game."
        case .dummy:
            string = ""
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
    
    
    @IBAction func buyOrSellButtonPressed(_ sender: Any) {
        if buyOrSellButton.titleLabel!.text == "Sell!"{
            sellPiece()
        } else if buyOrSellButton.titleLabel!.text == "Buy!"{
            buyPiece()
        }
    }
    
    @IBAction func buyGoldButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "GoldPurchaseSegue", sender: self)
    }
    
}
