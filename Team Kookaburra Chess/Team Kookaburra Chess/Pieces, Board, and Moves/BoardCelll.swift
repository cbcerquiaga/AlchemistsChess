//
//  Originally created by Mikael Mukhsikaroyan on 11/1/16.
//  Used and modified under MIT License
//

import UIKit

protocol BoardCellDelegate {
    func didSelect(cell: BoardCell, atRow row: Int, andColumn col: Int)
}

class BoardCell: UIView {
    
    var row: Int
    var col: Int
    var piece: ChessPiece
    var color: UIColor
    var delegate: BoardCellDelegate?
    var pieceImageView:  UIImageView
    
    lazy var invisibleButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(selectedCell(sender:)), for: .touchUpInside)
        return b
    }()
    
    let pieceLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textAlignment = .center
        l.font = UIFont.systemFont(ofSize: 40)
        l.minimumScaleFactor = 0.5
        return l
    }()
    
    
    init(row: Int, col: Int, piece: ChessPiece, color: UIColor) {
        self.row = row
        self.col = col
        self.piece = piece
        self.color = color
        
        self.pieceImageView =  UIImageView(image: piece.symbolImage)
        let imageOffsetY:CGFloat = -5.0
        self.pieceImageView.bounds = CGRect(x: 0, y: 0, width: 50, height: 50)
        
        
        super.init(frame: .zero)
        self.backgroundColor = color
        
        setupViews()
        //special thanks to StackOverflow user Tarun Seera
        //Create Attachment
        let imageAttachment =  NSTextAttachment()
        imageAttachment.image = UIImage(named: piece.symbol)
        //Set bound to reposition
        
        imageAttachment.bounds = CGRect(x: 0, y: imageOffsetY, width: 50, height: 50)
        //Create string with attachment
        let attachmentString = NSAttributedString(attachment: imageAttachment)
        //Initialize mutable string
        let completeText = NSMutableAttributedString(string: "")
        //Add image to mutable string
        completeText.append(attachmentString)
        //Add your text to mutable string
        let  textAfterIcon = NSMutableAttributedString(string: "")
        completeText.append(textAfterIcon)
        pieceLabel.textAlignment = .center
        pieceLabel.attributedText = completeText
        //pieceLabel.text = piece.symbol
        pieceLabel.textColor = piece.color
        
    }
    
    func setupViews() {
        addSubview(invisibleButton)
        invisibleButton.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0).isActive = true
        invisibleButton.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        invisibleButton.widthAnchor.constraint(equalTo: widthAnchor, constant: 0).isActive = true
        invisibleButton.heightAnchor.constraint(equalTo: heightAnchor, constant: 0).isActive = true
        
        addSubview(pieceImageView)
        pieceImageView.translatesAutoresizingMaskIntoConstraints = false
        pieceImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        pieceImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        pieceImageView.centerXAnchor.constraint(lessThanOrEqualTo: pieceImageView.superview!.centerXAnchor).isActive = true
        pieceImageView.centerYAnchor.constraint(lessThanOrEqualTo: pieceImageView.superview!.centerYAnchor).isActive = true
        
        
        //        addSubview(pieceLabel)
        //        pieceLabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0).isActive = true
        //        pieceLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        //        pieceLabel.widthAnchor.constraint(equalTo: widthAnchor, constant: 0).isActive = true
        //        pieceLabel.heightAnchor.constraint(equalTo: heightAnchor, constant: 0).isActive = true
    }
    
    
    
    func configureCell(forPiece piece: ChessPiece) {
        row = piece.row
        col = piece.col
        self.piece = piece
        //pieceLabel.attributedText = imageFromPath(path: "testRook.png")
        //special thanks to StackOverflow user Tarun Seera
        //Create Attachment
        let imageAttachment =  NSTextAttachment()
        imageAttachment.image = UIImage(named: piece.symbol)
        //Set bound to reposition
        let imageOffsetY:CGFloat = -5.0
        imageAttachment.bounds = CGRect(x: 0, y: imageOffsetY, width: 50, height: 50)
        //Create string with attachment
        let attachmentString = NSAttributedString(attachment: imageAttachment)
        //Initialize mutable string
        let completeText = NSMutableAttributedString(string: "")
        //Add image to mutable string
        completeText.append(attachmentString)
        //Add your text to mutable string
        let textAfterIcon = NSMutableAttributedString(string: "")
        completeText.append(textAfterIcon)
        pieceLabel.textAlignment = .center
        pieceLabel.attributedText = completeText
        pieceLabel.text = piece.symbol
        pieceLabel.textColor = piece.color
        backgroundColor = color
        //  addSubview(pieceLabel)
        
        self.pieceImageView.image  = piece.symbolImage
        
        //         addSubview(pieceImageView)
        //        pieceImageView.translatesAutoresizingMaskIntoConstraints = false
        //        pieceImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        //        pieceImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        //        pieceImageView.centerXAnchor.constraint(lessThanOrEqualTo: pieceImageView.superview!.centerXAnchor).isActive = true
        //        pieceImageView.centerYAnchor.constraint(lessThanOrEqualTo: pieceImageView.superview!.centerYAnchor).isActive = true
        //
    }
    
    func setAsPossibleLocation() {
        backgroundColor = hexStringToUIColor(hex: "6DAFFB")
    }
    
    func setAsEnemyLocation(){
        backgroundColor = UIColor.red
    }
    
    func setAsBlocked() {
        backgroundColor = hexStringToUIColor(hex: "BABABA")
    }
    
    //Thanks, StackOverflow user Ethan Strider
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func removeHighlighting() {
        backgroundColor = color
    }
    
    @objc func selectedCell(sender: UIButton) {
        //print("Selected cell at: \(row), \(column)")
        delegate?.didSelect(cell: self, atRow: row, andColumn: col)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
