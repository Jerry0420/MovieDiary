//
//  TicketCollectionViewCell.swift
//  SecondHandBooks
//
//  Created by JerryWang on 2016/11/7.
//  Copyright © 2016年 Jerrywang. All rights reserved.
//

import UIKit

class TicketCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var ticketsImageView: UIImageView!
    let zoomInZoomOutViewInstance = ZoomInZoomOutView()
    
    var movie: Movie?{
        didSet{
            setupWatchedMoviesCell()
        }
    }
    
    private func setupWatchedMoviesCell(){
        
        if movie?.ticketImageURL != ""{
        
            self.ticketsImageView.image = nil
            self.ticketsImageView.loadImageUsingCacheWithUrlString(urlString: (movie?.ticketImageURL)!)
            self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        }else{
            self.ticketsImageView.image = nil
        }
    }
    
    func handleZoomTap(tapGesture: UITapGestureRecognizer){
        
        self.zoomInZoomOutViewInstance.performZoomInForStartingImageView(startingImageView: ticketsImageView, movie: movie!)
    }
    
}
