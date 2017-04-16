//
//  PassDataProtocol.swift
//  SecondHandBooks
//
//  Created by JerryWang on 2016/11/3.
//  Copyright © 2016年 Jerrywang. All rights reserved.
//

import Foundation
import UIKit


protocol passMovieImageURLProtocol {
    func received(movieImageURL: String?)
}

protocol passAllMoviesDataProtocol {
    func received(movieName: String?, publishedYear: String?, movieImageURL: String?, ticketImageURL: String?, feelingText: String? )
}

protocol passSuccessEditedMovieProtocol {
    func passSuccessEditedMovie(afterEditedMovie: Movie)
    func passDeleteMovieID(deleteMovie: Movie)
}
