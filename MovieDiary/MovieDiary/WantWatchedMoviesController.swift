//
//  WantWatchedMoviesController.swift
//  SecondHandBooks
//
//  Created by JerryWang on 2016/11/6.
//  Copyright © 2016年 Jerrywang. All rights reserved.
//

import UIKit

class WantWatchedMoviesController: UIViewController, UITableViewDelegate, UITableViewDataSource, passSuccessEditedMovieProtocol  {

    var movies = [Movie]()
    var userDefault = UserDefaults.standard
    
    var moviesDictionary = [String: Movie](){
        didSet{
//            DataCount.wantWatchedMovieCount = moviesDictionary.count
            userDefault.setValue(moviesDictionary.count, forKey:"wantWatched")
            userDefault.synchronize()
        }
    }
    
    var selectedMovie : Movie?
    
    let firebaseWorksInstance = FirebaseWorks()
    var selectedCell : WantWatchedMovieTableViewCell?
    
    @IBOutlet weak var WantWatchedMoviesTableView: UITableView!
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    
    override func viewWillAppear(_ animated: Bool) {
//        WantWatchedMoviesTableView.reloadData()
        handleReloadTable()
    }
    
    func passSuccessEditedMovie(afterEditedMovie: Movie) {
        //moviesDictionary[afterEditedMovie.movieIDs!] = afterEditedMovie
    }
    
    func passDeleteMovieID(deleteMovie: Movie) {
        moviesDictionary.removeValue(forKey: deleteMovie.movieIDs!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //檢查是否登入！！！
        
        fetchWatchedMoviesData()
        
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.hideSpinning), userInfo: nil, repeats: false)
    }
    
    func hideSpinning(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        activity.stopAnimating()
    }
    
    private func fetchWatchedMoviesData(){
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        activity.startAnimating()
        
        firebaseWorksInstance.fetchDataFromFirebaseDataBase(childName: ChildName.wantWatchedMoviesChildName, completion:{
            (movie, movieID) in
            
            self.activity.startAnimating()
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
            self.activity.stopAnimating()
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = WantWatchedMoviesTableView.dequeueReusableCell(withIdentifier: CellIdentifier.wantWatchedMoviesCellIdentifier, for: indexPath) as! WantWatchedMovieTableViewCell
        
        let movie = movies[indexPath.row]
        cell.movie = movie
        
        WantWatchedMoviesTableView.deselectRow(at: indexPath, animated: true)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        selectedMovie = movies[indexPath.row]
        
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "已看", handler: {
            (action:UITableViewRowAction! , indexPath:IndexPath!) -> Void in
            
            self.tabBarController?.tabBar.isHidden = true
            
            self.selectedCell = (self.WantWatchedMoviesTableView.cellForRow(at: indexPath) as! WantWatchedMovieTableViewCell)
            
            self.performSegue(withIdentifier: SegueIdentifier.goToEditMovieControllerFromWantWatchedIdentifier, sender: self)
            
            
            
        })
        
        editAction.backgroundColor = UIColor.lightGray
        
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "刪除", handler: {
            (action:UITableViewRowAction! , indexPath:IndexPath!) -> Void in
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            self.activity.startAnimating()
            
            let movie = self.movies[indexPath.row]
            
            self.firebaseWorksInstance.removeDataFromFirebaseDataBase(movieID: movie.movieIDs!, childName: ChildName.wantWatchedMoviesChildName, completion: { (result) in
                
                if result != "Pass"{
                    return
                }
                
                self.moviesDictionary.removeValue(forKey: movie.movieIDs!)
                self.attemptReloadOfTable()
            })
        })
        deleteAction.backgroundColor = UIColor.getAlertColor()
        
        return [editAction,deleteAction]
    }
    
    @IBAction func goToAddWantWatchedMovieController(_ sender: UIBarButtonItem) {
        
        let addNewWantWatchedMovieController = UIStoryboard(name: ViewControllerIdentifier.mainControllerIdentifier, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifier.addNewWantWatchedMovieControllerIdentifier)
        
        self.present(addNewWantWatchedMovieController, animated: true, completion: nil)
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
