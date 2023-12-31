//
//  UIView+Ext.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/06/21.
//

import UIKit

extension UIView {
    func dismissKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer( target:     self, action:    #selector(UIView.dismissKeyboardTouchOutside))
        tap.cancelsTouchesInView = false
        addGestureRecognizer(tap)
    }
    
    
    
    @objc private func dismissKeyboardTouchOutside() {
        endEditing(true)
    }
    
    
        func findViewController() -> UIViewController? {
            if let nextResponder = self.next as? UIViewController {
                return nextResponder
            } else if let nextResponder = self.next as? UIView {
                return nextResponder.findViewController()
            } else {
                return nil
            }
        }
    
}
