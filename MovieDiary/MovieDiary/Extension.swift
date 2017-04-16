//
//  Extension.swift
//  SecondHandBooks
//
//  Created by JerryWang on 2016/11/2.
//  Copyright © 2016年 Jerrywang. All rights reserved.
//

import Foundation
import UIKit


struct StoryBoardIdentifier {
    static let registerLogInSBIdentifier = "RegisterLogIn"
}

struct ViewControllerIdentifier {
    
    static let logInControllerIdentifier = "LogInController"
    static let mainControllerIdentifier = "Main"
    static let registerControllerIdentifier = "RegisterController"
    
    static let addNewMovieControllerIdentifier = "AddNewMovieController"
    static let addTicketControllerIdentifier = "AddTicketController"
    static let MovieControllerIdentifier = "initialViewController"
    static let wantWatchedMovieControllerIdentifier = "WantWatchedMovieController"
    static let editMoviesControllerIdentifier = "editMoviesController"
    
    static let addNewWantWatchedMovieControllerIdentifier = "AddNewWantWatchedMovieController"
    
    static let feedBackControllerIdentifier = "FeedBackController"
}

struct Key{
    
    static let URLKeyT = "http://www.omdbapi.com/?t="
    static let URLkeyY = "&y="
    static let URLKeyElse = "&plot=full&r=json"
    static let TiTleKey = "Title"
    static let YearKey = "Year"
    static let PosterKey = "Poster"
    static let ResponseKey = "Response"
    
    //http://www.omdbapi.com/?t=&y=&plot=full&r=json
    //http://www.omdbapi.com/?t=frozen&y=2013&plot=full&r=json
}

struct HTMLKey{
    static let baseURL = "https://tw.movies.yahoo.com/moviesearch_result.html?k="
    
}

struct SegueIdentifier {
    static let goToAddTicketControllerIdentifier = "goToAddTicketController" //刪！
    static let goToEditMovieControllerFromWatchedIdentifier = "goToEditMovieControllerFromWatched"
    static let goToEditMovieControllerFromWantWatchedIdentifier = "goToEditMovieControllerFromWantWatched"
}

struct CellIdentifier{
    static let watchedMoviesCellIdentifier = "watchedMoviesCell"
    static let wantWatchedMoviesCellIdentifier = "wantWatchedMoviesCell"
    static let ticketsItemIdentifier = "ticketsItem"
    static let searchedMovieCellIdentifier = "searchedMovieCell"
}

struct ChildName {
    static let movieImageCHildName = "movie_Image"
    static let watchedMoviesChildName = "Watched Movies"
    static let ticketImageChildName = "ticket_Image"
    static let wantWatchedMoviesChildName = "Want Watched Movies"
}

extension String{
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }

}

extension UIColor{
    
    static func getAlertColor() -> UIColor{
        let alertColor = UIColor(red: 216.0/255.0, green: 36.0/255.0, blue: 36.0/255.0, alpha: 1.0)
        return alertColor
    }
}

