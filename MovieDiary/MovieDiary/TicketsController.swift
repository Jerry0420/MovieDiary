//
//  TicketsController.swift
//  SecondHandBooks
//
//  Created by JerryWang on 2016/11/7.
//  Copyright © 2016年 Jerrywang. All rights reserved.
//

import UIKit

class TicketsController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{

    var movies = [Movie]()
    var moviesDictionary = [String: Movie]()
    
    let firebaseWorksInstance = FirebaseWorks()
    
    @IBOutlet weak var ticketsCollectionView: UICollectionView!
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchWatchedMoviesData()
        
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.hideSpinning), userInfo: nil, repeats: false)
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backToWatchedMovieController(_:))))
        
        self.view.addGestureRecognizer(UISwipeGestureRecognizer(target: self, action: #selector(backToWatchedMovieController(_:))))
        _ = UISwipeGestureRecognizerDirection.right
    }
    
    func hideSpinning(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        activity.stopAnimating()
    }

    private func fetchWatchedMoviesData(){
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        activity.startAnimating()
        
        firebaseWorksInstance.fetchDataFromFirebaseDataBase(childName: ChildName.watchedMoviesChildName, completion:{
            (movie, movieID) in
            
            if movie.ticketImageURL != ""{
                self.activity.startAnimating()
                self.moviesDictionary[movieID] = movie
                
                self.attemptReloadOfTable()
                
            }
            
        })
    }
    
    var timer: Timer?
    
    func attemptReloadOfTable(){
        
        self.timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
        
    }
    
    func handleReloadTable() {
        
        self.movies = Array(self.moviesDictionary.values)
        
        self.movies.sort(by: { (movie1, movie2) -> Bool in
            
            return (movie1.timeStamp?.intValue)! > (movie2.timeStamp?.intValue)!
        })
        
        DispatchQueue.main.async(execute: {
            
            self.ticketsCollectionView.reloadData()
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.activity.stopAnimating()
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return moviesDictionary.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = ticketsCollectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.ticketsItemIdentifier, for: indexPath) as! TicketCollectionViewCell
        
        let movie = movies[indexPath.row]
        cell.movie = movie
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
        //點下cell後
    }
    
    @IBAction func backToWatchedMovieController(_ sender: UIBarButtonItem) {
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    
    let itemsPerRow: CGFloat = 4
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return sectionInsets.left
//    }
    

}
