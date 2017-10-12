//
//  RegisterController.swift
//  SecondHandBooks
//
//  Created by JerryWang on 2016/11/2.
//  Copyright © 2016年 Jerrywang. All rights reserved.
//

import UIKit
import Firebase

// MARK: - Property, function
class RegisterController: UIViewController {
    
    var uploadedProfileImage : UIImage?
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passWordTextField: UITextField!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    @IBOutlet weak var registerButton: RegisterButton!
    
    @IBOutlet weak var goToLogInButton: RegisterButton!
    
    @IBOutlet weak var picLabel: UILabel!
    
    fileprivate func handleEmailRegister(){
        
        guard let email = emailTextField.text, let password = passWordTextField.text, let name = nameTextField.text else {
            print("Form is not valid")
            return
        }
        
        if name.characters.count == 0{
            
            setUp([nameTextField], with: ["請輸入用戶名稱"], of: [UIColor.getAlertColor()])
            
            return
        }else{
            if email.isValidEmail() == false{

                setUp([emailTextField], with: ["電子信箱格式錯誤"], of: [UIColor.getAlertColor()])
                
                return
            }else if password.characters.count < 6{
                setUp([passWordTextField], with: ["密碼請大於6碼"], of: [UIColor.getAlertColor()])
                
                return
            }
        }
        
        
        
        handleStatusOfNetworkActivity(when: true, of: activity)
        
        registerToFirebase(withEmail: email, password: password, name: name)
        
    }
    
    func registerToFirebase(withEmail email: String, password: String, name: String){
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
            
            if error != nil{
                
                guard let errorString = error?.localizedDescription else{
                    return
                }
                
                if errorString == "The email address is already in use by another account."{
                    //已有email了 前往登入
                    self.accountAlreadyExistAlert()
                    
                }else{
                    //其他錯誤
                    self.errorAlert()
                }
                
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            self.uploadProfileImage(of: self.uploadedProfileImage, withEmail: email, password: password, name: name, uid: uid)
            
        })
    }
    
    func uploadProfileImage(of image: UIImage?,withEmail email: String, password: String, name: String, uid: String){
        
        let imageName = NSUUID().uuidString
        let storegeRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).jpg")
        
        if let profileImage = image,let uploadData = UIImageJPEGRepresentation(profileImage, 1){
            
            storegeRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil{
                    print(error!)
                    return
                }
                
                if let profileImageUrl = metadata?.downloadURL()?.absoluteString{
                    
                    let userData = ["name": name as AnyObject, "email": email as AnyObject, "profileImageUrl": profileImageUrl as AnyObject] as [String: AnyObject]
                    
                    self.saveUserDataToFirebaseDatabase(with: uid, and: userData)
                }
            })
        }
    }
    
    func saveUserDataToFirebaseDatabase(with uid: String,and userData: [String: AnyObject]){
        FirebaseWorks.sharedInstance.registerUserIntoDatabaseWithUID(uid: uid, values: userData, completion: { (result) in
            
            if result == "Pass"{
                
                self.handleStatusOfNetworkActivity(when: false, of: self.activity)
                
                let user = FIRAuth.auth()?.currentUser
                
                self.sendEmailVerification(of: user)
                
            }
            
        })
    }
    
    func sendEmailVerification(of user: FIRUser?){
        user?.sendEmailVerification() { error in
            if let error = error {
                print(error)
            } else {
                self.successLogInAlert()
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func hideKeyboard() {
        nameTextField.resignFirstResponder()
        passWordTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
    }
    
    func handleSelectProfileImageView(){
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
}

// MARK: - Alert!
extension RegisterController{
    fileprivate func errorAlert(){
        showOKAlert(title: "", message: "註冊失敗，請再試一次", actionATitle: "是") {
            self.setUp([self.emailTextField, self.passWordTextField, self.nameTextField], with: ["電子郵件地址", "密碼","用戶名稱"], of: [UIColor.white,UIColor.white,UIColor.lightGray])
            
            self.handleStatusOfNetworkActivity(when: false, of: self.activity)
        }
    }
    
    fileprivate func accountAlreadyExistAlert(){
        showOKAlert(title: "", message: "帳號已存在，請前往登入", actionATitle: "是") {
            self.setUp([self.emailTextField, self.passWordTextField, self.nameTextField], with: ["電子郵件地址", "密碼","用戶名稱"], of: [UIColor.white,UIColor.white,UIColor.lightGray])
            
            self.dismiss(animated: true, completion: nil)
            
            self.handleStatusOfNetworkActivity(when: false, of: self.activity)
        }
    }
    
    fileprivate func successLogInAlert(){
        
        showOKAlert(title: "", message: "已發送確認郵件至您的電子信箱，請前往驗證。", actionATitle: "是") {
            self.setUp([self.emailTextField, self.passWordTextField, self.nameTextField], with: ["電子郵件地址", "密碼","用戶名稱"], of: [UIColor.white,UIColor.white,UIColor.lightGray])
            
            self.dismiss(animated: true, completion: nil)
            
            self.handleStatusOfNetworkActivity(when: false, of: self.activity)
        }
    }
}

// MARK: - 畫面跳轉
extension RegisterController{
    @IBAction func goToLogInPage(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
        
    }
}

// MARK: - IBAction
extension RegisterController{
    @IBAction func emailRegister(_ sender: UIButton) {
        
        handleEmailRegister()
    }
    
    @IBAction func selectProfileImage(_ sender: UIButton) {
        
        handleSelectProfileImageView()
    }
}

// MARK: - Delegate implement
extension RegisterController: SetUpTextFieldDelegate{}

extension RegisterController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
        return true
    }
}

extension RegisterController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            
            selectedImageFromPicker = editedImage
            
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage
        {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            picLabel.isHidden = true
            profileImageView.image = selectedImage
            uploadedProfileImage = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        uploadedProfileImage = #imageLiteral(resourceName: "default")
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - life cycle

extension RegisterController{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        
        profileImageView.layer.cornerRadius = 16
        profileImageView.clipsToBounds = true
        
        setUp([emailTextField, passWordTextField, nameTextField], with: ["電子郵件地址", "密碼","用戶名稱"], of: [UIColor.white,UIColor.white,UIColor.white])
        
        nameTextField.delegate = self
        emailTextField.delegate = self
        passWordTextField.delegate = self
        
        uploadedProfileImage = #imageLiteral(resourceName: "default")
    }
}
