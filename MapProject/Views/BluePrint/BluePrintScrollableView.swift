//
//  MPScrollableView.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/07/07.
//

import UIKit

class BluePrintScrollableView: PassThroughView {
    
    enum ScrollViewPosition: CGFloat {
        
        case bottom = 0.78
        case middle = 0.55
        case top = 0.08
        
    }
    
    var topConstraint: NSLayoutConstraint!
    
    var currentPosition: ScrollViewPosition = .bottom {
        didSet {
            UIView.animate(withDuration: 0.1) {
                self.topConstraint.constant = self.getHeight(position: self.currentPosition)
                self.layoutIfNeeded()
            }
            
        }
    }
    
   var currentHeight: CGFloat!
    
     lazy var scrollableView: UIView = {
        let view = UIView()
         view.backgroundColor = .white
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(viewTapped(_:))))
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        
        configureUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func viewTapped(_ gesture: UIPanGestureRecognizer) {
        let state = gesture.state
        let translation = gesture.translation(in: self)
        if state == .began {

        } else if state == .changed {
            
            currentHeight = getHeight(position: currentPosition) + translation.y
            checkIfInTheRnage()
            topConstraint.constant = currentHeight
        } else if state == .ended {
            changeTheHeightAtTheEnd()
            
        }
    }
    private func checkIfInTheRnage() {
        if currentHeight < getHeight(position: .top) {
            currentHeight = getHeight(position: .top)
        } else if currentHeight > getHeight(position: .bottom) {
            currentHeight = getHeight(position: .bottom)
        }
    }
    
    
    private func changeTheHeightAtTheEnd() {
        switch currentPosition {
        case .bottom:
            
            if currentHeight < getHeight(position: .middle) {
                currentPosition = .top
            } else if currentHeight < getHeight(position: .bottom) {
                currentPosition = .middle
            } else {
                currentPosition = .bottom
            }
//            UIView.animate(withDuration: 0.1) {
//                self.topConstraint.constant = self.getHeight(position: self.currentPosition)
//                self.layoutIfNeeded()
//            }
            
            
        case .middle:
            if currentHeight < getHeight(position: .middle) {
                currentPosition = .top
            } else if currentHeight > getHeight(position: .middle) {
                currentPosition = .bottom
            } else {
                currentPosition = .middle
            }
//            UIView.animate(withDuration: 0.1) {
//                self.topConstraint.constant = self.getHeight(position: self.currentPosition)
//                self.layoutIfNeeded()
//            }
            
            
        case .top:
            if currentHeight > getHeight(position: .middle) {
                currentPosition = .bottom
            } else if currentHeight > getHeight(position: .top) {
                currentPosition = .middle
            } else {
                currentPosition = .top
            }
//            UIView.animate(withDuration: 0.1) {
//                self.topConstraint.constant = self.getHeight(position: self.currentPosition)
//                self.layoutIfNeeded()
//            }
            
            
        }
    }
    
    func getHeight(position: ScrollViewPosition) -> CGFloat {
        
        return position.rawValue * UIScreen.main.bounds.height
    }
    
    private func configureUI() {
        
        addSubview(scrollableView)
        scrollableView.translatesAutoresizingMaskIntoConstraints = false
        topConstraint = scrollableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: getHeight(position: .bottom))
        NSLayoutConstraint.activate([
            topConstraint,
            scrollableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
