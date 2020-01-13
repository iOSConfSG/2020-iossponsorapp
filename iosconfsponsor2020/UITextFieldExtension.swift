//
//  UITextFieldExtension.swift
//  iosconfsponsor2020
//
//  Created by Hotha Santhanakrishnan Swarup on 12/1/20.
//  Copyright © 2020 Hotha Santhanakrishnan Swarup. All rights reserved.
//

import UIKit

extension UIView {
    func setAppTheme() {
        layer.cornerRadius = 5.0
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.init(red: 206/255, green: 213/255, blue: 220/255, alpha: 1).cgColor
        tintColor = UIColor.purple
    }
}
