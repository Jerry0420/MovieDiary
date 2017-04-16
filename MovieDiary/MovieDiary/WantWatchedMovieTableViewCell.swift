//
//  WantWatchedMovieTableViewCell.swift
//  SecondHandBooks
//
//  Created by JerryWang on 2016/11/7.
//  Copyright © 2016年 Jerrywang. All rights reserved.
//

import UIKit
import Firebase

class WantWatchedMovieTableViewCell: UITableViewCell {

    @IBOutlet weak var moviesImageView: UIImageView!
    
    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var publishedYearLabel: UILabel!
    
    let zoomInZoomOutViewInstance = ZoomInZoomOutView()
    
    var movie: Movie?{
        didSet{
            setupWatchedMoviesCell()
        }
    }
    
    private func setupWatchedMoviesCell(){

        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        
        if movie?.movieImageURL != "" && movie?.movieImageURL != nil{
            
            self.movieNameLabel.text = movie?.movieName
            self.publishedYearLabel.text = movie?.publishedYear
            self.moviesImageView.image = nil
            self.moviesImageView.loadImageUsingCacheWithUrlString(urlString: (movie?.movieImageURL)!)
            
            self.moviesImageView.layer.cornerRadius = 8
            self.moviesImageView.clipsToBounds = true
            
        }else{
            self.movieNameLabel.text = movie?.movieName
            self.publishedYearLabel.text = movie?.publishedYear
            self.moviesImageView.image = nil
        }
    }
    
    func handleZoomTap(tapGesture: UITapGestureRecognizer){
        
        self.zoomInZoomOutViewInstance.performZoomInForStartingImageView(startingImageView: moviesImageView, movie: movie!)
    }
}
