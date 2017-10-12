//
//  Extension.swift
//  SecondHandBooks
//
//  Created by JerryWang on 2016/11/2.
//  Copyright © 2016年 Jerrywang. All rights reserved.
//

import Foundation
import UIKit


struct StoryBoardIdentifier {
    static let registerLogInSBIdentifier = "RegisterLogIn"
}

struct ViewControllerIdentifier {
    
    static let logInControllerIdentifier = "LogInController"
    static let mainControllerIdentifier = "Main"
    static let registerControllerIdentifier = "RegisterController"
    
    static let addNewMovieControllerIdentifier = "AddNewMovieController"
    static let addTicketControllerIdentifier = "AddTicketController"
    static let MovieControllerIdentifier = "initialViewController"
    static let wantWatchedMovieControllerIdentifier = "WantWatchedMovieController"
    static let editMoviesControllerIdentifier = "editMoviesController"
    
    static let addNewWantWatchedMovieControllerIdentifier = "AddNewWantWatchedMovieController"
    
    static let feedBackControllerIdentifier = "FeedBackController"
}

struct Key{
    
    static let URLKeyT = "http://www.omdbapi.com/?t="
    static let URLkeyY = "&y="
    static let URLKeyElse = "&plot=full&r=json"
    static let TiTleKey = "Title"
    static let YearKey = "Year"
    static let PosterKey = "Poster"
    static let ResponseKey = "Response"
    
    //http://www.omdbapi.com/?t=&y=&plot=full&r=json
    //http://www.omdbapi.com/?t=frozen&y=2013&plot=full&r=json
}

struct HTMLKey{
    static let baseURL = "https://tw.movies.yahoo.com/moviesearch_result.html?k="
    
}

struct SegueIdentifier {
    static let goToAddTicketControllerIdentifier = "goToAddTicketController" //刪！
    static let goToEditMovieControllerFromWatchedIdentifier = "goToEditMovieControllerFromWatched"
    static let goToEditMovieControllerFromWantWatchedIdentifier = "goToEditMovieControllerFromWantWatched"
}

struct CellIdentifier{
    static let watchedMoviesCellIdentifier = "watchedMoviesCell"
    static let wantWatchedMoviesCellIdentifier = "wantWatchedMoviesCell"
    static let ticketsItemIdentifier = "ticketsItem"
    static let searchedMovieCellIdentifier = "searchedMovieCell"
}

struct ChildName {
    static let movieImageCHildName = "movie_Image"
    static let watchedMoviesChildName = "Watched Movies"
    static let ticketImageChildName = "ticket_Image"
    static let wantWatchedMoviesChildName = "Want Watched Movies"
    //倒過來放，讓上映日期新的在比較前面
    static let childNamesOfMovieName : [String] = ["MovieName8", "MovieName6", "MovieName4", "MovieName2"]
    static let childNamesOfMovieData : [String] = ["MovieData8", "MovieData6", "MovieData4", "MovieData2"]
    static let childNames : [String] = ["MovieName", "MovieData"]
}

extension String{
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }

}

extension UIColor{
    
    static func getAlertColor() -> UIColor{
        let alertColor = UIColor(red: 216.0/255.0, green: 36.0/255.0, blue: 36.0/255.0, alpha: 1.0)
        return alertColor
    }
}

//需要用到以下方法的，再implement delegate
protocol SetUpTextFieldDelegate {
    func setUp(_ textFields: [UITextField],with placeholders: [String],of colors: [UIColor])
}

extension SetUpTextFieldDelegate where Self: UIViewController{
    func setUp(_ textFields: [UITextField],with placeholders: [String],of colors: [UIColor]){
        
        for index in 0...(textFields.count - 1){
            textFields[index].attributedPlaceholder = NSAttributedString(string: placeholders[index], attributes: [NSForegroundColorAttributeName:colors[index]])
            textFields[index].text = nil
        }
    }
}

//每個view controller都會用到的，放在extension
extension UIViewController{
    func createTableViewAction(of title: String,and color: UIColor, with completion: (()->())?) -> UITableViewRowAction{
        
        let action = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: title, handler: {
            (action:UITableViewRowAction! , indexPath:IndexPath!) -> Void in
            
            if let completion = completion{
                completion()
            }
        })
        
        action.backgroundColor = color
        
        return action
    }
}

extension UIViewController{
    func handleStatusOfNetworkActivity(when status: Bool, of indicator: UIActivityIndicatorView){
        if status{
            UIApplication.shared.isNetworkActivityIndicatorVisible = status
            indicator.startAnimating()
        }else{
            UIApplication.shared.isNetworkActivityIndicatorVisible = status
            indicator.stopAnimating()
        }
    }
}

extension UIViewController{
        
    func presentAnotherViewControllerUnderNavigationController(in storyBoard: String, of identifier: String, with completion: ((_ vc: UIViewController)->())?){
        
        let presentedViewController = UIStoryboard(name: storyBoard, bundle: nil).instantiateViewController(withIdentifier: identifier)
        
        if let completion = completion{
            completion(presentedViewController)
        }
        
        navigationController?.pushViewController(presentedViewController, animated: true)
    }
    
    func presentAnotherViewController(in storyBoard: String, of identifier: String, with completion: ((_ vc: UIViewController)->())?){
        
        let presentedViewController = UIStoryboard(name: storyBoard, bundle: nil).instantiateViewController(withIdentifier: identifier)
        
        if let completion = completion{
            completion(presentedViewController)
        }
        
        present(presentedViewController, animated: true, completion: nil)
    }
}

extension UIViewController{
    
    func showAlert(title: String, message: String, style: UIAlertControllerStyle, actionATitle: String, actionAStyle: UIAlertActionStyle,actionAHandler: (()->())?, actionBTitle: String?, actionBStyle: UIAlertActionStyle?,actionBHandler: (()->())?, actionCTitle: String?, actionCStyle: UIAlertActionStyle?,actionCHandler: (()->())?, completionHandler: (()->())?){
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        
        let actionA = UIAlertAction(title: actionATitle, style: actionAStyle, handler: {
            action in
            
            if let actionAHandler = actionAHandler{
                actionAHandler()
            }
        })
        alertController.addAction(actionA)
        
        if let actionBTitle = actionBTitle,let actionBStyle = actionBStyle{
            
            let actionB = UIAlertAction(title: actionBTitle, style: actionBStyle, handler: {
                action in
                
                if let actionBHandler = actionBHandler{
                    actionBHandler()
                }
            })
            alertController.addAction(actionB)
        }
        
        if let actionCTitle = actionCTitle,let actionCStyle = actionCStyle{
            
            let actionC = UIAlertAction(title: actionCTitle, style: actionCStyle, handler: {
                action in
                
                if let actionCHandler = actionCHandler{
                    actionCHandler()
                }
                
            })
            alertController.addAction(actionC)
        }
        
        if let completionHandler = completionHandler{completionHandler()}
        
        present(alertController, animated: true, completion: nil)
    }
    
    func showOKAlert(title: String, message: String, actionATitle: String,actionAHandler: (()->())?){
        
        showAlert(title: title, message: message, style: .alert, actionATitle: actionATitle, actionAStyle: .default, actionAHandler: actionAHandler, actionBTitle: nil, actionBStyle: nil, actionBHandler: nil, actionCTitle: nil, actionCStyle: nil, actionCHandler: nil, completionHandler: nil)
    }
    
    func showAlertWithTextField(title: String, message: String, actionATitle: String,actionAHandler: ((_ email: String)->())?, actionBTitle: String, placeHolder: String){
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        var inputText = ""
        var alertTextField = UITextField()
        
        let actionA = UIAlertAction(title: actionATitle, style: .default, handler: {
            action in
            
            inputText = alertTextField.text!
            
            if let actionAHandler = actionAHandler{
                actionAHandler(inputText)
            }
        })
        
        let actionB = UIAlertAction(title: actionBTitle, style: .default, handler: nil)
        
        alertController.addTextField()
        alertController.addAction(actionA)
        alertController.addAction(actionB)
        
        present(alertController, animated: true, completion: nil)
        
        if let textField = alertController.textFields?.first{
            
            alertTextField = textField
            alertTextField.attributedPlaceholder = NSAttributedString(string: placeHolder, attributes: [NSForegroundColorAttributeName:UIColor.gray])
            
        }
    }
}
