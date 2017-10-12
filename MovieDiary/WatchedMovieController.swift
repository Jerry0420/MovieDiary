//
//  WatchedMovieController.swift
//  SecondHandBooks
//
//  Created by JerryWang on 2016/11/5.
//  Copyright © 2016年 Jerrywang. All rights reserved.
//

import UIKit

class WatchedMovieController: UIViewController {
    
    var movies = [Movie]()
    var moviesDictionary = [String: Movie](){
        didSet{
            userDefault.setValue(moviesDictionary.count, forKey:"watched")
            userDefault.synchronize()
        }
    }
    
    var moviesDictionaryToCountTickets = [String: Movie](){
        didSet{
            userDefault.setValue(moviesDictionaryToCountTickets.count, forKey:"ticket")
            userDefault.synchronize()
        }
    }
    
    var selectedMovie : Movie?
    var userDefault = UserDefaults.standard
    var selectedCell : WatchedMovieTableViewCell?
    
    // Pre-Fetching Queue
    fileprivate let imageLoadQueue = OperationQueue()
    fileprivate var imageLoadOperations = [IndexPath: ImageLoadOperation]()
    
    @IBOutlet weak var watchedMoviesTableView: UITableView!
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    @IBOutlet weak var openSlideOutMenuButton: UIBarButtonItem!
    
    @IBOutlet weak var addItemView: UIView!
    
    
    func hideSpinning(){
        
        handleStatusOfNetworkActivity(when: false, of: activity)
    }
    
    fileprivate func fetchWatchedMoviesData(){
        
        handleStatusOfNetworkActivity(when: true, of: activity)
        
        FirebaseWorks.sharedInstance.fetchDataFromFirebaseDataBase(childName: ChildName.watchedMoviesChildName, completion:{
            (movie, movieID) in
            
            self.handleStatusOfNetworkActivity(when: true, of: self.activity)
            self.moviesDictionary[movieID] = movie
            self.attemptReloadOfTable()
            
            if movie.ticketImageURL != ""{
                self.moviesDictionaryToCountTickets[movieID] = movie
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
            
            self.watchedMoviesTableView.reloadData()
            
            self.handleStatusOfNetworkActivity(when: false, of: self.activity)
        })
    }
    
    func removeDataFromFirebaseDatabase(of movie: Movie){
        FirebaseWorks.sharedInstance.removeDataFromFirebaseDataBase(movieID: movie.movieIDs!, childName: ChildName.watchedMoviesChildName, completion: { (result) in
            
            if result != "Pass"{
                return
            }
            
            self.moviesDictionary.removeValue(forKey: movie.movieIDs!)
            if movie.ticketImageURL != ""{
                self.moviesDictionaryToCountTickets.removeValue(forKey: movie.movieIDs!)
            }
            self.attemptReloadOfTable()
            
        })
    }
    
    func downloadImage(fromPhotoURL urlString: String, cell: WatchedMovieTableViewCell, at indexPath: IndexPath) {
        
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
extension WatchedMovieController{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fetchWatchedMoviesData()
        
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.hideSpinning), userInfo: nil, repeats: false)
        
        openSlideOutMenuButton.target = self.revealViewController()
        openSlideOutMenuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //        watchedMoviesTableView.reloadData()
        handleReloadTable()
        
    }
}

// MARK: - 畫面跳轉
extension WatchedMovieController{

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == SegueIdentifier.goToEditMovieControllerFromWatchedIdentifier{
            if let editMovieController = segue.destination as? EditMoviesController{
                
                editMovieController.movie = selectedMovie
                editMovieController.fromWatchedORWantWatched = "Watched Movies"
                editMovieController.delegate = self
                
                if selectedCell?.moviesImageView.image != nil{
                    
                    editMovieController.receivedMovieImage = (selectedCell?.moviesImageView.image)!
                    
                }
            }
            
        }
    }
}

// MARK: - delegate implement

extension WatchedMovieController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = watchedMoviesTableView.dequeueReusableCell(withIdentifier: CellIdentifier.watchedMoviesCellIdentifier, for: indexPath) as! WatchedMovieTableViewCell
        
        let movie = movies[indexPath.row]
        
        cell.movie = movie
        
        watchedMoviesTableView.deselectRow(at: indexPath, animated: true)
        
        guard let movieImageURL = movie.movieImageURL else { return cell }
        
        downloadImage(fromPhotoURL: movieImageURL, cell: cell, at: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let imageLoadOperation = imageLoadOperations[indexPath] else {
            return
        }
        
        if let cell = cell as? WatchedMovieTableViewCell {
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
        
        let editAction = createTableViewAction(of: "編輯", and: UIColor.lightGray) {
            self.tabBarController?.tabBar.isHidden = true
            
            self.selectedCell = (self.watchedMoviesTableView.cellForRow(at: indexPath) as! WatchedMovieTableViewCell)
            
            self.performSegue(withIdentifier: SegueIdentifier.goToEditMovieControllerFromWatchedIdentifier, sender: self)
        }
        
        let deleteAction = createTableViewAction(of: "刪除", and: UIColor.getAlertColor()) {
            
            self.handleStatusOfNetworkActivity(when: true, of: self.activity)
            
            let movie = self.movies[indexPath.row]
            
            self.removeDataFromFirebaseDatabase(of: movie)
            
        }
        
        return [editAction,deleteAction]
    }
}

extension WatchedMovieController: passSuccessEditedMovieProtocol{
    func passSuccessEditedMovie(afterEditedMovie: Movie) {
        moviesDictionary[afterEditedMovie.movieIDs!] = afterEditedMovie
        if afterEditedMovie.ticketImageURL != ""{
            self.moviesDictionaryToCountTickets[afterEditedMovie.movieIDs!] = afterEditedMovie
        }
    }
    
    func passDeleteMovieID(deleteMovie: Movie) {
        moviesDictionary.removeValue(forKey: deleteMovie.movieIDs!)
        if deleteMovie.ticketImageURL != ""{
            moviesDictionaryToCountTickets.removeValue(forKey: deleteMovie.movieIDs!)
        }
    }
}
