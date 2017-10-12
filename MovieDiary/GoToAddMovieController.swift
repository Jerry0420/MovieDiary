//
//  GoToAddMandTController.swift
//  SecondHandBooks
//
//  Created by JerryWang on 2016/11/4.
//  Copyright © 2016年 Jerrywang. All rights reserved.
//

import UIKit

class GoToAddMovieController: UIViewController {

    var tabBarSelectedIndex = 3
}


// MARK: - life cycle
extension GoToAddMovieController{
    override func viewWillAppear(_ animated: Bool) {
        if tabBarSelectedIndex == 0{
            self.tabBarController?.selectedIndex = 0
            tabBarSelectedIndex = 3
        }else if tabBarSelectedIndex == 2{
            self.tabBarController?.selectedIndex = 2
            tabBarSelectedIndex = 3
        }else{
            perform(#selector(goToAddNewWantWatchedMovieController), with: nil, afterDelay: 0)
        }
    }
}

// MARK: - 畫面轉換
extension GoToAddMovieController{
    func goToAddNewWantWatchedMovieController(){
        
        presentAnotherViewController(in: ViewControllerIdentifier.mainControllerIdentifier, of: ViewControllerIdentifier.addNewWantWatchedMovieControllerIdentifier, with: nil)
    }
}
