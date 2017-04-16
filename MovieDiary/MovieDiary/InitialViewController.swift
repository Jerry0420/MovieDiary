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

class InitialViewController: UIViewController {

    let firebaseWorksInstance = FirebaseWorks()
    var userDefault = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        firebaseWorksInstance.checkIfUserIsLoggedIn { (result) in
            if result == "Pass"{
                
                self.perform(#selector(self.goToMovieController), with: nil, afterDelay: 0)
                
            }else{
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
                
                self.perform(#selector(self.goToLogInController), with: nil, afterDelay: 0)
            }
        }
    }
    
    func goToMovieController(){
        let MovieController = UIStoryboard(name: ViewControllerIdentifier.mainControllerIdentifier, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifier.MovieControllerIdentifier)
        self.present(MovieController, animated: true, completion: nil)
        
    }
    
    func goToLogInController(){
        let logInController = UIStoryboard(name: StoryBoardIdentifier.registerLogInSBIdentifier, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifier.logInControllerIdentifier)
        self.present(logInController, animated: true, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
}
