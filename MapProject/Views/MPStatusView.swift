//
//  CustomStatusView.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/06/29.
//

import UIKit

class MPStatusView: UIView {
    
    private let leftImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: "mappin.circle.fill")
       return iv
    }()
    
     let label: UILabel = {
        let label = UILabel()
//        label.text = "1"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        configureLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        addSubview(leftImageView)
        leftImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leftImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            leftImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
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
