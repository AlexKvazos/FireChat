//
//  UIColor.swift
//  FireChat
//
//  Created by Alejandro Cavazos on 11/8/17.
//  Copyright © 2017 Alejandro Cavazos. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}
