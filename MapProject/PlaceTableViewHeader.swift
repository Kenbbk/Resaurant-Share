//
//  PlaceTableViewHeader.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/06/16.
//

import UIKit

class PlaceTableViewHeader: UITableViewHeaderFooterView {
    static let identifier = "PlaceTableViewHeader"
    
    let titleNameLabel: UILabel = {
       let label = UILabel()
        label.backgroundColor = .systemPink
        label.text = "양산 물금한신더휴 아파트"
        return label
    }()
    
    let addressLabel: UILabel = {
       let label = UILabel()
        label.backgroundColor = .systemCyan
        return label
        
    }()
    
    let distanceLabel: UILabel = {
       let label = UILabel()
        label.backgroundColor = .systemYellow
        return label
    }()
    
    let lowerStackView = UIStackView()
    
    
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        addSubview(titleNameLabel)
        titleNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleNameLabel.topAnchor.constraint(equalTo: self.topAnchor),
            titleNameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            titleNameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            titleNameLabel.heightAnchor.constraint(equalToConstant: 30)

        ])
        
        addSubview(lowerStackView)
        lowerStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lowerStackView.topAnchor.constraint(equalTo: titleNameLabel.bottomAnchor),
            lowerStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            lowerStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            lowerStackView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        

       
        lowerStackView.addArrangedSubview(addressLabel)
        lowerStackView.addArrangedSubview(distanceLabel)

        lowerStackView.axis = .vertical
        lowerStackView.distribution = .fillEqually
        
        
        
//        let myView = UIView()
//        addSubview(myView)
//        myView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            myView.topAnchor.constraint(equalTo: spacerView, constant: <#T##CGFloat#>)
//        ])
    }
}
