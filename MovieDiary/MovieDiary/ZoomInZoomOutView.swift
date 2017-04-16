//
//  ZoomInZoomOutView.swift
//  SecondHandBooks
//
//  Created by JerryWang on 2016/11/12.
//  Copyright © 2016年 Jerrywang. All rights reserved.
//

import Foundation

class ZoomInZoomOutView{
    
    var startingFrame: CGRect?
    
    var startingImageView: UIImageView?
    
    var zoomingImageView : UIImageView?
    
    var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
//    let feelingTextLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 16)
//        label.textColor = UIColor.lightGray
//        label.lineBreakMode = .byTruncatingTail
//        label.numberOfLines = 10
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
    
    let feelingTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.textColor = UIColor.lightGray
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.backgroundColor = UIColor.clear
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
   
    let movieNameTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 21)
        label.textColor = UIColor.lightGray
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 3
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func performZoomInForStartingImageView(startingImageView: UIImageView,movie: Movie){
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        feelingTextView.text = movie.feelingText
        movieNameTextLabel.text = movie.movieName
        
        zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView?.backgroundColor = UIColor.clear
        zoomingImageView?.image = startingImageView.image
        zoomingImageView?.isUserInteractionEnabled = true
        zoomingImageView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        visualEffectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlevisualEffectViewZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            
            visualEffectView.frame = keyWindow.frame
            visualEffectView.alpha = 0
            
            keyWindow.addSubview(visualEffectView)
            
            keyWindow.addSubview(zoomingImageView!)
            
            self.visualEffectView.addSubview(self.feelingTextView)
            self.visualEffectView.addSubview(self.movieNameTextLabel)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.visualEffectView.alpha = 1
                
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                self.zoomingImageView?.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width/1, height: height/1.1)
                
                self.zoomingImageView?.center = keyWindow.center
                
                self.feelingTextView.leftAnchor.constraint(equalTo: (self.zoomingImageView?.leftAnchor)!, constant: 20).isActive = true

                self.feelingTextView.rightAnchor.constraint(equalTo: (self.zoomingImageView?.rightAnchor)!, constant: -20).isActive = true
                self.feelingTextView.centerXAnchor.constraint(equalTo: (self.zoomingImageView?.centerXAnchor)!).isActive = true
                self.feelingTextView.topAnchor.constraint(equalTo: (self.zoomingImageView?.bottomAnchor)!, constant: 20).isActive = true
                self.feelingTextView.bottomAnchor.constraint(equalTo: self.visualEffectView.bottomAnchor, constant: -20).isActive = true
                
                
                self.movieNameTextLabel.leftAnchor.constraint(equalTo: (self.zoomingImageView?.leftAnchor)!, constant: 20).isActive = true
                self.movieNameTextLabel.rightAnchor.constraint(equalTo: (self.zoomingImageView?.rightAnchor)!, constant: -20).isActive = true
                self.movieNameTextLabel.centerXAnchor.constraint(equalTo: (self.zoomingImageView?.centerXAnchor)!).isActive = true
                self.movieNameTextLabel.bottomAnchor.constraint(equalTo: (self.zoomingImageView?.topAnchor)!, constant: -20).isActive = true
                
            }, completion: { (completed) in
                
            })
        }
    }
    
    @objc func handleZoomOut(tapGesture: UITapGestureRecognizer){
        
        if let zoomOutImageView = tapGesture.view {
            
            //zoomOutImageView.layer.cornerRadius = 8
            //zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                zoomOutImageView.frame = self.startingFrame!
                self.visualEffectView.alpha = 0
                self.movieNameTextLabel.removeFromSuperview()
                self.feelingTextView.removeFromSuperview()
                
            }, completion: { (completed) in
                
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
        }
    }
    
    @objc func handlevisualEffectViewZoomOut(tapGesture: UITapGestureRecognizer){
        
        //zoomingImageView?.layer.cornerRadius = 8
        //zoomingImageView?.clipsToBounds = true
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.zoomingImageView?.frame = self.startingFrame!
            self.visualEffectView.alpha = 0
            self.movieNameTextLabel.removeFromSuperview()
            self.feelingTextView.removeFromSuperview()
            
        }, completion: { (completed) in
    
            self.zoomingImageView?.removeFromSuperview()
            self.visualEffectView.removeFromSuperview()
            self.startingImageView?.isHidden = false
        })
    }
}
