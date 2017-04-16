//
//  AddNewWantWatchedMovieViewController.swift
//  SecondHandBooks
//
//  Created by JerryWang on 2016/11/19.
//  Copyright © 2016年 Jerrywang. All rights reserved.
//

import UIKit
import Kanna

class AddNewMovieController: UIViewController,UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate {
    
    let dataRequestInstance = DataRequest()
    
    var movieCounts = 0
    
    var movies = [Movie]()
    
    let firebaseWorksInstance = FirebaseWorks()
    
    var movieImageView = UIImageView()
    
    var delegate: passMovieImageURLProtocol?
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    @IBOutlet weak var searchResultsTableView: UITableView!
    
    @IBOutlet weak var inputMovieNameTextField: UITextField!
    
    private func goSearchMovie(){
        
        if inputMovieNameTextField.text == ""{
            inputMovieNameTextField.attributedPlaceholder = NSAttributedString(string: "輸入電影名稱", attributes: [NSForegroundColorAttributeName:UIColor.getAlertColor()])
        }else{
            
            activity.startAnimating()
            
            guard let encodedInputString = inputMovieNameTextField.text!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                return
            }
            
            let temp = HTMLKey.baseURL + encodedInputString
            
            guard let url = URL(string: temp) else {
                return
            }
            
            dataRequestInstance.fetchMovieDataFromWeb(url: url, completion: { (data) in
                
                if let doc = HTML(html: data, encoding: .utf8) {
                    
                    if let counts = doc.xpath("//*[@id=\"ymvmvl\"]/div[1]/div/em[1]")[0]?.text{
                        
                        (Int(counts)! >= 11) ? (self.movieCounts = 10) : (self.movieCounts = Int(counts)!)
                        
                        self.movies = []
                        
                        for i in 1...self.movieCounts{
                            for j in 2...3{
                                
                                let nodes = doc.xpath("//*[@id=\"ymvmvl\"]/div[2]/div/div[\(i)]/div/div[\(j)]/div[1]/a/img")
                                let timeNodes = doc.xpath("//*[@id=\"ymvmvl\"]/div[2]/div/div[\(i)]/div/div[\(j)]/div[2]/span/span")
                                
                                if let movieName = (nodes[0]?.at_xpath("@title")?.text),let movieImageURL = (nodes[0]?.at_xpath("@src")?.text)?.replacingOccurrences(of: "mpost4", with: "mpost"),let publishYear = (timeNodes[0]?.text){
                                    
                                    let dictionary = ["movieName": movieName as AnyObject, "publishedYear": publishYear as AnyObject, "movieImageURL": movieImageURL as AnyObject] as [String: AnyObject]
                                    
                                    let movie = Movie(dictionary: dictionary)
                                    self.movies.append(movie)
                                    
                                    DispatchQueue.main.async(execute: {
                                        
                                        self.searchResultsTableView.reloadData()
                                        self.activity.stopAnimating()
                                    })
                                    
                                }else{
                                    print("官方沒放照片或名稱或年代 or 此i,j 之下無資料")
                                }
                            }
                        }
                        
                    }else{
                        DispatchQueue.main.async(execute: {
                            self.inputMovieNameTextField.text = ""
                            self.activity.stopAnimating()
                            self.inputMovieNameTextField.attributedPlaceholder = NSAttributedString(string: "查無結果，請重新搜尋", attributes: [NSForegroundColorAttributeName:UIColor.getAlertColor()])
                        })
                    }
                }
            })
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchResultsTableView.dequeueReusableCell(withIdentifier: CellIdentifier.searchedMovieCellIdentifier, for: indexPath) as! SearchedMovieTableViewCell
        
        let movie = movies[indexPath.row]
        
        cell.movie = movie
        
        cell.uploadToTicketControllerButton.tag = indexPath.row
        cell.uploadToTicketControllerButton.addTarget(self, action: #selector(uploadToWantWatchedMovies), for: .touchUpInside)
        
        return cell
    }
    
    func uploadToWantWatchedMovies(sender: UIButton){
        
        let selectedMovie = movies[sender.tag]
        
        chooseWantWatchedOrWatchedMoviesAlert(selectedMovie: selectedMovie)
        
    }
    
    private func chooseWantWatchedOrWatchedMoviesAlert(selectedMovie: Movie){
        
        let alertController = UIAlertController(title: "新增到列表", message: "", preferredStyle: .alert)
        let actionA = UIAlertAction(title: "加上票根及心得", style: .default, handler: {
            action in
            
            if selectedMovie.movieImageURL != nil{
                
                self.activity.startAnimating()
                self.movieImageView.loadImageUsingCacheWithUrlString(urlString: (selectedMovie.movieImageURL!))
                
                self.firebaseWorksInstance.uploadToFirebaseStorageUsingImage(image: self.movieImageView.image, childName: ChildName.movieImageCHildName, completion: { (movieImageURL) in
                    selectedMovie.movieImageURL = movieImageURL //從官方的url改成firebase的url
                    
                    let addTicketController = UIStoryboard(name: ViewControllerIdentifier.mainControllerIdentifier, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifier.addTicketControllerIdentifier)
                    self.navigationController?.pushViewController(addTicketController, animated: true)
                    self.activity.stopAnimating()
                    
                    
                    if let addTicketController = self.navigationController?.viewControllers[1] as? AddTicketController{
                        
                        self.delegate = addTicketController
                        
                        self.delegate?.received(movieImageURL: selectedMovie.movieImageURL!)
                        
                        addTicketController.movieName = selectedMovie.movieName!
                        
                        if self.movieImageView.image != nil{
                            addTicketController.receivedMovieImage = self.movieImageView.image!
                        }
                        
                        if selectedMovie.publishedYear != nil{
                            addTicketController.publishedYear = selectedMovie.publishedYear
                            
                        }else{
                            addTicketController.publishedYear = ""
                        }
                        
                        
                        //activity.stopAnimating()
                        
                    }
                })
                
            }else{
                self.activity.startAnimating()
                selectedMovie.movieImageURL = ""
                
                let addTicketController = UIStoryboard(name: ViewControllerIdentifier.mainControllerIdentifier, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifier.addTicketControllerIdentifier)
                self.navigationController?.pushViewController(addTicketController, animated: true)
                
                self.activity.stopAnimating()
                
                if let addTicketController = self.navigationController?.viewControllers[1] as? AddTicketController{
                    
                    self.delegate = addTicketController
                    
                    self.delegate?.received(movieImageURL: selectedMovie.movieImageURL!)
                    
                    addTicketController.movieName = selectedMovie.movieName!
                    
                    if selectedMovie.publishedYear != nil{
                        addTicketController.publishedYear = selectedMovie.publishedYear
                        
                    }else{
                        addTicketController.publishedYear = ""
                    }
                    
                    
                    //activity.stopAnimating()
                    
                }
            }
        })
        
        let actionB = UIAlertAction(title: "新增至待看清單", style: .default, handler: {
            action in
            
            if selectedMovie.movieImageURL != nil && selectedMovie.movieImageURL != ""{
                
                self.activity.startAnimating()
                self.movieImageView.loadImageUsingCacheWithUrlString(urlString: (selectedMovie.movieImageURL!))
                
                self.firebaseWorksInstance.uploadToFirebaseStorageUsingImage(image: self.movieImageView.image, childName: ChildName.movieImageCHildName, completion: { (movieImageURL) in
                    selectedMovie.movieImageURL = movieImageURL //從官方的url改成firebase的url
                    
                    let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
                    
                    let properties = ["movieName": selectedMovie.movieName as AnyObject,"feelingText": "" as AnyObject,"publishedYear": selectedMovie.publishedYear as AnyObject,"ticketImageURL":"" as AnyObject,"movieImageURL":selectedMovie.movieImageURL as AnyObject,"timeStamp": timestamp] as [String: AnyObject]
                    
                    self.firebaseWorksInstance.uploadToFirebaseDataBaseUsingProperties(childName: ChildName.wantWatchedMoviesChildName, inputProperties: properties, completion: { (result, movieID) in
                        
                        if result != "Pass"{
                            return
                        }
                        
                        self.movieImageView.image = nil
                        
                        if let swrevealViewController = self.presentingViewController as? SWRevealViewController{
                            
                            if let tabBarController = swrevealViewController.frontViewController as? UITabBarController{
                                
                                if let wantWatchedMovieController = tabBarController.viewControllers?[1] as? GoToAddMovieController{
                                    wantWatchedMovieController.tabBarSelectedIndex = 2
                                }
                            }
                        }
                        
                        self.dismiss(animated: true, completion: nil)
                        self.activity.stopAnimating()
                    })
                    
                })
                
            }else{
                self.activity.startAnimating()
                selectedMovie.movieImageURL = ""
                
                let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
                
                let properties = ["movieName": selectedMovie.movieName as AnyObject,"feelingText": "" as AnyObject,"publishedYear": selectedMovie.publishedYear as AnyObject,"ticketImageURL":"" as AnyObject,"movieImageURL":selectedMovie.movieImageURL as AnyObject,"timeStamp": timestamp] as [String: AnyObject]
                
                self.firebaseWorksInstance.uploadToFirebaseDataBaseUsingProperties(childName: ChildName.wantWatchedMoviesChildName, inputProperties: properties, completion: { (result, movieID) in
                    
                    if result != "Pass"{
                        return
                    }
                    
                    if let swrevealViewController = self.presentingViewController as? SWRevealViewController{
                        
                        if let tabBarController = swrevealViewController.frontViewController as? UITabBarController{
                            
                            if let wantWatchedMovieController = tabBarController.viewControllers?[1] as? GoToAddMovieController{
                                wantWatchedMovieController.tabBarSelectedIndex = 2
                            }
                        }
                    }
                    
                    self.dismiss(animated: true, completion: nil)
                    self.activity.stopAnimating()
                })
            }
            
            
        })
        
        let actionC = UIAlertAction(title: "取消", style: .default, handler: nil)
        
        alertController.addAction(actionA)
        alertController.addAction(actionB)
        alertController.addAction(actionC)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    @IBAction func goToMovieController(_ sender: UIBarButtonItem) {
        
        if let swrevealViewController = self.presentingViewController as? SWRevealViewController{
            
            if let tabBarController = swrevealViewController.frontViewController as? UITabBarController{
                
                tabBarController.selectedIndex = 0
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func hideKeyboard() {
        inputMovieNameTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        goSearchMovie()
        hideKeyboard()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        inputMovieNameTextField.delegate = self
        inputMovieNameTextField.becomeFirstResponder()
    }
    
}
