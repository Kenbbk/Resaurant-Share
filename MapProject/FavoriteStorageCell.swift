//
//  FavoriteStorageCell.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/06/29.
//

import UIKit

class FavoriteStoreageCell: UITableViewCell {
    
    //MARK: - Properties
    static let identifier = "FavoriteStoreageCell"
    
    private let leftImageView: UIImageView = {
       let iv = UIImageView()
        iv.image = UIImage(systemName: "star.circle")
        iv.tintColor = .systemGreen
        iv.clipsToBounds = true
        return iv
    }()
    
    private let wholeContainerStackView: UIStackView = {
       let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fillEqually
        return view
    }()
    
    private let titleLabel: UILabel = {
       let label = UILabel()
        label.text = "제주도 먹을거"
        return label
    }()
    
    private let statusView: CustomStatusView = {
       let view = CustomStatusView()
        return view
    }()
    
    private let padding: CGFloat = 10
    private let height: CGFloat = 40
    
    
    
    //MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Actions
    
    //MARK: - Helpers
    
    func setLabel(colorNumber: Int, title: String, numberOfPlaces: Int) {
        leftImageView.tintColor = CustomColor.colors[colorNumber]
        titleLabel.text = title
        statusView.label.text = "\(numberOfPlaces)"
    }
    
    //MARK: - UI
    private func configureUI() {
        configureLeftImageView()
        configureStackView()
        
    }
    
    private func configureLeftImageView() {
        addSubview(leftImageView)
        leftImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leftImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            leftImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            leftImageView.heightAnchor.constraint(equalToConstant: height),
            leftImageView.widthAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func configureStackView() {
        addSubview(wholeContainerStackView)
        wholeContainerStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            wholeContainerStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            wholeContainerStackView.leadingAnchor.constraint(equalTo: leftImageView.trailingAnchor, constant: 10),
            wholeContainerStackView.heightAnchor.constraint(equalToConstant: height),
            wholeContainerStackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        wholeContainerStackView.addArrangedSubview(titleLabel)
        wholeContainerStackView.addArrangedSubview(statusView)
        
        
    }
    
    
    
    
}
