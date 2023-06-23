//
//  CreateCell.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/06/22.
//

import UIKit

class CreateCell: UITableViewCell {
    
    static let identifier = "CreateCell"
    //MARK: - Properties

    
    
    
    private let leftImageView: UIImageView = {
       let iv = UIImageView()
        iv.image = UIImage(systemName: "plus.circle")
        iv.tintColor = .systemGreen
        iv.clipsToBounds = true
        return iv
    }()
    
    private let label: UILabel = {
       let label = UILabel()
        let attributedText = NSAttributedString(string: "Create list", attributes: [.font: UIFont.boldSystemFont(ofSize: 18), .foregroundColor: UIColor.systemGray3])
        label.attributedText = attributedText
        return label
    }()
    
    
    
    //MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        configureUI()
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
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
        
        
        
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: leftImageView.trailingAnchor, constant: 5),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            label.heightAnchor.constraint(equalToConstant: height)
            
        ])
    }
    
    
    
    
    
    
    
    
    
    
}
