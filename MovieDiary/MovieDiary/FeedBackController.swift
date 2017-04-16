//
//  FeedBackController.swift
//  SecondHandBooks
//
//  Created by JerryWang on 2016/11/25.
//  Copyright © 2016年 Jerrywang. All rights reserved.
//

import UIKit
import Firebase

class FeedBackController: UIViewController {

    var email : String?
    
    var userName: String?
    
    @IBOutlet weak var inputFeedBackTextView: UITextView!
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    @IBOutlet weak var sendFeedBackButton: UIButton!
    
    @IBOutlet weak var backToUserDataControllerButton: UIButton!
    
    @IBAction func sendFeedBack(_ sender: UIButton) {
        
        activity.startAnimating()
        inputFeedBackTextView.resignFirstResponder()
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        guard let feedBackText = inputFeedBackTextView.text else {
            return
        }
        
        guard let email = email, let userName = userName else {
            return
        }

        let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
        let ref = FIRDatabase.database().reference().child("FeedBack").child(uid)
        
        let childRef = ref.childByAutoId()
        
        let properties = ["FeedBack": feedBackText as AnyObject, "Email":email as AnyObject, "UserName":userName as AnyObject, "timeStamp": timestamp as AnyObject] as [String: AnyObject]
    
        childRef.updateChildValues(properties, withCompletionBlock: {
            (error, ref) in
            
            if error != nil{
                print(error!)
                return
            }
            self.activity.stopAnimating()
            self.backToUserDataController()
        })
        
    }
    
    func backToUserDataController(){
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        inputFeedBackTextView.becomeFirstResponder()
        
        backToUserDataControllerButton.addTarget(self, action: #selector(backToUserDataController), for: .touchUpInside)
        
        self.sendFeedBackButton.layer.cornerRadius = 6
        self.sendFeedBackButton.layer.borderWidth = 0.6
        self.sendFeedBackButton.layer.borderColor = UIColor.lightGray.cgColor
        
        self.backToUserDataControllerButton.layer.cornerRadius = 6
        self.backToUserDataControllerButton.layer.borderWidth = 0.6
        self.backToUserDataControllerButton.layer.borderColor = UIColor.lightGray.cgColor
    }
}
