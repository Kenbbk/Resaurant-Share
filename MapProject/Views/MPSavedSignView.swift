//
//  CustomCategoryView.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/06/24.
//

import UIKit

class MPSavedSignView: UIView {
    
    lazy var leftImageView: UIImageView = {
       let iv = UIImageView()
        iv.image = UIImage(systemName: "star.circle")
        iv.clipsToBounds = true
        return iv
    }()
    
    let label: UILabel = {
       let label = UILabel()
        label.text = "HELLO There"
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderWidth = 0.4
        layer.borderColor = UIColor.systemGray3.cgColor
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        configureleftImageView()
        configureLabel()
    }
    
    private func configureleftImageView() {
        
        addSubview(leftImageView)
        leftImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leftImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            leftImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            leftImageView.widthAnchor.constraint(equalToConstant: 10),
            leftImageView.heightAnchor.constraint(equalToConstant: 10)
            
        ])
    }
    
    private func configureLabel() {
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leftImageView.trailingAnchor, constant: 5),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5)
        ])
    }
}
