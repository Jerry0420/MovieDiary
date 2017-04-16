//
//  WatchedMovieTableViewCell.swift
//  SecondHandBooks
//
//  Created by JerryWang on 2016/11/5.
//  Copyright © 2016年 Jerrywang. All rights reserved.
//

import UIKit
import Firebase

class WatchedMovieTableViewCell: UITableViewCell {

    @IBOutlet weak var moviesImageView: UIImageView!
    
    @IBOutlet weak var movieNameLabel: UILabel!
    
    @IBOutlet weak var publishedYearLabel: UILabel!
    
    @IBOutlet weak var timeStanpLabel: UILabel!
    
    @IBOutlet weak var timeLineImageView: UIImageView!
    
    let zoomInZoomOutViewInstance = ZoomInZoomOutView()
    
    var movie: Movie?{
        didSet{
            setupWatchedMoviesCell()
        }
    }

    private func setupWatchedMoviesCell(){
        
        self.timeLineImageView.layer.cornerRadius = 6
        self.timeLineImageView.clipsToBounds = true
        //self.timeLineImageView.layer.cornerRadius = (self.timeLineImageView.bounds.width / 2)
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
        
        if let seconds = movie?.timeStamp?.doubleValue {
            
            let timestampDate = Date(timeIntervalSince1970: seconds)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd"
            timeStanpLabel.text = dateFormatter.string(from: timestampDate)
        }
    }
    
    func handleZoomTap(tapGesture: UITapGestureRecognizer){
        
        self.zoomInZoomOutViewInstance.performZoomInForStartingImageView(startingImageView: moviesImageView, movie: movie!)
    }
}
