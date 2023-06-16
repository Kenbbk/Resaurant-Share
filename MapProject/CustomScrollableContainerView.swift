//
//  CustomScrollableContainer.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/06/16.
//

import UIKit

class CustomScrollableContainerView: UIView {
    
    private lazy var upperView: UIView = {
        let myView = UIView()
        myView.backgroundColor = .white
        return myView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemPink
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
