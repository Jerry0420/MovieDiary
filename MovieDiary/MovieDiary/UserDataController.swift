//
//  UserDataController.swift
//  SecondHandBooks
//
//  Created by JerryWang on 2016/11/10.
//  Copyright © 2016年 Jerrywang. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class UserDataController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var goToFeedBackControllerButton: UIButton!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var watchedMovieNumberLabel: UILabel!
    
    @IBOutlet weak var ticketsNumberLabel: UILabel!
    
    @IBOutlet weak var wantWatchedMoviesNumberLabel: UILabel!
    
    @IBOutlet weak var logOutButton: UIButton!
    
    
    let firebaseWorksInstance = FirebaseWorks()
    var userDefault = UserDefaults.standard
    
    @IBAction func logOut(_ sender: UIButton) {
        alert()
    }
    private func alert(){
        
        let alertController = UIAlertController(title: "注意", message: "是否確定登出？", preferredStyle: .alert)
        let actionY = UIAlertAction(title: "是", style: .default){
            action in
            
            self.userDefault.setValue(0, forKey:"watched")
            self.userDefault.setValue(0, forKey:"ticket")
            self.userDefault.setValue(0
                , forKey:"wantWatched")
            self.userDefault.synchronize()
            
            FBSDKLoginManager().logOut()
            
            do{ //將目前使用者登出
                try FIRAuth.auth()?.signOut()
            }catch let logOutError {
                print(logOutError)
            }
            
            let HomeVC = UIStoryboard(name: StoryBoardIdentifier.registerLogInSBIdentifier, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifier.logInControllerIdentifier)
            self.present(HomeVC, animated: true, completion: nil)
        }
        
        let actionN = UIAlertAction(title: "否", style: .cancel, handler: nil)
        alertController.addAction(actionY)
        alertController.addAction(actionN)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        firebaseWorksInstance.fetchUserAndSetupNavBarTitle { (dictionary) in
            
            self.navigationItem.title = "個人資料"
            
            self.emailLabel.text = dictionary["email"] as? String
            self.userNameLabel.text = dictionary["name"] as? String
            
            self.profileImage.layer.cornerRadius = (self.profileImage.bounds.width / 2)
            self.profileImage.clipsToBounds = true
            self.profileImage.loadImageUsingCacheWithUrlString(urlString: dictionary["profileImageUrl"] as! String)
        }
        
        guard let watchedNumber = (userDefault.object(forKey: "watched") as? Int), let ticketNumber = (userDefault.object(forKey: "ticket") as? Int), let wantWatchedNumber = (userDefault.object(forKey: "wantWatched") as? Int)  else {
            return
        }
        
        self.watchedMovieNumberLabel.text = "已看：" + String(watchedNumber)
        self.wantWatchedMoviesNumberLabel.text = "待看：" + String(wantWatchedNumber)
        self.ticketsNumberLabel.text = "票根：" + String(ticketNumber)
        
//        if DataCount.watchedMovieCount == 0{
//            DataCount.ticketCount = 0
//        }
//        
//        self.watchedMovieNumberLabel.text = "已看：" + String(DataCount.watchedMovieCount)
//        self.wantWatchedMoviesNumberLabel.text = "待看：" + String(DataCount.wantWatchedMovieCount)
//        self.ticketsNumberLabel.text = "票根：" + String(DataCount.ticketCount)
    }
    
    @IBAction func goToFeedBackController(_ sender: UIButton) {
        
        let feedBackController = UIStoryboard(name: ViewControllerIdentifier.mainControllerIdentifier, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifier.feedBackControllerIdentifier)
        self.present(feedBackController, animated: true, completion: nil)
        
        if let feedBackVC = self.presentedViewController as? FeedBackController{
            feedBackVC.userName = userNameLabel.text
            feedBackVC.email = emailLabel.text
        }
        
    }
    override func viewDidLoad() {
        self.logOutButton.layer.cornerRadius = 6
        self.logOutButton.layer.borderWidth = 0.6
        self.logOutButton.layer.borderColor = UIColor.lightGray.cgColor
        
        self.goToFeedBackControllerButton.layer.cornerRadius = 6
        self.goToFeedBackControllerButton.layer.borderWidth = 0.6
        self.goToFeedBackControllerButton.layer.borderColor = UIColor.lightGray.cgColor
    }
        
}
