//
//  MovieImageView.swift
//  MovieDiary
//
//  Created by JerryWang on 2017/7/16.
//  Copyright © 2017年 Jerrywang. All rights reserved.
//

import UIKit

class MovieImageView: UIImageView {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.cornerRadius = 8
        clipsToBounds = true
    }
}
