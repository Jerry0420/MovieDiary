//
//  RegisterButton.swift
//  MovieDiary
//
//  Created by JerryWang on 2017/7/13.
//  Copyright © 2017年 Jerrywang. All rights reserved.
//

import UIKit

class RegisterButton: UIButton {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.cornerRadius = 6
        layer.borderWidth = 0.6
        layer.borderColor = UIColor.lightGray.cgColor
    }
}
