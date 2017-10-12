//
//  SearchedMovieTableViewCell.swift
//  SecondHandBooks
//
//  Created by JerryWang on 2016/11/17.
//  Copyright © 2016年 Jerrywang. All rights reserved.
//

import UIKit

class SearchedMovieTableViewCell: UITableViewCell {

    @IBOutlet weak var movieImageView: MovieImageView!
    
    @IBOutlet weak var uploadToTicketControllerButton: UIButton!
    
    @IBOutlet weak var movieNameLabel: UILabel!
    
    @IBOutlet weak var publishYearLabel: UILabel!
    
    let zoomInZoomOutViewInstance = ZoomInZoomOutView()
    
    var movie: Movie?{
        didSet{
            setupSearchedMoviesCell()
        }
    }
    
    private func setupSearchedMoviesCell(){
        
        self.movieImageView.image = nil
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        if movie?.movieImageURL != nil{
            movieNameLabel.text = movie?.movieName
            publishYearLabel.text = movie?.publishedYear
        }
    }
    
    func handleZoomTap(tapGesture: UITapGestureRecognizer){
        
        self.zoomInZoomOutViewInstance.performZoomInForStartingImageView(startingImageView: movieImageView, movie: movie!, isContentsShowAble: true)
    }


}
