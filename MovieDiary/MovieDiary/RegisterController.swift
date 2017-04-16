//
//  RegisterController.swift
//  SecondHandBooks
//
//  Created by JerryWang on 2016/11/2.
//  Copyright © 2016年 Jerrywang. All rights reserved.
//

import UIKit
import Firebase

class RegisterController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITextFieldDelegate {
    
    let firebaseWorksInstance = FirebaseWorks()
    
    var uploadedProfileImage : UIImage?
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passWordTextField: UITextField!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    @IBOutlet weak var registerButton: UIButton!
    
    @IBOutlet weak var goToLogInButton: UIButton!
    
    @IBOutlet weak var picLabel: UILabel!
    
    @IBAction func emailRegister(_ sender: UIButton) {
        
        handleEmailRegister()
    }
    
    private func handleEmailRegister(){
        
        guard let email = emailTextField.text, let password = passWordTextField.text, let name = nameTextField.text else {
            print("Form is not valid")
            return
        }
        
        if name.characters.count == 0{
            nameTextField.text = ""
            nameTextField.attributedPlaceholder = NSAttributedString(string: "請輸入用戶名稱", attributes: [NSForegroundColorAttributeName:UIColor.getAlertColor()])
            return
        }else{
            if email.isValidEmail() == false{
                emailTextField.text = ""
                emailTextField.attributedPlaceholder = NSAttributedString(string: "電子信箱格式錯誤", attributes: [NSForegroundColorAttributeName:UIColor.getAlertColor()])
                return
            }else if password.characters.count < 6{
                passWordTextField.text = ""
                passWordTextField.attributedPlaceholder = NSAttributedString(string: "密碼請大於6碼", attributes: [NSForegroundColorAttributeName:UIColor.getAlertColor()])
                return
            }
        }
        
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.activity.startAnimating()
        
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
            
            let imageName = NSUUID().uuidString
            let storegeRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).jpg")
            
            if let profileImage = self.uploadedProfileImage,let uploadData = UIImageJPEGRepresentation(profileImage, 1){
                
                storegeRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                    
                    if error != nil{
                        print(error!)
                        return
                    }
                    
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString{
                        
                        let values = ["name": name as AnyObject, "email": email as AnyObject, "profileImageUrl": profileImageUrl as AnyObject] as [String: AnyObject]
                        
                        self.firebaseWorksInstance.registerUserIntoDatabaseWithUID(uid: uid, values: values, completion: { (result) in
                            
                            if result == "Pass"{
                            
                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                self.activity.stopAnimating()
                                
                                let user = FIRAuth.auth()?.currentUser
                                
                                user?.sendEmailVerification() { error in
                                    if let error = error {
                                        print(error)
                                    } else {
                                        self.successLogInAlert()
                                    }
                                }
                            }
                            
                        })
                    }
                })
            }
        })
        
    }
    
    @IBAction func goToLogInPage(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func selectProfileImage(_ sender: UIButton) {
        
        handleSelectProfileImageView()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        
        profileImageView.layer.cornerRadius = 16
        profileImageView.clipsToBounds = true
        
        self.registerButton.layer.cornerRadius = 6
        self.registerButton.layer.borderWidth = 0.6
        self.registerButton.layer.borderColor = UIColor.lightGray.cgColor
        
        self.goToLogInButton.layer.cornerRadius = 6
        self.goToLogInButton.layer.borderWidth = 0.6
        self.goToLogInButton.layer.borderColor = UIColor.lightGray.cgColor
        
        emailTextField.attributedPlaceholder = NSAttributedString(string: "電子郵件地址", attributes: [NSForegroundColorAttributeName:UIColor.white])
        
        passWordTextField.attributedPlaceholder = NSAttributedString(string: "密碼", attributes: [NSForegroundColorAttributeName:UIColor.white])
        
        nameTextField.attributedPlaceholder = NSAttributedString(string: "用戶名稱", attributes: [NSForegroundColorAttributeName:UIColor.white])
        
        //showGradientColor()
        
        nameTextField.delegate = self
        emailTextField.delegate = self
        passWordTextField.delegate = self
        
        uploadedProfileImage = UIImage(named: "default")
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func handleSelectProfileImageView(){
        
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
            picLabel.isHidden = true
            profileImageView.image = selectedImage
            uploadedProfileImage = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        uploadedProfileImage = UIImage(named: "default")
        dismiss(animated: true, completion: nil)
    }
    
    func hideKeyboard() {
        nameTextField.resignFirstResponder()
        passWordTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
        return true
    }
    
    private func errorAlert(){
        
        let alertController = UIAlertController(title: "", message: "註冊失敗，請重新輸入", preferredStyle: .alert)
        let actionY = UIAlertAction(title: "是", style: .default, handler: {
            action in
            
            self.emailTextField.text = nil
            self.passWordTextField.text = nil
            self.passWordTextField.text = nil
            self.emailTextField.attributedPlaceholder = NSAttributedString(string: "電子郵件地址", attributes: [NSForegroundColorAttributeName:UIColor.lightGray])
            
            self.passWordTextField.attributedPlaceholder = NSAttributedString(string: "密碼", attributes: [NSForegroundColorAttributeName:UIColor.lightGray])
            
            self.nameTextField.attributedPlaceholder = NSAttributedString(string: "用戶名稱", attributes: [NSForegroundColorAttributeName:UIColor.lightGray])
        })
        
        alertController.addAction(actionY)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.activity.stopAnimating()
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    private func accountAlreadyExistAlert(){
        
        let alertController = UIAlertController(title: "", message: "帳號已存在，請前往登入", preferredStyle: .alert)
        let actionY = UIAlertAction(title: "是", style: .default, handler: {
            action in
            
            self.emailTextField.text = nil
            self.passWordTextField.text = nil
            self.passWordTextField.text = nil
            self.emailTextField.attributedPlaceholder = NSAttributedString(string: "電子郵件地址", attributes: [NSForegroundColorAttributeName:UIColor.lightGray])
            
            self.passWordTextField.attributedPlaceholder = NSAttributedString(string: "密碼", attributes: [NSForegroundColorAttributeName:UIColor.lightGray])
            
            self.nameTextField.attributedPlaceholder = NSAttributedString(string: "用戶名稱", attributes: [NSForegroundColorAttributeName:UIColor.lightGray])
            
            self.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(actionY)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.activity.stopAnimating()
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    private func successLogInAlert(){
        
        let alertController = UIAlertController(title: "", message: "已發送確認郵件至您的電子信箱，請前往驗證。", preferredStyle: .alert)
        let actionY = UIAlertAction(title: "是", style: .default, handler: {
            action in
            
            self.emailTextField.text = nil
            self.passWordTextField.text = nil
            self.passWordTextField.text = nil
            self.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(actionY)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.activity.stopAnimating()
        self.present(alertController, animated: true, completion: nil)
        
    }

}
