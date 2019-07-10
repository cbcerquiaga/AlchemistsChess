//
//  HowToViewController.swift
//  Team Kookaburra Chess
//
//  Created by Meghan Stovall on 3/30/19.
//  Copyright © 2019 Christopher Blake Cassell Erquiaga. All rights reserved.
//

import Foundation

import UIKit

class HowToViewController: UIViewController {
    

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        loadScrollView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //self.textView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    func loadScrollView(){
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton!) {
        self.performSegue(withIdentifier: "BackFromHowToSegue", sender: self)
    }
    
}
