//
//  RWGameData.swift
//  Team Kookaburra Chess
//
//  Created by Christopher Blake Cassell Erquiaga on 7/5/19.
//  Copyright © 2019 Christopher Blake Cassell Erquiaga. All rights reserved.
//

import Foundation

class RWGameData: NSData {
    //player information
    var gold: Int = 0
    var pieces: Array<String> = []
    var rank: Int = 0
    var xp: Int = 0
    //stats
    var gamesPlayed: Int = 0
    var wins: Int = 0
    var losses: Int = 0
    var winStreak: Int = 0
    var lossStreak: Int = 0
    var recordWinStreak: Int = 0
    var recordLossStreak: Int = 0
    var elo: Float = 0
    var championships: Int = 0
    
    private func saveToCloud(){
        //pass information from this object to the cloud
    }
    
    private func loadFromCloud(){
        //load information from the cloud into this object
    }
    
    func save(){
        //pass data into this function
        //store that data in this object
        saveToCloud()
    }
    
    func load(){
        //x = loadFromCloud()
        //take the data from loadFromCloud and store it on this device
        //avoid any conflicts in the save file
            //if there is a conflict, prioritize the more recent data if possible
    }
}
