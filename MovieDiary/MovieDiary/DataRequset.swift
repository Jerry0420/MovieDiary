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

    func fetchMovieDataFromWeb(url: URL, completion: @escaping (Data)->Void){
        
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
    
    func fetchMovieData(url: URL, completion: @escaping (UIImage?,String?,String)->Void){
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url, completionHandler: {
            data, response, error -> Void in
            
            if let error = error{
                print(error.localizedDescription)
            }else if let httpResponse = response as? HTTPURLResponse{
                if httpResponse.statusCode == 200 {
                    
                    if let receivedData = data{
                        self.parseReceivedData(data: receivedData, completion: completion)
                    }
                }
            }
        })
        task.resume()
    }
    
    
    func parseReceivedData(data : Data, completion: (UIImage?,String?,String)->Void)
    {
        
        guard  let dataArray = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as AnyObject else{
            
            return
        }
        
        guard let imageURLString = dataArray[Key.PosterKey] as? String else {
            
            print("無imageURL回傳")
            return
        }
        
        if let receivedResponse = dataArray[Key.ResponseKey] as? String{
            
            if receivedResponse == "True"{
                
                guard let name = dataArray[Key.TiTleKey] as? String, let year = dataArray[Key.YearKey] as? String else{
                    
                    print("無name, year回傳")
                    return
                }
                
                
                if let imageURL = URL(string: imageURLString), let data = try? Data(contentsOf: imageURL), let image = UIImage(data: data)
                {
                    completion(image, year, name)
                    
                }else{
                    
                    print("搜尋的到,但無image,只有name, year")
                    
                    completion(nil, year, name)
                }
                
            }else{
                
                print("搜尋不到或輸入字數太少")
                
            }
        }
    }
}
