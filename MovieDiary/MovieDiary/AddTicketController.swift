//
//  AddTicketController.swift
//  SecondHandBooks
//
//  Created by JerryWang on 2016/11/3.
//  Copyright © 2016年 Jerrywang. All rights reserved.
//

import UIKit

class AddTicketController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITextFieldDelegate,passMovieImageURLProtocol, UITextViewDelegate  {
    
    let firebaseWorksInstance = FirebaseWorks()
    
    var publishedYear : String?
    var movieName : String?
    
    var movieImageURL : String?
    var ticketImageURL : String?
    var receivedMovieImage : UIImage?
    var placeholderLabel : UILabel!
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    @IBOutlet weak var ticketImageView: UIImageView!
    
    @IBOutlet weak var movieNameLabel: UILabel!
    
    @IBOutlet weak var movieImageView: UIImageView!
    
    @IBOutlet weak var feelingTextView: UITextView!
    
    @IBAction func publish(_ sender: UIBarButtonItem) {
        
        if movieNameLabel.text == ""{
            
            alert()
        }else{
            
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            
            activity.startAnimating()
            
            firebaseWorksInstance.uploadToFirebaseStorageUsingImage(image: ticketImageView.image, childName: ChildName.ticketImageChildName, completion: { (ticketImageURL) in
                
                let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
                
                let properties = ["movieName": self.movieNameLabel.text! as AnyObject,"feelingText": self.feelingTextView.text! as AnyObject,"publishedYear": self.publishedYear! as AnyObject,"ticketImageURL":ticketImageURL as AnyObject,"movieImageURL":self.movieImageURL! as AnyObject,"timeStamp": timestamp] as [String: AnyObject]
                
                self.firebaseWorksInstance.uploadToFirebaseDataBaseUsingProperties(childName: ChildName.watchedMoviesChildName, inputProperties: properties, completion: { (result, movieID) in
                    
                    if result != "Pass"{
                        return
                    }
                    
                    self.feelingTextView.text = ""
                    self.ticketImageView.image = nil
                    self.movieNameLabel.text = nil
                    self.publishedYear = nil
                    
                    self.activity.stopAnimating()
                    
                    //回到第一頁
                    if let swrevealViewController = self.presentingViewController as? SWRevealViewController{
                        
                        if let tabBarController = swrevealViewController.frontViewController as? UITabBarController{
                            
                            tabBarController.selectedIndex = 0
                        }
                    }
                    
                    self.dismiss(animated: true, completion: nil)
                    
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
    
    @IBAction func addTicketImage(_ sender: UIButton) {
        
        handleSelectImageView()
        
    }
    
    func received(movieImageURL: String?){
        self.movieImageURL = movieImageURL
    }
    
    @IBAction func backToAddNewMovieController(_ sender: UIBarButtonItem) {
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        self.view.addGestureRecognizer(UISwipeGestureRecognizer(target: self, action: #selector(backToAddNewMovieController(_:))))
        _ = UISwipeGestureRecognizerDirection.right
        
        movieNameLabel.text = movieName
        
        addButtonOnKeyboard()
        
        movieImageView.layer.cornerRadius = 8
        movieImageView.clipsToBounds = true
        movieImageView.image = receivedMovieImage
        
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
        //        movieNameLabel.resignFirstResponder()
        feelingTextView.resignFirstResponder()
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
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
    
}
