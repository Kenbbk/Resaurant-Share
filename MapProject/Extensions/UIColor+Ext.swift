//
//  UIColor+Ext.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/06/20.
//

import UIKit

extension UIColor {

    convenience init(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) {
        self.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
    }
}
