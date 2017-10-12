//
//  EditMoviesController.swift
//  SecondHandBooks
//
//  Created by JerryWang on 2016/11/7.
//  Copyright © 2016年 Jerrywang. All rights reserved.
//

import UIKit

class EditMoviesController: UIViewController {
    
    var movie : Movie?
    
    var fromWatchedORWantWatched : String?
    
    var delegate : passSuccessEditedMovieProtocol?
    
    var receivedMovieImage : UIImage?
    
    @IBOutlet weak var ticketImageView: UIImageView!
    
    @IBOutlet weak var movieNameLabel: UILabel!
    
    @IBOutlet weak var movieImageView: MovieImageView!
    
    @IBOutlet weak var feelingTextView: UITextView!
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    var placeholderLabel : UILabel!
    
    func removeDataFromFirebaseDatabase(of movieIDs: String){
        FirebaseWorks.sharedInstance.removeDataFromFirebaseDataBase(movieID: movieIDs, childName: fromWatchedORWantWatched!, completion: { (result) in
            if result != "Pass"{
                
                return
            }
        })
    }
    
    func uploadToFirebaseStorage(){
        FirebaseWorks.sharedInstance.uploadToFirebaseStorageUsingImage(image: ticketImageView.image, childName: ChildName.ticketImageChildName, completion: { (ticketImageURL) in
            
            let properties = ["movieName": self.movieNameLabel.text! as AnyObject,"feelingText": self.feelingTextView.text! as AnyObject,"publishedYear": self.movie?.publishedYear as AnyObject,"ticketImageURL":ticketImageURL as AnyObject,"movieImageURL":self.movie?.movieImageURL as AnyObject,"timeStamp": (self.movie?.timeStamp!)!] as [String: AnyObject]
            
            self.uploadToFirebaseDatabase(with: properties)
            
        })
    }
    
    func uploadToFirebaseDatabase(with properties: [String: AnyObject]){
        
        var properties = properties
        
        FirebaseWorks.sharedInstance.uploadToFirebaseDataBaseUsingProperties(childName: ChildName.watchedMoviesChildName, inputProperties: properties, completion: { (result, movieID) in
            
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
            
            self.handleStatusOfNetworkActivity(when: false, of: self.activity)
            
            self.tabBarController?.tabBar.isHidden = false
            
            _ = self.navigationController?.popViewController(animated: true)
            
        })
    }
    
    fileprivate func alert(){
        showOKAlert(title: "提示", message: "請填入電影名稱", actionATitle: "ok", actionAHandler: nil)
    }
    
    func addPlaceholderLable()
    {
        feelingTextView.delegate = self
        
        placeholderLabel = UILabel()
        placeholderLabel.text = "輸入心得...."
        placeholderLabel.font = UIFont.italicSystemFont(ofSize: (feelingTextView.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (feelingTextView.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor(white: 0, alpha: 0.3)
        placeholderLabel.isHidden = !feelingTextView.text.isEmpty
        
        feelingTextView.addSubview(placeholderLabel)
        
    }
    
    func addToolButtonOnKeyboard(){
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
    
    func hideKeyboard() {

        feelingTextView.resignFirstResponder()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

//MARK: - Life cycle
extension EditMoviesController{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        movieNameLabel.text = movie?.movieName
        feelingTextView.text = movie?.feelingText
        movieImageView.image = receivedMovieImage
        
        self.navigationItem.title = "編輯"
        
        if movie?.ticketImageURL != "" && movie?.ticketImageURL != nil{
            
            guard let url = URL(string: (movie?.ticketImageURL!)!) else{return}
            
            UIImage.downloadImage(url: url, complectionHandler: { [weak self] (image) in
                
                guard let insideSelf = self else{return}
                
                DispatchQueue.main.async {
                    insideSelf.ticketImageView.image = image
                }
            })
            
        }
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        addPlaceholderLable()
        addToolButtonOnKeyboard()
        
        ticketImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectImageView)))
        
    }
}

extension EditMoviesController{
    @IBAction func publish(_ sender: UIBarButtonItem) {
        
        if movieNameLabel.text == ""{
            
            alert()
            
        }else{
            
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            handleStatusOfNetworkActivity(when: true, of: activity)
            delegate?.passDeleteMovieID(deleteMovie: movie!)
            removeDataFromFirebaseDatabase(of: (movie?.movieIDs)!)
            uploadToFirebaseStorage()
        }
    }
}

// MARK: - 畫面轉換
extension EditMoviesController{
    @IBAction func backToWarchedMovieController(_ sender: UIBarButtonItem) {
        self.tabBarController?.tabBar.isHidden = false
        _ = self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - delegate implement
extension EditMoviesController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
        return true
    }
}
extension EditMoviesController: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !feelingTextView.text.isEmpty
    }
}

//MARK: - image picker
extension EditMoviesController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
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
}
