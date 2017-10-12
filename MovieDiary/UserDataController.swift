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


// MARK: - property
class UserDataController: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var goToFeedBackControllerButton: RegisterButton!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var watchedMovieNumberLabel: UILabel!
    
    @IBOutlet weak var ticketsNumberLabel: UILabel!
    
    @IBOutlet weak var wantWatchedMoviesNumberLabel: UILabel!
    
    @IBOutlet weak var logOutButton: RegisterButton!
    
    var userDefault = UserDefaults.standard
    
    fileprivate func alert(){
        
        showAlert(title: "注意", message: "是否確定登出？", style: .alert, actionATitle: "是", actionAStyle: .default, actionAHandler: {
            
            let dictToSave = ["watched": 0, "ticket": 0, "wantWatched": 0]
            self.userDefault.setValuesForKeys(dictToSave)
            self.userDefault.synchronize()
            
            FBSDKLoginManager().logOut()
            
            do{ //將目前使用者登出
                try FIRAuth.auth()?.signOut()
            }catch let logOutError {
                print(logOutError)
            }
            
            self.presentAnotherViewController(in: StoryBoardIdentifier.registerLogInSBIdentifier, of: ViewControllerIdentifier.logInControllerIdentifier, with: nil)
            
        }, actionBTitle: "否", actionBStyle: .cancel, actionBHandler: nil, actionCTitle: nil, actionCStyle: nil, actionCHandler: nil, completionHandler: nil)
    }
    
}

// MARK: - life cycle
extension UserDataController{
    override func viewWillAppear(_ animated: Bool) {
        
        FirebaseWorks.sharedInstance.fetchUserAndSetupNavBarTitle { (dictionary) in
            
            self.navigationItem.title = "個人資料"
            
            self.emailLabel.text = dictionary["email"] as? String
            self.userNameLabel.text = dictionary["name"] as? String
            
            self.profileImage.layer.cornerRadius = (self.profileImage.bounds.width / 2)
            self.profileImage.clipsToBounds = true
            
//            self.profileImage.loadImageUsingCacheWithUrlString(urlString: dictionary["profileImageUrl"] as! String)
            
            guard let url = URL(string: dictionary["profileImageUrl"] as! String) else{return}
            
            UIImage.downloadImage(url: url, complectionHandler: { [weak self] (image) in
                
                guard let insideSelf = self else{return}
                
                DispatchQueue.main.async {
                    insideSelf.profileImage.image = image
                }
            })
        }
        
        guard let watchedNumber = (userDefault.object(forKey: "watched") as? Int), let ticketNumber = (userDefault.object(forKey: "ticket") as? Int), let wantWatchedNumber = (userDefault.object(forKey: "wantWatched") as? Int)  else {
            return
        }
        
        self.watchedMovieNumberLabel.text = "已看：" + String(watchedNumber)
        self.wantWatchedMoviesNumberLabel.text = "待看：" + String(wantWatchedNumber)
        self.ticketsNumberLabel.text = "票根：" + String(ticketNumber)
    }
}

// MARK: - IBAction, 畫面轉換
extension UserDataController{
    @IBAction func goToFeedBackController(_ sender: UIButton) {
        
        presentAnotherViewController(in: ViewControllerIdentifier.mainControllerIdentifier, of: ViewControllerIdentifier.feedBackControllerIdentifier) { (vc) in
            
            if let feedBackVC = vc as? FeedBackController{
                feedBackVC.userName = self.userNameLabel.text
                feedBackVC.email = self.emailLabel.text
            }
            
        }
    }
    
    @IBAction func logOut(_ sender: UIButton) {
        alert()
    }
}
