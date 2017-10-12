//
//  FirebaseWorks.swift
//  SecondHandBooks
//
//  Created by JerryWang on 2016/11/8.
//  Copyright © 2016年 Jerrywang. All rights reserved.
//

import Foundation
import Firebase

class FirebaseWorks{
    
    var searchedResultsCount = 0
    var childNameCount = 0
    var searchedNamesCount = 0
    
    static let sharedInstance = FirebaseWorks()
    
    private init() {}
    
    func checkIfUserIsLoggedIn(completion: @escaping (_ imageUrl: String) -> ()){
        
        if FIRAuth.auth()?.currentUser?.uid == nil{
            
            completion("Fail")
        }else{
            completion("Pass")
        }
    }
    
    //傳入uiimage, childName.回傳imageURL
    func uploadToFirebaseStorageUsingImage(image: UIImage?,childName: String, completion: @escaping (_ imageUrl: String) -> ()) {
        
        let imageName = NSUUID().uuidString
        let ref = FIRStorage.storage().reference().child(childName).child(imageName)
        
        if let image = image{
            if let uploadData = UIImageJPEGRepresentation(image, 0.3) {
                ref.put(uploadData, metadata: nil, completion: { (metadata, error) in
                    
                    if error != nil {
                        print("Failed to upload image:", error!)
                        completion("")
                        return
                    }
                    
                    if let imageUrl = metadata?.downloadURL()?.absoluteString {
                        
                        completion(imageUrl)
                        
                    }else{
                        completion("")
                    }
                })
                
            }
        }else{
            completion("")
        }
    }
    
    //傳入properties,childName, 傳回result(pass or fail)和movieID
    func uploadToFirebaseDataBaseUsingProperties(childName: String,inputProperties: [String: AnyObject], completion: @escaping (_ result: String, _ movieID: String) -> ()) {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child(childName).child(uid)
        
        let childRef = ref.childByAutoId() //隨機建立的id
        
        var properties = ["movieID":childRef.key as AnyObject] as [String: AnyObject]
        
        inputProperties.forEach({properties[$0] = $1})
        
        childRef.updateChildValues(properties, withCompletionBlock: {
            (error, ref) in
            
            if error != nil{
                print(error!)
                completion("Fail", childRef.key)
                return
            }
            completion("Pass", childRef.key)
        })
    }
    
    //抓資料下來, 傳回資料moviesDictionary or let movie, snapshot.key
    func fetchDataFromFirebaseDataBase(childName: String, completion: @escaping (_ movie: Movie, _ movieID: String) -> ()){
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let movieIDsReference = FIRDatabase.database().reference().child(childName).child(uid)
        movieIDsReference.observe(.childAdded, with: {
            (snapshot) in
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                
                let movie = Movie(dictionary: dictionary)
                
                completion(movie, snapshot.key)
                
            }
            
        }, withCancel: nil)
    }
    
    func filterDataFromFirebaseDatabase(under dataOrName: String,in childNames : [String], with nameArray: [[String]], of counts: Int, completion: @escaping (_ movies: [Movie]?) -> ()){
        
        var searchedMovieData = [Movie]()
        
        for index in 0..<nameArray.count{
            
            for name in nameArray[index]{
                
                self.searchedNamesCount += 1
                
                if searchedNamesCount <= counts{
                    
                    FIRDatabase.database().reference().child(dataOrName).child(childNames[index]).child(name).observe(.value, with: { (snapshot) in
                        
                        self.searchedResultsCount += 1
                        
                        if let dictionary = snapshot.value as? [String: AnyObject]{
                            
                            let movie = Movie(dictionary: dictionary)
                            searchedMovieData.append(movie)
                        }
                        
                        if self.searchedResultsCount == counts{
                            //歸為0，因為為singleton，故會一直累加，記得設為0
                            self.searchedResultsCount = 0
                            self.searchedNamesCount = 0
                            completion(searchedMovieData)
                        }
                        
                    })
                }
                
                
            }
        }
    }
    
    func fetchAllMovieNames(under dataOrName: String,with childNames: [String], completion: @escaping (_ movieNames: [[String]]) -> ()){
        
        var totalMovieNames = [[String]]()
        for childName in childNames{
            FIRDatabase.database().reference().child(dataOrName).child(childName).observe(.value, with: { (snapshot) in
                
                self.childNameCount += 1
                
                if let partialMovieNames = snapshot.value as? [String]{
                    
                    totalMovieNames.append(partialMovieNames)
                }
                if self.childNameCount == childNames.count{
                    self.childNameCount = 0
                    completion(totalMovieNames)
                }
            })
        }
    }
    
    //傳入movieID, childname 回傳result pass or fail
    func removeDataFromFirebaseDataBase(movieID: String,childName: String, completion: @escaping (_ result: String) -> ()){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        FIRDatabase.database().reference().child(childName).child(uid).child(movieID).removeValue(completionBlock: { (error, ref) in
            
            if error != nil{
                print(error!)
                completion("Fail")
                return
            }
            
            completion("Pass")
        })
    }
    
    func registerUserIntoDatabaseWithUID(uid: String, values:[String: AnyObject], completion: @escaping (_ result: String) -> ()){
        
        let ref = FIRDatabase.database().reference()
        
        let usersReference = ref.child("users").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil{
                print(err!)
                completion("Fail")
                return
            }
            
            completion("Pass")
            
        })
    }
    
    func fetchUserAndSetupNavBarTitle(completion: @escaping (_ userDictionary: [String: AnyObject]) -> ()){
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        FIRDatabase.database().reference().child("users").child(uid).observe(.value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                completion(dictionary)
                //                self.navigationItem.title = dictionary["name"] as? String
                //
                //                self.emailLabel.text = dictionary["email"] as? String
                //                self.userNameLabel.text = dictionary["name"] as? String
                //                self.profileImage.loadImageUsingCacheWithUrlString(urlString: dictionary["profileImageUrl"] as! String)
            }
        }, withCancel: nil)
    }
}
