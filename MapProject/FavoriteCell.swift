//
//  FavoriteCell.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/06/17.
//

import UIKit

class FavoriteCell: UITableViewCell {
    
    static let identifier = "FavoriteCell"
    //MARK: - Properties
    
    private let leftImageView: UIImageView = {
       let iv = UIImageView()
        iv.image = UIImage(systemName: "star.circle")
        iv.tintColor = .systemGreen
        iv.clipsToBounds = true
        return iv
    }()
    
    private let label: UILabel = {
       let label = UILabel()
        label.text = "제주도 먹을거"
        return label
    }()
    
    private let rightImageView: UIImageView = {
       let iv = UIImageView()
        iv.image = UIImage(systemName: "checkmark.circle")
        iv.tintColor = .systemGray3
        iv.clipsToBounds = true
        return iv
    }()
    
    //MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
        setLabelText()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Actions
    
    
    //MARK: - Helpers
    
    private func configureUI() {
        let padding: CGFloat = 10
        let height: CGFloat = 30
        
        addSubview(leftImageView)
        leftImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leftImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            leftImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding),
            leftImageView.widthAnchor.constraint(equalToConstant: 20),
            leftImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        addSubview(rightImageView)
        rightImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rightImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            rightImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -padding),
            rightImageView.widthAnchor.constraint(equalToConstant: 20),
            rightImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: leftImageView.trailingAnchor, constant: 5),
            label.trailingAnchor.constraint(equalTo: rightImageView.leadingAnchor, constant: -5),
            label.heightAnchor.constraint(equalToConstant: height)
            
        ])
    }
    
    func setLabelText() {
        let attributedText = NSMutableAttributedString(string: "제주도 먹을거", attributes: [.font: UIFont.boldSystemFont(ofSize: 18)])
        
        
        attributedText.append(NSAttributedString(string: " 17", attributes: [.font: UIFont.systemFont(ofSize: 18), .foregroundColor: UIColor.black.withAlphaComponent(0.6)]))
        
        label.attributedText = attributedText
    }
    
    
    
    
}
