//
//  LoadImageWithCache.swift
//  SecondHandBooks
//
//  Created by JerryWang on 2016/11/8.
//  Copyright © 2016年 Jerrywang. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImage {
    
    static func downloadImage(url: URL, complectionHandler: @escaping (UIImage?) -> Swift.Void) {
        
        //check cache for image first 有下載過的 直接載入圖片 用kvo
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            
            complectionHandler(cachedImage)
            
            return
        }
        //沒下載過的 重新下載 kvo
        DataRequest.sharedInstance.fetchDataFromWeb(of: url) { (data) in
            
            if let downloadedImage = UIImage(data: data) {
                imageCache.setObject(downloadedImage, forKey: url.absoluteString as NSString)
                
                complectionHandler(downloadedImage)
            }
            
        }
    }
}
