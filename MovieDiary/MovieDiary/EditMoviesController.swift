//
//  EditMoviesController.swift
//  SecondHandBooks
//
//  Created by JerryWang on 2016/11/7.
//  Copyright © 2016年 Jerrywang. All rights reserved.
//

import UIKit

class EditMoviesController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITextFieldDelegate, UITextViewDelegate {
    
    var movie : Movie?
    
    var fromWatchedORWantWatched : String?

    let firebaseWorksInstance = FirebaseWorks()
    
    var delegate : passSuccessEditedMovieProtocol?
    
    var receivedMovieImage : UIImage?
    
    @IBOutlet weak var ticketImageView: UIImageView!
    
    @IBOutlet weak var movieNameLabel: UILabel!
    
    @IBOutlet weak var movieImageView: UIImageView!
    
    @IBOutlet weak var feelingTextView: UITextView!
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    var placeholderLabel : UILabel!
    
    @IBAction func publish(_ sender: UIBarButtonItem) {
        
        if movieNameLabel.text == ""{
        
            alert()
        
        }else{
            
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            
            activity.startAnimating()
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            delegate?.passDeleteMovieID(deleteMovie: movie!)
            
            firebaseWorksInstance.removeDataFromFirebaseDataBase(movieID: (movie?.movieIDs)!, childName: fromWatchedORWantWatched!, completion: { (result) in
                if result != "Pass"{
                
                    return
                }
            })
            
            firebaseWorksInstance.uploadToFirebaseStorageUsingImage(image: ticketImageView.image, childName: ChildName.ticketImageChildName, completion: { (ticketImageURL) in
                
                var properties = ["movieName": self.movieNameLabel.text! as AnyObject,"feelingText": self.feelingTextView.text! as AnyObject,"publishedYear": self.movie?.publishedYear as AnyObject,"ticketImageURL":ticketImageURL as AnyObject,"movieImageURL":self.movie?.movieImageURL as AnyObject,"timeStamp": (self.movie?.timeStamp!)!] as [String: AnyObject]
                
                self.firebaseWorksInstance.uploadToFirebaseDataBaseUsingProperties(childName: ChildName.watchedMoviesChildName, inputProperties: properties, completion: { (result, movieID) in
                    
                    if result != "Pass"{
                        
                        return
                    }
                    
                    properties["movieID"] = movieID as AnyObject
                    let editedMovie = Movie(dictionary: properties)
                    
                    self.delegate?.passSuccessEditedMovie(afterEditedMovie: editedMovie)
                    
                    self.feelingTextView.text = ""
                    self.ticketImageView.image = nil
                    self.movieNameLabel.text = nil
                    //self.movie?.publishedYear = nil segue目的地的變數若有更改，出發點的也會變動
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.activity.stopAnimating()
                    
                    self.tabBarController?.tabBar.isHidden = false
                    
                    _ = self.navigationController?.popViewController(animated: true)
                    
                    
                    /*
                        if let navVC = self.tabBarController?.viewControllers?[2] as? UINavigationController{
                            if let wantWatchedMovieController = navVC.topViewController as? WantWatchedMoviesController{
                                wantWatchedMovieController.moviesDictionary.removeValue(forKey: (self.movie?.movieIDs)!)
                                
                            }
                        }
                    
                    */
                    
//                    let MovieController = UIStoryboard(name: StoryBoardIdentifier.mainControllerIdentifier, bundle: nil).instantiateViewController(withIdentifier: StoryBoardIdentifier.MovieControllerIdentifier)
//                    self.present(MovieController, animated: true, completion: nil)
                    
                })
                
            })
        }
    }
    
    private func alert(){
        
        let alertController = UIAlertController(title: "提示", message: "請填入電影名稱", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "ok", style: .cancel, handler: nil)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func backToWarchedMovieController(_ sender: UIBarButtonItem) {
        self.tabBarController?.tabBar.isHidden = false
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        movieImageView.layer.cornerRadius = 8
        movieImageView.clipsToBounds = true
        
        movieNameLabel.text = movie?.movieName
        feelingTextView.text = movie?.feelingText
        movieImageView.image = receivedMovieImage
        
        self.navigationItem.title = "編輯"
        
        if movie?.ticketImageURL != "" && movie?.ticketImageURL != nil{
            ticketImageView.loadImageUsingCacheWithUrlString(urlString: (movie?.ticketImageURL!)!)
        }
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        addButtonOnKeyboard()
        
        ticketImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectImageView)))
        
    }
    
    func addButtonOnKeyboard()
    {
        feelingTextView.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = "輸入心得...."
        placeholderLabel.font = UIFont.italicSystemFont(ofSize: (feelingTextView.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        feelingTextView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (feelingTextView.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor(white: 0, alpha: 0.3)
        placeholderLabel.isHidden = !feelingTextView.text.isEmpty
        
        let toolbarDone = UIToolbar.init()
        toolbarDone.sizeToFit()
        toolbarDone.backgroundColor = UIColor.clear
        
        let barBtnDone = UIBarButtonItem()
        barBtnDone.image = UIImage(named: "pic2-Small")
        barBtnDone.tintColor = UIColor.black
        barBtnDone.action = #selector(handleSelectImageView)
        
        let barBtnTwo = UIBarButtonItem()
        barBtnTwo.title = "← 點擊新增票根"
        barBtnTwo.tintColor = UIColor.black
        barBtnTwo.isEnabled = false
        
        toolbarDone.items = [barBtnDone, barBtnTwo]
        feelingTextView.inputAccessoryView = toolbarDone
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !feelingTextView.text.isEmpty
    }
    
    func hideKeyboard() {

        feelingTextView.resignFirstResponder()
    }
    
    func handleSelectImageView(){
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            
            selectedImageFromPicker = editedImage
            
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage
        {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            ticketImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
        return true
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
