//
//  WantWatchedMoviesController.swift
//  SecondHandBooks
//
//  Created by JerryWang on 2016/11/6.
//  Copyright © 2016年 Jerrywang. All rights reserved.
//

import UIKit

class WantWatchedMoviesController: UIViewController{

    var movies = [Movie]()
    var userDefault = UserDefaults.standard
    
    var moviesDictionary = [String: Movie](){
        didSet{
            userDefault.setValue(moviesDictionary.count, forKey:"wantWatched")
            userDefault.synchronize()
        }
    }
    
    var selectedMovie : Movie?
    
    var selectedCell : WantWatchedMovieTableViewCell?
    
    // Pre-Fetching Queue
    fileprivate let imageLoadQueue = OperationQueue()
    fileprivate var imageLoadOperations = [IndexPath: ImageLoadOperation]()
    
    @IBOutlet weak var WantWatchedMoviesTableView: UITableView!
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    func hideSpinning(){
        handleStatusOfNetworkActivity(when: false, of: activity)
    }
    
    fileprivate func fetchWatchedMoviesData(){
        
        handleStatusOfNetworkActivity(when: true, of: activity)
        
        FirebaseWorks.sharedInstance.fetchDataFromFirebaseDataBase(childName: ChildName.wantWatchedMoviesChildName, completion:{
            (movie, movieID) in
            
            self.handleStatusOfNetworkActivity(when: true, of: self.activity)
            self.moviesDictionary[movieID] = movie
            self.attemptReloadOfTable()
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
            
            self.WantWatchedMoviesTableView.reloadData()
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.handleStatusOfNetworkActivity(when: false, of: self.activity)
        })
    }
    
    func downloadImage(fromPhotoURL urlString: String, cell: WantWatchedMovieTableViewCell, at indexPath: IndexPath) {
        
        if let imageLoadOperation = imageLoadOperations[indexPath],
            let image = imageLoadOperation.image {
            DispatchQueue.main.async {
                cell.moviesImageView.image = image
            }
        } else {
            
            guard let url = URL(string: urlString) else{return}
            
            let imageLoadOperation = ImageLoadOperation(url: url)
            
            imageLoadOperation.completionHandler = { [weak self] (image) in
                guard let strongSelf = self else {
                    return
                }
                DispatchQueue.main.async {
                    cell.moviesImageView.image = image
                }
                strongSelf.imageLoadOperations.removeValue(forKey: indexPath)
            }
            imageLoadQueue.addOperation(imageLoadOperation)
            imageLoadOperations[indexPath] = imageLoadOperation
        }
        
    }
}

// MARK: - life cycle
extension WantWatchedMoviesController{
    override func viewWillAppear(_ animated: Bool) {
        handleReloadTable()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //檢查是否登入！！！
        
        fetchWatchedMoviesData()
        
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.hideSpinning), userInfo: nil, repeats: false)
    }
}

// MARK: - Delegate Implement
extension WantWatchedMoviesController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = WantWatchedMoviesTableView.dequeueReusableCell(withIdentifier: CellIdentifier.wantWatchedMoviesCellIdentifier, for: indexPath) as! WantWatchedMovieTableViewCell
        
        let movie = movies[indexPath.row]
        cell.movie = movie
        
        guard let movieImageURL = movie.movieImageURL else { return cell }
        
        downloadImage(fromPhotoURL: movieImageURL, cell: cell, at: indexPath)
        
        WantWatchedMoviesTableView.deselectRow(at: indexPath, animated: true)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let imageLoadOperation = imageLoadOperations[indexPath] else {
            return
        }
        
        if let cell = cell as? WantWatchedMovieTableViewCell {
            cell.moviesImageView.image = nil
        }
        
        imageLoadOperation.cancel()
        imageLoadOperations.removeValue(forKey: indexPath)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        selectedMovie = movies[indexPath.row]
        
        let editAction = createTableViewAction(of: "已看", and: UIColor.lightGray) {
            self.tabBarController?.tabBar.isHidden = true
            
            self.selectedCell = (self.WantWatchedMoviesTableView.cellForRow(at: indexPath) as! WantWatchedMovieTableViewCell)
            
            self.performSegue(withIdentifier: SegueIdentifier.goToEditMovieControllerFromWantWatchedIdentifier, sender: self)
        }
        
        let deleteAction = createTableViewAction(of: "刪除", and: UIColor.getAlertColor()) {
            self.handleStatusOfNetworkActivity(when: true, of: self.activity)
            
            let movie = self.movies[indexPath.row]
            
            FirebaseWorks.sharedInstance.removeDataFromFirebaseDataBase(movieID: movie.movieIDs!, childName: ChildName.wantWatchedMoviesChildName, completion: { (result) in
                
                if result != "Pass"{
                    return
                }
                
                self.moviesDictionary.removeValue(forKey: movie.movieIDs!)
                self.attemptReloadOfTable()
            })
        }
        
        return [editAction,deleteAction]
    }
}

extension WantWatchedMoviesController: passSuccessEditedMovieProtocol{
    func passSuccessEditedMovie(afterEditedMovie: Movie) {
        //moviesDictionary[afterEditedMovie.movieIDs!] = afterEditedMovie
    }
    
    func passDeleteMovieID(deleteMovie: Movie) {
        moviesDictionary.removeValue(forKey: deleteMovie.movieIDs!)
    }
}

//MARK: - 畫面跳轉
extension WantWatchedMoviesController{
    @IBAction func goToAddWantWatchedMovieController(_ sender: UIBarButtonItem) {
        
        presentAnotherViewController(in: ViewControllerIdentifier.mainControllerIdentifier, of: ViewControllerIdentifier.addNewWantWatchedMovieControllerIdentifier, with: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.goToEditMovieControllerFromWantWatchedIdentifier{
            if let editMovieController = segue.destination as? EditMoviesController{
                
                let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
                editMovieController.movie = selectedMovie
                editMovieController.movie?.timeStamp = timestamp
                editMovieController.fromWatchedORWantWatched = "Want Watched Movies"
                editMovieController.delegate = self
                
                if selectedCell?.moviesImageView.image != nil{
                    
                    editMovieController.receivedMovieImage = (selectedCell?.moviesImageView.image)!
                    
                }
            }
            
        }
    }
}
