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
    
    func goToAddNewWantWatchedMovieController(){
        let addNewWantWatchedMovieController = UIStoryboard(name: ViewControllerIdentifier.mainControllerIdentifier, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifier.addNewWantWatchedMovieControllerIdentifier)
        self.present(addNewWantWatchedMovieController, animated: true, completion: nil)
    }
}
