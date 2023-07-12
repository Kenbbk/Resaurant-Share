//
//  PassThroughView.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/07/07.
//

import UIKit

import UIKit

class PassThroughView: UIView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        // superview가 터치 이벤트를 받을 수 있도록,
        // 해당 뷰 (subview)가 터치되면 nil을 반환하고 다른 뷰일경우 UIView를 반환
        return hitView == self ? nil : hitView
      }
    
}
