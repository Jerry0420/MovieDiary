 //
//  LoadImageWithCache.swift
//  SecondHandBooks
//
//  Created by JerryWang on 2016/11/8.
//  Copyright © 2016年 Jerrywang. All rights reserved.
//

import UIKit

class imageCacheFileName{
    
}


let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    func loadImageUsingCacheWithUrlString(urlString: String){
        
        //self.image = nil
        
        //check cache for image first 有下載過的 直接載入圖片 用kvo
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            self.image = cachedImage
            return
        }
        
        //otherwise fire off a new download
        //若用URLSession, dataTask with url, 每次滑動到cell時就會下載圖片，產生很大的用量
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            if error != nil{
                print(error!)
                return
            }
            
            DispatchQueue.main.async(execute: {
                //沒下載過的 重新下載 kvo
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                    
                    self.image = downloadedImage
                }
                //                self.image = UIImage(data: data!)
                
            })
        }).resume()
        
    }
}
