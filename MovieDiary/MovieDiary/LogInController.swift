//
//  LogInController.swift
//  SecondHandBooks
//
//  Created by JerryWang on 2016/11/2.
//  Copyright © 2016年 Jerrywang. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase

class LogInController: UIViewController,UITextFieldDelegate {
    
    let fbReadPermission = ["public_profile", "email", "user_friends"]
    
    let fbParameters = ["fields": "email, first_name, last_name, picture.type(large)"]
    
    let firebaseWorksInstance = FirebaseWorks()
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passWordTextField: UITextField!
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    @IBAction func emailLogIn(_ sender: UIButton) {
        
        handleEmailLogIn()
    }
    
    private func handleEmailLogIn(){
        
        guard let email = emailTextField.text, let password = passWordTextField.text else {
            print("Form is not valid")
            return
        }
        
        if email.isValidEmail() == false{
            emailTextField.text = ""
            emailTextField.attributedPlaceholder = NSAttributedString(string: "電子信箱格式錯誤", attributes: [NSForegroundColorAttributeName:UIColor.getAlertColor()])
            return
        }else if password.characters.count < 6{
            passWordTextField.text = ""
            passWordTextField.attributedPlaceholder = NSAttributedString(string: "密碼請大於6碼", attributes: [NSForegroundColorAttributeName:UIColor.getAlertColor()])
            return //跳出此函數
        }
        
        self.activity.startAnimating()
        
        //帶著信箱密碼登入
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                
                guard let errorString = error?.localizedDescription else{
                    return
                }
                
                if errorString == "There is no user record corresponding to this identifier. The user may have been deleted."{
                    //無帳號 跳註冊
                    self.noAccountAlert()
                    
                }else if errorString == "The password is invalid or the user does not have a password."{
                    //密碼錯誤
                    self.passWordErrorAlert()
                    
                }else{
                    //其他錯誤
                 self.alert()
                }
                return
            }
            
            self.activity.stopAnimating()
            
            let MovieController = UIStoryboard(name: ViewControllerIdentifier.mainControllerIdentifier, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifier.MovieControllerIdentifier)
            self.present(MovieController, animated: true, completion: nil)
            
//            self.dismiss(animated: true, completion: nil)
            
        })
    }
    
    @IBAction func FBLogIn(_ sender: UIButton) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.activity.startAnimating()
        
        FBSDKLoginManager().logIn(withReadPermissions:fbReadPermission, from: self) { (result, error) in
            
            if error != nil{
                //登入失敗 請重新登入
                self.alert()
                print(error!)
                return
            }else if (result?.isCancelled)!{
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.activity.stopAnimating()
                
            }else{
                
                //確定登入fb後，用戶資料再用來登入firebase
                self.signInFireBaseWithFB()
            }
        }
    }
    
    private func signInFireBaseWithFB(){
        
        let fbAccessToken = FBSDKAccessToken.current()
        guard let fbAccessTokenString = fbAccessToken?.tokenString else { return }
        
        let fbCredentials = FIRFacebookAuthProvider.credential(withAccessToken: fbAccessTokenString)
        
        FIRAuth.auth()?.signIn(with: fbCredentials, completion: { (user, error) in
            if error != nil {
                //登入失敗 請重新登入
                self.alert()
                print("Something went wrong with our FB user: ", error ?? "")
                return
            }else{
                
                print("Successfully logged in with our user: ", user ?? "")
                
                guard let uid = user?.uid else {
                    return
                }
                
                guard let profileImageUrl = user?.photoURL?.absoluteString, let email = user?.email, let name = user?.displayName else{
                    return
                }
                
                let values = ["name": name as AnyObject, "email": email as AnyObject, "profileImageUrl": profileImageUrl as AnyObject] as [String: AnyObject]
                
                self.firebaseWorksInstance.registerUserIntoDatabaseWithUID(uid: uid, values: values, completion: { (result) in
                    
                    if result == "Pass"{
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        self.activity.stopAnimating()
                        
                        let MovieController = UIStoryboard(name: ViewControllerIdentifier.mainControllerIdentifier, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifier.MovieControllerIdentifier)
                        self.present(MovieController, animated: true, completion: nil)
                        
//                        self.dismiss(animated: true, completion: nil)
                    }
                })
            }
        })
    }
    
    @IBAction func goToRegisterController(_ sender: UIButton) {
        
        let registerController = UIStoryboard(name: StoryBoardIdentifier.registerLogInSBIdentifier, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifier.registerControllerIdentifier)
        present(registerController, animated: true, completion: nil)
        
    }
    
    
    @IBOutlet weak var emailLogInButton: UIButton!
    @IBOutlet weak var fbLogInButton: UIButton!
    @IBOutlet weak var goToRegisterButton: UIButton!
    
    override func viewDidLoad() {
        
//        showGradientColor()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        self.emailLogInButton.layer.cornerRadius = 6
        self.emailLogInButton.layer.borderWidth = 0.6
        self.emailLogInButton.layer.borderColor = UIColor.lightGray.cgColor
        
        self.fbLogInButton.layer.cornerRadius = 6
        self.fbLogInButton.layer.borderWidth = 0.6
        self.fbLogInButton.layer.borderColor = UIColor.lightGray.cgColor
        
        self.goToRegisterButton.layer.cornerRadius = 6
        self.goToRegisterButton.layer.borderWidth = 0.6
        self.goToRegisterButton.layer.borderColor = UIColor.lightGray.cgColor
        
        emailTextField.attributedPlaceholder = NSAttributedString(string: "電子郵件地址", attributes: [NSForegroundColorAttributeName:UIColor.white])
        
        passWordTextField.attributedPlaceholder = NSAttributedString(string: "密碼", attributes: [NSForegroundColorAttributeName:UIColor.white])
        
        emailTextField.delegate = self
        passWordTextField.delegate = self
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func alert(){
        
        let alertController = UIAlertController(title: "", message: "登入失敗，請重新登入", preferredStyle: .alert)
        let actionY = UIAlertAction(title: "是", style: .default, handler: {
            action in
            
            self.emailTextField.text = nil
            self.passWordTextField.text = nil
            self.emailTextField.attributedPlaceholder = NSAttributedString(string: "電子郵件地址", attributes: [NSForegroundColorAttributeName:UIColor.lightGray])
            
            self.passWordTextField.attributedPlaceholder = NSAttributedString(string: "密碼", attributes: [NSForegroundColorAttributeName:UIColor.lightGray])
        })
        
        alertController.addAction(actionY)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.activity.stopAnimating()
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    private func noAccountAlert(){
        
        let alertController = UIAlertController(title: "", message: "查無此帳號，是否註冊？", preferredStyle: .alert)
        let actionY = UIAlertAction(title: "是", style: .default, handler: {
            action in
            
            let registerController = UIStoryboard(name: StoryBoardIdentifier.registerLogInSBIdentifier, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifier.registerControllerIdentifier)
            self.present(registerController, animated: true, completion: nil)
            
        })
        //把刪除帳號密碼的移到外面
        let actionN = UIAlertAction(title: "否", style: .default, handler: nil)
        
        alertController.addAction(actionN)
        alertController.addAction(actionY)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.activity.stopAnimating()
        
        self.emailTextField.text = nil
        self.passWordTextField.text = nil
        self.emailTextField.attributedPlaceholder = NSAttributedString(string: "電子郵件地址", attributes: [NSForegroundColorAttributeName:UIColor.lightGray])
        
        self.passWordTextField.attributedPlaceholder = NSAttributedString(string: "密碼", attributes: [NSForegroundColorAttributeName:UIColor.lightGray])
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    private func passWordErrorAlert(){
        
        let alertController = UIAlertController(title: "", message: "密碼輸入錯誤，寄送新密碼至電子信箱？", preferredStyle: .alert)
        let actionY = UIAlertAction(title: "是", style: .default, handler: {
            action in
            
            self.passWordTextField.attributedPlaceholder = NSAttributedString(string: "密碼", attributes: [NSForegroundColorAttributeName:UIColor.lightGray])
            
            FIRAuth.auth()?.sendPasswordReset(withEmail: self.emailTextField.text!) { error in
            
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    // Password reset email sent.
                }
            }
        })
        let actionN = UIAlertAction(title: "否", style: .default, handler: nil)
        
        alertController.addAction(actionN)
        alertController.addAction(actionY)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.activity.stopAnimating()
        self.passWordTextField.text = nil
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func hideKeyboard() {
        passWordTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        FBSDKLoginManager().logOut()
        
        do{
            try FIRAuth.auth()?.signOut()
        }catch let logOutError {
            print(logOutError)
        }
    }
}
