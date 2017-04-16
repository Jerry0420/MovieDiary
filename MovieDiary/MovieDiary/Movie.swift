//
//  Movie.swift
//  SecondHandBooks
//
//  Created by JerryWang on 2016/11/4.
//  Copyright © 2016年 Jerrywang. All rights reserved.
//

import Foundation

class Movie : NSObject{
    
    var movieName : String?
    var publishedYear : String?
    var movieImageURL : String?
    var ticketImageURL : String?
    var feelingText : String?
    var movieIDs: String?
    
    var timeStamp : NSNumber?
    
    
    init(dictionary: [String: AnyObject]) {
        super.init()

        feelingText = dictionary["feelingText"] as? String
        movieImageURL = dictionary["movieImageURL"] as? String
        movieName = dictionary["movieName"] as? String
        publishedYear = dictionary["publishedYear"] as? String
        ticketImageURL = dictionary["ticketImageURL"] as? String
        timeStamp = dictionary["timeStamp"] as? NSNumber
        movieIDs = dictionary["movieID"] as? String
    }
    
}
