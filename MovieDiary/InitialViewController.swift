//
//  InitialViewController.swift
//  SecondHandBooks
//
//  Created by JerryWang on 2016/11/22.
//  Copyright © 2016年 Jerrywang. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase

// MARK: - Property
class InitialViewController: UIViewController {

    var userDefault = UserDefaults.standard
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// MARK: - life cycle

extension InitialViewController{ //lifr cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkIfUserIsLoggedIn()
    }
    
    func checkIfUserIsLoggedIn(){
        FirebaseWorks.sharedInstance.checkIfUserIsLoggedIn { (result) in
            if result == "Pass"{
                
                self.perform(#selector(self.goToMovieController), with: nil, afterDelay: 0)
                
            }else{
                
                let dictToSave = ["watched": 0, "ticket": 0, "wantWatched": 0]
                
                self.updateUserDefaults(of: dictToSave)
                
                self.logOutFacebookAndFirebase()
                
                self.perform(#selector(self.goToLogInController), with: nil, afterDelay: 0)
            }
        }
    }
    
    func updateUserDefaults(of data: [String: Any]){
        
        self.userDefault.setValuesForKeys(data)
        
        self.userDefault.synchronize()
    }
    
    func logOutFacebookAndFirebase(){
        
        FBSDKLoginManager().logOut()
        
        do{ //將目前使用者登出
            try FIRAuth.auth()?.signOut()
        }catch let logOutError {
            print(logOutError)
        }
    }
}

// MARK: - 畫面轉換

extension InitialViewController{ //畫面跳轉
    func goToMovieController(){
        
        presentAnotherViewController(in: ViewControllerIdentifier.mainControllerIdentifier, of: ViewControllerIdentifier.MovieControllerIdentifier) { (vc) in
            
        }
    }
    
    func goToLogInController(){
        
        presentAnotherViewController(in: StoryBoardIdentifier.registerLogInSBIdentifier, of: ViewControllerIdentifier.logInControllerIdentifier) { (vc) in
            
        }
    }
}
