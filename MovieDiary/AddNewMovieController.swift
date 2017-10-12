//
//  AddNewWantWatchedMovieViewController.swift
//  SecondHandBooks
//
//  Created by JerryWang on 2016/11/19.
//  Copyright © 2016年 Jerrywang. All rights reserved.
//

import UIKit
import Kanna

class AddNewMovieController: UIViewController {
    
    var movieCounts = 0
    var movies = [Movie]()
    var movieImage = UIImage()
    
    var delegate: passMovieImageURLProtocol?
    
    var upperBoundCounts = 20
    
    // Pre-Fetching Queue
    fileprivate let imageLoadQueue = OperationQueue()
    fileprivate var imageLoadOperations = [IndexPath: ImageLoadOperation]()
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    @IBOutlet weak var searchResultsTableView: UITableView!
    
    @IBOutlet weak var inputMovieNameTextField: UITextField!
    
    fileprivate func goSearchMovie(){
        
        if inputMovieNameTextField.text == ""{
            setUp([inputMovieNameTextField], with: ["輸入電影名稱"], of: [UIColor.getAlertColor()])
        }else{
            
            handleStatusOfNetworkActivity(when: true, of: activity)
            
            guard let inputString = inputMovieNameTextField.text else {
                return
            }
            
            fetchAllMovieNames(searchWith: inputString)
            
            
            //            //以下為app內parse
            //            guard let encodedInputString = inputMovieNameTextField.text!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            //                return
            //            }
            //
            //            let temp = HTMLKey.baseURL + encodedInputString
            //
            //            guard let url = URL(string: temp) else {
            //                return
            //            }
            //
            //            print(url)
            //
            //            dataRequestInstance.fetchMovieDataFromWeb(url: url, completion: { (data) in
            //
            //                if let doc = HTML(html: data, encoding: String.Encoding.utf8) {
            //
            //                    if let counts = doc.xpath("//*[@id=\"ymvmvl\"]/div[1]/div/em[1]")[0].text{
            //
            //                        (Int(counts)! >= 11) ? (self.movieCounts = 10) : (self.movieCounts = Int(counts)!)
            //
            //                        self.movies = []
            //
            //                        for i in 1...self.movieCounts{
            //                            for j in 2...3{
            //                                let nodes = doc.xpath("//*[@id=\"ymvmvl\"]/div[2]/div/div[\(i)]/div/div[\(j)]/div[1]/a/img")
            //                                let timeNodes = doc.xpath("//*[@id=\"ymvmvl\"]/div[2]/div/div[\(i)]/div/div[\(j)]/div[2]/span/span")
            //
            //                                if let movieName = (nodes[0].at_xpath("@title")?.text),let movieImageURL = (nodes[0].at_xpath("@src")?.text)?.replacingOccurrences(of: "mpost4", with: "mpost"),let publishYear = (timeNodes[0].text){
            //
            //                                    let dictionary = ["movieName": movieName as AnyObject, "publishedYear": publishYear as AnyObject, "movieImageURL": movieImageURL as AnyObject] as [String: AnyObject]
            //
            //                                    let movie = Movie(dictionary: dictionary)
            //                                    self.movies.append(movie)
            //
            //                                    DispatchQueue.main.async(execute: {
            //
            //                                        self.searchResultsTableView.reloadData()
            //                                        self.activity.stopAnimating()
            //                                    })
            //
            //                                }else{
            //                                    print("官方沒放照片或名稱或年代 or 此i,j 之下無資料")
            //                                }
            //                            }
            //                        }
            //
            //                    }else{
            //                        DispatchQueue.main.async(execute: {
            //                            self.inputMovieNameTextField.text = ""
            //                            self.activity.stopAnimating()
            //                            self.inputMovieNameTextField.attributedPlaceholder = NSAttributedString(string: "查無結果，請重新搜尋", attributes: [NSForegroundColorAttributeName:UIColor.getAlertColor()])
            //                        })
            //                    }
            //                }
            //            })
            
            //================
        }
    }
    
    func fetchAllMovieNames(searchWith inputString: String){
        FirebaseWorks.sharedInstance.fetchAllMovieNames(under: ChildName.childNames[0], with: ChildName.childNamesOfMovieName, completion: { (allMovieNames) in
            
            self.filterMovieNames(in: allMovieNames, of: inputString)
        })
    }
    
    func filterMovieNames(in allMovieNames: [[String]], of inputString: String){
        
        var totalSearchedResults = [[String]]()
        var totalSearchedMovieCounts = 0
        
        for partialMovieNames in allMovieNames{
            
            var partialSearchedResults = partialMovieNames.filter({ (movieName) -> Bool in
                return (movieName.range(of: inputString) != nil)
            })
            
            partialSearchedResults = partialSearchedResults.reversed()
            totalSearchedMovieCounts += partialSearchedResults.count
            totalSearchedResults.append(partialSearchedResults)
        }
        
        if totalSearchedMovieCounts <= 0{
            //顯示沒搜尋到
            DispatchQueue.main.async(execute: {
                
                self.setUp([self.inputMovieNameTextField], with: ["查無結果，請重新搜尋"], of: [UIColor.getAlertColor()])
                self.handleStatusOfNetworkActivity(when: false, of: self.activity)
            })
        }else{
            
            if totalSearchedMovieCounts >= upperBoundCounts{totalSearchedMovieCounts = upperBoundCounts}
            
            //繼續往下
            fetchFilteredMovieDatasFromFirebase(by: totalSearchedResults, and: totalSearchedMovieCounts)
        }
    }
    
    func fetchFilteredMovieDatasFromFirebase(by totalSearchedResults: [[String]], and totalSearchedMovieCounts: Int){
        FirebaseWorks.sharedInstance.filterDataFromFirebaseDatabase(under: ChildName.childNames[1], in: ChildName.childNamesOfMovieData, with: totalSearchedResults, of: totalSearchedMovieCounts, completion: { (movies) in
            
            if let movies = movies{
                self.movies = movies
                DispatchQueue.main.async(execute: {
                    
                    self.searchResultsTableView.reloadData()
                    
                    self.handleStatusOfNetworkActivity(when: false, of: self.activity)
                })
            }
        })
    }
    
    func uploadToWantWatchedMovies(sender: UIButton){
        
        let selectedMovie = movies[sender.tag]
        
        let indexPath = IndexPath(row: sender.tag, section: 0)
        
        chooseWantWatchedOrWatchedMoviesAlert(selectedMovie: selectedMovie, and: indexPath)
        
    }
    
    private func chooseWantWatchedOrWatchedMoviesAlert(selectedMovie: Movie, and indexPath : IndexPath){
        
        showAlert(title: "新增到列表", message: "", style: .alert, actionATitle: "加上票根及心得", actionAStyle: .default, actionAHandler: {
            self.addTicket(selectedMovie: selectedMovie, and: indexPath)
        }, actionBTitle: "新增至待看清單", actionBStyle: .default, actionBHandler: {
            self.addToWantWatchList(of: selectedMovie, and: indexPath)
        }, actionCTitle: "取消", actionCStyle: .default, actionCHandler: nil, completionHandler: nil)
    }
    
    func addToWantWatchList(of selectedMovie: Movie, and indexPath : IndexPath){
        
        var selectedMovie = selectedMovie
        
        if selectedMovie.movieImageURL != nil && selectedMovie.movieImageURL != ""{
            //確定有照片
            self.handleStatusOfNetworkActivity(when: true, of: self.activity)
            
            let selectedCell = searchResultsTableView.cellForRow(at: indexPath) as! SearchedMovieTableViewCell
            
            
            if let image = selectedCell.movieImageView.image{
                self.movieImage = image
                self.uploadImageToFirebaseStorage(of: selectedMovie)
            }else{
                //避免圖片還沒出現在tableview cell時，就點下了新增到待看
                guard let url = URL(string: (selectedMovie.movieImageURL!)) else{return}
                
                UIImage.downloadImage(url: url, complectionHandler: { [weak self] (image) in
                    
                    guard let insideSelf = self else{return}
                    
                    DispatchQueue.main.async {
                        insideSelf.movieImage = image!
                        
                        insideSelf.uploadImageToFirebaseStorage(of: selectedMovie)
                    }
                })
            }
            
        }else{
            //沒照片URL
            self.handleStatusOfNetworkActivity(when: true, of: self.activity)
            selectedMovie.movieImageURL = ""
            
            let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
            
            let properties = ["movieName": selectedMovie.movieName as AnyObject,"feelingText": "" as AnyObject,"publishedYear": selectedMovie.publishedYear as AnyObject,"ticketImageURL":"" as AnyObject,"movieImageURL":selectedMovie.movieImageURL as AnyObject,"timeStamp": timestamp, "contents": selectedMovie.contents as AnyObject] as [String: AnyObject]
            
            uploadToFirebaseDatabase(with: properties)
            
        }
    }
    
    func uploadImageToFirebaseStorage(of selectedMovie: Movie){
        
        var selectedMovie = selectedMovie
        
        FirebaseWorks.sharedInstance.uploadToFirebaseStorageUsingImage(image: self.movieImage, childName: ChildName.movieImageCHildName, completion: { (movieImageURL) in
            
            selectedMovie.movieImageURL = movieImageURL //從官方的url改成firebase的url
            
            let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
            
            let properties = ["movieName": selectedMovie.movieName as AnyObject,"feelingText": "" as AnyObject,"publishedYear": selectedMovie.publishedYear as AnyObject,"ticketImageURL":"" as AnyObject,"movieImageURL":selectedMovie.movieImageURL as AnyObject,"timeStamp": timestamp, "contents": selectedMovie.contents as AnyObject] as [String: AnyObject]
            
            self.uploadToFirebaseDatabase(with: properties)
            
        })
    }
    
    func uploadToFirebaseDatabase(with properties: [String: AnyObject]){
        FirebaseWorks.sharedInstance.uploadToFirebaseDataBaseUsingProperties(childName: ChildName.wantWatchedMoviesChildName, inputProperties: properties, completion: { (result, movieID) in
            
            if result != "Pass"{
                return
            }
            
            //新增待看完後，跑去tab 2
            self.dismissSelfAndGoToWantWatchList()
            self.handleStatusOfNetworkActivity(when: false, of: self.activity)
        })
    }
    
    func uploadToFirebaseStorage(of selectedMovie: Movie){
        
        var selectedMovie = selectedMovie
        
        FirebaseWorks.sharedInstance.uploadToFirebaseStorageUsingImage(image: self.movieImage, childName: ChildName.movieImageCHildName, completion: { (movieImageURL) in
            
            selectedMovie.movieImageURL = movieImageURL //從官方的url改成firebase的url
            
            self.goToAddTicketVC(of: selectedMovie)
        })
    }
    
    func goToAddTicketVC(of selectedMovie: Movie){
        
        self.goToAddTicketVC()
        
        self.handleStatusOfNetworkActivity(when: false, of: self.activity)
        
        if let addTicketController = self.navigationController?.viewControllers[1] as? AddTicketController{
            
            self.delegate = addTicketController
            
            self.delegate?.received(movieImageURL: selectedMovie.movieImageURL!)
            
            addTicketController.movieName = selectedMovie.movieName!
            
            if selectedMovie.publishedYear != nil{
                addTicketController.publishedYear = selectedMovie.publishedYear
                
            }else{
                addTicketController.publishedYear = ""
            }
            
            if self.movieImage != nil{
                addTicketController.receivedMovieImage = self.movieImage
            }
            
        }
    }
    
    
    func addTicket(selectedMovie: Movie, and indexPath : IndexPath){
        
        var selectedMovie = selectedMovie
        
        if selectedMovie.movieImageURL != nil{
            
            handleStatusOfNetworkActivity(when: true, of: self.activity)

            let selectedCell = searchResultsTableView.cellForRow(at: indexPath) as! SearchedMovieTableViewCell
            
            if let image = selectedCell.movieImageView.image{
                self.movieImage = image
                self.uploadToFirebaseStorage(of: selectedMovie)
            }else{
             
                //避免圖片還沒出現在tableview cell時，就點下了新增到票根
                guard let url = URL(string: (selectedMovie.movieImageURL!)) else{return}
                
                UIImage.downloadImage(url: url, complectionHandler: { [weak self] (image) in
                    
                    guard let insideSelf = self else{return}
                    
                    DispatchQueue.main.async {
                        insideSelf.movieImage = image!
                        insideSelf.uploadToFirebaseStorage(of: selectedMovie)
                    }
                })
            }
            
        }else{
            handleStatusOfNetworkActivity(when: true, of: self.activity)
            
            selectedMovie.movieImageURL = ""
            
            goToAddTicketVC(of: selectedMovie)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func hideKeyboard() {
        inputMovieNameTextField.resignFirstResponder()
    }
    
    func downloadImage(fromPhotoURL urlString: String, cell: SearchedMovieTableViewCell, at indexPath: IndexPath) {
        
        if let imageLoadOperation = imageLoadOperations[indexPath],
            let image = imageLoadOperation.image {
            DispatchQueue.main.async {
                cell.movieImageView.image = image
            }
        } else {
            
            guard let url = URL(string: urlString) else{return}
            
            let imageLoadOperation = ImageLoadOperation(url: url)
            
            imageLoadOperation.completionHandler = { [weak self] (image) in
                guard let strongSelf = self else {
                    return
                }
                DispatchQueue.main.async {
                    cell.movieImageView.image = image
                }
                strongSelf.imageLoadOperations.removeValue(forKey: indexPath)
            }
            imageLoadQueue.addOperation(imageLoadOperation)
            imageLoadOperations[indexPath] = imageLoadOperation
        }
        
    }
    
}

// MARK: - 畫面轉換
extension AddNewMovieController{
    @IBAction func goToMovieController(_ sender: UIBarButtonItem) {
        baceToFirstTab()
    }
    
    func baceToFirstTab(){
        if let swrevealViewController = self.presentingViewController as? SWRevealViewController{
            
            if let tabBarController = swrevealViewController.frontViewController as? UITabBarController{
                
                tabBarController.selectedIndex = 0
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func goToAddTicketVC(){
        self.presentAnotherViewControllerUnderNavigationController(in: ViewControllerIdentifier.mainControllerIdentifier, of: ViewControllerIdentifier.addTicketControllerIdentifier, with: nil)
    }
    
    func dismissSelfAndGoToWantWatchList(){
        //新增待看完後，跑去tab 2
        if let swrevealViewController = self.presentingViewController as? SWRevealViewController{
            
            if let tabBarController = swrevealViewController.frontViewController as? UITabBarController{
                
                if let wantWatchedMovieController = tabBarController.viewControllers?[1] as? GoToAddMovieController{
                    wantWatchedMovieController.tabBarSelectedIndex = 2
                }
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - life cycle
extension AddNewMovieController{
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        inputMovieNameTextField.delegate = self
        inputMovieNameTextField.becomeFirstResponder()
    }
}

// MARK: - delegate implement
extension AddNewMovieController: SetUpTextFieldDelegate{}

extension AddNewMovieController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        goSearchMovie()
        hideKeyboard()
        return true
    }
}

extension AddNewMovieController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchResultsTableView.dequeueReusableCell(withIdentifier: CellIdentifier.searchedMovieCellIdentifier, for: indexPath) as! SearchedMovieTableViewCell
        
        let movie = movies[indexPath.row]
        
        cell.movie = movie
        cell.uploadToTicketControllerButton.tag = indexPath.row
        cell.uploadToTicketControllerButton.addTarget(self, action: #selector(uploadToWantWatchedMovies), for: .touchUpInside)
        
        guard let movieImageURL = movie.movieImageURL else { return cell }
        
        downloadImage(fromPhotoURL: movieImageURL, cell: cell, at: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let imageLoadOperation = imageLoadOperations[indexPath] else {
            return
        }
        
        if let cell = cell as? SearchedMovieTableViewCell {
            cell.movieImageView.image = nil
        }
        
        imageLoadOperation.cancel()
        imageLoadOperations.removeValue(forKey: indexPath)
    }
}
