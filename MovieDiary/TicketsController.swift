//
//  TicketsController.swift
//  SecondHandBooks
//
//  Created by JerryWang on 2016/11/7.
//  Copyright © 2016年 Jerrywang. All rights reserved.
//

import UIKit

class TicketsController: UIViewController{

    var movies = [Movie]()
    var moviesDictionary = [String: Movie]()
    
    // Pre-Fetching Queue
    fileprivate let imageLoadQueue = OperationQueue()
    fileprivate var imageLoadOperations = [IndexPath: ImageLoadOperation]()
    
    @IBOutlet weak var ticketsCollectionView: UICollectionView!
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    func hideSpinning(){
        handleStatusOfNetworkActivity(when: false, of: activity)
    }

    fileprivate func fetchWatchedMoviesData(){
        
        handleStatusOfNetworkActivity(when: true, of: activity)
        
        FirebaseWorks.sharedInstance.fetchDataFromFirebaseDataBase(childName: ChildName.watchedMoviesChildName, completion:{
            (movie, movieID) in
            
            if movie.ticketImageURL != ""{
                self.handleStatusOfNetworkActivity(when: true, of: self.activity)
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
            
            self.handleStatusOfNetworkActivity(when: false, of: self.activity)
        })
    }
    
    func downloadImage(fromPhotoURL urlString: String, cell: TicketCollectionViewCell, at indexPath: IndexPath) {
        
        if let imageLoadOperation = imageLoadOperations[indexPath],
            let image = imageLoadOperation.image {
            DispatchQueue.main.async {
                cell.ticketsImageView.image = image
            }
        } else {
            
            guard let url = URL(string: urlString) else{return}
            
            let imageLoadOperation = ImageLoadOperation(url: url)
            
            imageLoadOperation.completionHandler = { [weak self] (image) in
                guard let strongSelf = self else {
                    return
                }
                DispatchQueue.main.async {
                    cell.ticketsImageView.image = image
                }
                strongSelf.imageLoadOperations.removeValue(forKey: indexPath)
            }
            imageLoadQueue.addOperation(imageLoadOperation)
            imageLoadOperations[indexPath] = imageLoadOperation
        }
        
    }
    
}

// MARK: - life cycle
extension TicketsController{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchWatchedMoviesData()
        
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.hideSpinning), userInfo: nil, repeats: false)
        
        self.view.addGestureRecognizer(UISwipeGestureRecognizer(target: self, action: #selector(backToWatchedMovieController(_:))))
        _ = UISwipeGestureRecognizerDirection.right
    }
}


// MARK: - Delegate Implement
extension TicketsController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return moviesDictionary.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = ticketsCollectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.ticketsItemIdentifier, for: indexPath) as! TicketCollectionViewCell
        
        let movie = movies[indexPath.row]
        cell.movie = movie
        
        guard let ticketImageURL = movie.ticketImageURL else { return cell }
        
        downloadImage(fromPhotoURL: ticketImageURL, cell: cell, at: indexPath)
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //點下cell後
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let imageLoadOperation = imageLoadOperations[indexPath] else {
            return
        }
        
        if let cell = cell as? TicketCollectionViewCell {
            cell.ticketsImageView.image = nil
        }
        
        imageLoadOperation.cancel()
        imageLoadOperations.removeValue(forKey: indexPath)
    }
}

extension TicketsController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        
        let itemsPerRow: CGFloat = 4
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        return sectionInsets
    }
}

// MARK: - 畫面跳轉
extension TicketsController{
    @IBAction func backToWatchedMovieController(_ sender: UIBarButtonItem) {
        
        _ = self.navigationController?.popViewController(animated: true)
    }
}
