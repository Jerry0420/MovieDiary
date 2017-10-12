//
//  DataRequset.swift
//  SecondHandBooks
//
//  Created by JerryWang on 2016/11/3.
//  Copyright © 2016年 Jerrywang. All rights reserved.
//

import Foundation
import UIKit

class DataRequest{
    
    static let sharedInstance = DataRequest()
    
    private init() {}
    
    func fetchDataFromWeb(of url: URL, completion: @escaping (Data)->Void){
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url, completionHandler: {
            data, response, error -> Void in
            
            if let error = error{
                print(error.localizedDescription)
            }else if let httpResponse = response as? HTTPURLResponse{
                if httpResponse.statusCode == 200 {
                    
                    if let receivedData = data{
                        completion(receivedData)
                    }
                }
            }
        })
        task.resume()
    }    
}
