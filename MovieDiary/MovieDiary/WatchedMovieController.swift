//
//  WatchedMovieController.swift
//  SecondHandBooks
//
//  Created by JerryWang on 2016/11/5.
//  Copyright © 2016年 Jerrywang. All rights reserved.
//

import UIKit

class WatchedMovieController: UIViewController, UITableViewDelegate, UITableViewDataSource, passSuccessEditedMovieProtocol {
    
    var movies = [Movie]()
    var moviesDictionary = [String: Movie](){
        didSet{
            userDefault.setValue(moviesDictionary.count, forKey:"watched")
            userDefault.synchronize()
//            DataCount.watchedMovieCount = moviesDictionary.count
        }
    }
    
    var moviesDictionaryToCountTickets = [String: Movie](){
        didSet{
//            DataCount.ticketCount = moviesDictionary.count
            userDefault.setValue(moviesDictionaryToCountTickets.count, forKey:"ticket")
            userDefault.synchronize()
        }
    }
    
    let firebaseWorksInstance = FirebaseWorks()
    var selectedMovie : Movie?
    var userDefault = UserDefaults.standard
    var selectedCell : WatchedMovieTableViewCell?
    
    @IBOutlet weak var watchedMoviesTableView: UITableView!
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    @IBOutlet weak var openSlideOutMenuButton: UIBarButtonItem!
    
    @IBOutlet weak var addItemView: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        
//        watchedMoviesTableView.reloadData()
        handleReloadTable()
        
    }
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fetchWatchedMoviesData()
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.hideSpinning), userInfo: nil, repeats: false)
        
//        firebaseWorksInstance.checkIfUserIsLoggedIn { (result) in
//            if result == "Pass"{
//                
//                self.fetchWatchedMoviesData()
//                Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.hideSpinning), userInfo: nil, repeats: false)
//                
//            }else{
//                self.userDefault.setValue(0, forKey:"watched")
//                self.userDefault.setValue(0, forKey:"ticket")
//                self.userDefault.setValue(0
//                    , forKey:"wantWatched")
//                self.userDefault.synchronize()
//                
//                let logInController = UIStoryboard(name: StoryBoardIdentifier.mainControllerIdentifier, bundle: nil).instantiateViewController(withIdentifier: StoryBoardIdentifier.logInControllerIdentifier)
//                self.present(logInController, animated: true, completion: nil)
//            }
//        }
        
        openSlideOutMenuButton.target = self.revealViewController()
        openSlideOutMenuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        
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
            
            self.activity.startAnimating()
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
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.activity.stopAnimating()
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = watchedMoviesTableView.dequeueReusableCell(withIdentifier: CellIdentifier.watchedMoviesCellIdentifier, for: indexPath) as! WatchedMovieTableViewCell
        
        let movie = movies[indexPath.row]
        
        cell.movie = movie
        
        watchedMoviesTableView.deselectRow(at: indexPath, animated: true)
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        selectedMovie = movies[indexPath.row]
        
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "編輯", handler: {
            (action:UITableViewRowAction! , indexPath:IndexPath!) -> Void in
            
            self.tabBarController?.tabBar.isHidden = true
        
            self.selectedCell = (self.watchedMoviesTableView.cellForRow(at: indexPath) as! WatchedMovieTableViewCell)
            
            self.performSegue(withIdentifier: SegueIdentifier.goToEditMovieControllerFromWatchedIdentifier, sender: self)
            
        })

        editAction.backgroundColor = UIColor.lightGray
        
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "刪除", handler: {
            (action:UITableViewRowAction! , indexPath:IndexPath!) -> Void in
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            self.activity.startAnimating()
        
            let movie = self.movies[indexPath.row]
            
            self.firebaseWorksInstance.removeDataFromFirebaseDataBase(movieID: movie.movieIDs!, childName: ChildName.watchedMoviesChildName, completion: { (result) in
                
                if result != "Pass"{
                 return
                }
                
                self.moviesDictionary.removeValue(forKey: movie.movieIDs!)
                if movie.ticketImageURL != ""{
                    self.moviesDictionaryToCountTickets.removeValue(forKey: movie.movieIDs!)
                }
                self.attemptReloadOfTable()
                
            })

        })
        
        deleteAction.backgroundColor = UIColor.getAlertColor()
        
        return [editAction,deleteAction]
    }
    
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
