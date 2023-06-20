//
//  ColorCollectionViewCell.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/06/18.
//

import UIKit

class ColorCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "ColorCollectionViewCell"
    
    override var isSelected: Bool {
        didSet {
            isSelected ? didselectedChangeTheColor() : notSelected()
        }
    }
    
    var themeColor: UIColor = .clear

    
    
    let containerViewPadding: CGFloat = 5
    let imageViewPadding: CGFloat = 5
    
    lazy var containerView: UIView = {
        let containerView = UIView()
        
        
        return containerView
    }()
    
    lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.image = UIImage(named: "checkmark-512")?.withRenderingMode(.alwaysTemplate)
        iv.tintColor = .clear
        
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 20
        
        configureUI()
       
    }
    
//    convenience init(with color: UIColor) {
//        self.init(frame: .zero)
//    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpInitialColor(with color: UIColor) {
        themeColor = color
        imageView.backgroundColor = themeColor
        containerView.backgroundColor = themeColor
    }
    
    func didselectedChangeTheColor() {
        imageView.tintColor = .white
        backgroundColor = themeColor.withAlphaComponent(0.5)
    }
    
    func notSelected() {
        imageView.tintColor = .clear
        backgroundColor = .clear
    }
    
    private func configureUI() {
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.cornerRadius = (frame.width - (containerViewPadding * 2)) / 2
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: containerViewPadding),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: containerViewPadding),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -containerViewPadding),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -containerViewPadding)
        ])
        
        containerView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = (containerView.frame.width - (imageViewPadding * 2)) / 2
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: imageViewPadding),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: imageViewPadding),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -imageViewPadding),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -imageViewPadding)
        ])
    }
}
// red, orage, yellow, light green, green, sky, purple, pink, gray , blue, heavy ocean, gray
