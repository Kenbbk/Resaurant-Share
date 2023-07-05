//
//  UIViewController+Ext.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/06/21.
//

import UIKit

extension UIViewController {
    
    func dismissKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer( target:     self, action:    #selector(UIViewController.dismissKeyboardTouchOutside))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboardTouchOutside() {
        view.endEditing(true)
    }
    
    func getTopHierarchyViewController() -> UIViewController? {
        var vc = self
        
        while vc.parent != nil {
            vc = vc.parent!
        }
        
        return vc == self ? nil: vc
        
        
    }
}
