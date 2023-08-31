//
//  UIViewController+
//
//  Created by Woojun Lee on 2023/06/21.
//

import UIKit
import SnapKit

extension UIViewController {
    
    
    func add(_ child: UIViewController, to containerView: UIView) {
        addChild(child)
        containerView.addSubview(child.view)
        child.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        child.didMove(toParent: self)
    }
    
    func remove() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
    
    
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
