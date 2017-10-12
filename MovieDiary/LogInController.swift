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

// MARK: - Property, function
class LogInController: UIViewController {
    
    let fbReadPermission = ["public_profile", "email", "user_friends"]
    
    let fbParameters = ["fields": "email, first_name, last_name, picture.type(large)"]
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passWordTextField: UITextField!
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    @IBOutlet weak var emailLogInButton: RegisterButton!
    @IBOutlet weak var fbLogInButton: RegisterButton!
    @IBOutlet weak var goToRegisterButton: RegisterButton!
    
    fileprivate func signInFireBaseWithFB(of userData : [String: AnyObject]){
        
        let fbAccessToken = FBSDKAccessToken.current()
        guard let fbAccessTokenString = fbAccessToken?.tokenString else { return }
        
        let fbCredentials = FIRFacebookAuthProvider.credential(withAccessToken: fbAccessTokenString)
        
        signInFirebase(with: fbCredentials, of: userData)
    }
    
    func signInFirebase(with fbCredentials: FIRAuthCredential, of userData: [String: AnyObject]){
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
                
                self.saveUserDataIntoFirebaseDatabase(with: uid, and: userData)
            }
        })
    }
    
    func saveUserDataIntoFirebaseDatabase(with uid: String, and userData: [String: AnyObject]){
        FirebaseWorks.sharedInstance.registerUserIntoDatabaseWithUID(uid: uid, values: userData, completion: { (result) in
            
            if result == "Pass"{
                
                self.handleStatusOfNetworkActivity(when: false, of: self.activity)
                
                self.goToInitialViewController()
                
            }
        })
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    fileprivate func alert(){
        
        showOKAlert(title: "", message: "登入失敗，請重新登入", actionATitle: "是", actionAHandler: {
            
            self.setUp([self.emailTextField, self.passWordTextField], with: ["電子郵件地址", "密碼"], of: [UIColor.lightGray, UIColor.lightGray])
            
            self.handleStatusOfNetworkActivity(when: false, of: self.activity)
        })
    }
    
    fileprivate func noAccountAlert(){
        
        self.showAlert(title: "", message: "查無此帳號，是否註冊？", style: .alert, actionATitle: "是", actionAStyle: .default, actionAHandler: {
            self.goToRegisterViewController()
        }, actionBTitle: "否", actionBStyle: .default, actionBHandler: nil, actionCTitle: nil, actionCStyle: nil, actionCHandler: nil, completionHandler: {
            
            self.handleStatusOfNetworkActivity(when: false, of: self.activity)
            
            self.setUp([self.emailTextField, self.passWordTextField], with: ["電子郵件地址", "密碼"], of: [UIColor.lightGray, UIColor.lightGray])
        })
    }
    
    fileprivate func passWordErrorAlert(){
        
        self.showAlert(title: "", message: "密碼輸入錯誤，寄送新密碼至電子信箱？", style: .alert, actionATitle: "是", actionAStyle: .default, actionAHandler: {
            
            self.setUp([self.passWordTextField], with: ["密碼"], of: [UIColor.lightGray])
            
            let email = self.emailTextField.text!
            
            self.sendPasswordReset(of: email)
            
        }, actionBTitle: "否", actionBStyle: .default, actionBHandler: nil, actionCTitle: nil, actionCStyle: nil, actionCHandler: nil) {
            self.handleStatusOfNetworkActivity(when: false, of: self.activity)
        }
    }
    
    func sendPasswordReset(of email: String){
        FIRAuth.auth()?.sendPasswordReset(withEmail: email) { error in
            
            if let error = error {
                print(error.localizedDescription)
            } else {
                // Password reset email sent.
            }
        }
    }
    
    func hideKeyboard() {
        passWordTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
    }
    
    func signInFirebase(withEmail email: String, password: String){
        
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
            self.handleStatusOfNetworkActivity(when: false, of: self.activity)
            self.goToInitialViewController()
            
        })
    }
    
    func fetchFacebookDataToLogin(){
        
        FBSDKGraphRequest(graphPath: "me", parameters: self.fbParameters).start(completionHandler: {
            connection, result, error -> Void in
            
            if error != nil {
                print("longinerror =\(error)")
            } else {
                
                if let resultNew = result as? [String:Any]{
                    
                    guard let firstName = resultNew["first_name"] as? String, let lastName = resultNew["last_name"] as? String,let email = resultNew["email"]  as? String, let picture = resultNew["picture"] as? NSDictionary, let data = picture["data"] as? NSDictionary, let profileImageUrl = data["url"] as? String else{
                        return
                    }
                    
                    let name = lastName + firstName
                    
                    let values = ["name": name as AnyObject, "email": email as AnyObject, "profileImageUrl": profileImageUrl as AnyObject] as [String: AnyObject]
                    
                    
                    self.signInFireBaseWithFB(of: values)
                }
            }
        })
    }
    
}

// MARK: - IBAction function
extension LogInController{
    
    @IBAction func goToRegisterController(_ sender: UIButton) {
        
        goToRegisterViewController()
    }
    
    @IBAction func emailLogIn(_ sender: UIButton) {
        
        handleEmailLogIn()
    }
    
    private func handleEmailLogIn(){
        
        guard let email = emailTextField.text, let password = passWordTextField.text else {
            print("Form is not valid")
            return
        }
        
        if email.isValidEmail() == false{
            setUp([emailTextField], with: ["電子信箱格式錯誤"], of: [UIColor.getAlertColor()])
            return
        }else if password.characters.count < 6{
            
            setUp([passWordTextField], with: ["密碼請大於6碼"], of: [UIColor.getAlertColor()])
            return //跳出此函數
        }
        
        self.handleStatusOfNetworkActivity(when: true, of: self.activity)
        
        //帶著信箱密碼登入
        self.signInFirebase(withEmail: email, password: password)
        
    }
    
    @IBAction func FBLogIn(_ sender: UIButton) {
        
        handleStatusOfNetworkActivity(when: true, of: activity)
        
        FBSDKLoginManager().logIn(withReadPermissions:fbReadPermission, from: self) { (result, error) in
            
            if error != nil{
                //登入失敗 請重新登入
                self.alert()
                print(error!)
                return
            }else if (result?.isCancelled)!{
                
                self.handleStatusOfNetworkActivity(when: false, of: self.activity)
                
            }else{
                //確定登入fb後，用戶資料再用來登入firebase
                self.fetchFacebookDataToLogin()
            }
        }
    }
}

// MARK: - 畫面轉換
extension LogInController{
    
    func goToRegisterViewController(){
        
        presentAnotherViewController(in: StoryBoardIdentifier.registerLogInSBIdentifier, of: ViewControllerIdentifier.registerControllerIdentifier) { (vc) in
            
        }
    }
    
    func goToInitialViewController(){
        presentAnotherViewController(in: ViewControllerIdentifier.mainControllerIdentifier, of: ViewControllerIdentifier.MovieControllerIdentifier) { (vc) in
            
        }
    }
}

// MARK: - delegate implement
extension LogInController: SetUpTextFieldDelegate{}

extension LogInController:UITextFieldDelegate{

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
        return true
    }
}

// MARK: - Life cycle
extension LogInController{
    
    override func viewWillAppear(_ animated: Bool) {
        
        FBSDKLoginManager().logOut()
        
        do{
            try FIRAuth.auth()?.signOut()
        }catch let logOutError {
            print(logOutError)
        }
    }
    
    override func viewDidLoad() {
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        setUp([emailTextField, passWordTextField], with: ["電子郵件地址", "密碼"], of: [UIColor.white, UIColor.white])
        
        emailTextField.delegate = self
        passWordTextField.delegate = self
        
    }
}
