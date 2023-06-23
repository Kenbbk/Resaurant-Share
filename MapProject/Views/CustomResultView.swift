//
//  CustomResultView.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/06/16.
//

import UIKit

protocol CustomResultViewDelegate: AnyObject {
    func favoriteButtonTapped()
}

class CustomResultView: UIView {
    
    //MARK: - Properties
    
    static let identifier = "PlaceTableViewHeader"
    
    var fetchedPlace: FetchedPlace?
    
    var categories: [Category] = []
    var addPlaceCategories: [Category] = []
    
    let padding: CGFloat = 10
    let titleNameLabel: UILabel = {
       let label = UILabel()
        
        label.text = "양산 물금한신더휴 아파트"
        label.textColor = .blue.withAlphaComponent(0.60)
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    
    let addressLabel: UILabel = {
       let label = UILabel()
        label.text = "경상남도 양산시 가촌서로 11 물금한신더휴 아파트"
        label.font = UIFont.systemFont(ofSize: 14)
        return label
        
    }()
    
    let distanceLabel: UILabel = {
       let label = UILabel()
        label.text = "40km"
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    let lowerStackView = UIStackView()
    
    let spacerView: UIView = {
       let myView = UIView()
        myView.backgroundColor = .systemGray3
        return myView
    }()
    
    let favoriteImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(systemName: "star")
        imageView.tintColor = .gray
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    var delegate: CustomResultViewDelegate?
    
    
    

    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped(_:)))
        favoriteImageView.addGestureRecognizer(tapGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Actions
    @objc private func imageViewTapped(_ gesture: UITapGestureRecognizer) {
        
        delegate?.favoriteButtonTapped()
        
    }
    
    //MARK: - Helpers
    
    func fetchCategories() {
        guard let fetchedPlace = self.fetchedPlace else { return }
        FavoriteSerivce.fetchCategory { categories in
            let sortedCategories = categories.sorted(by: { $0.timeStamp.dateValue() > $1.timeStamp.dateValue()})
            
            for category in sortedCategories {
                guard let categoryUID = category.categoryUID else { return }
                let query = COLLECTION_USERS.document(FavoriteSerivce.uid!).collection("categories").document(categoryUID).collection("places").whereField("title", isEqualTo: fetchedPlace.title)
                
                query.getDocuments { snapshot, error in
                    guard let document = snapshot?.documents else { return }
                    
                    if document.isEmpty == false {
                        
                        self.addPlaceCategories.append(category)
                        print(category.title)
                    }
                }
            }
        }

    }
    
    
    
    
    
    func setLabels(with fetchedPlace: FetchedPlace) {
        self.fetchedPlace = fetchedPlace
        titleNameLabel.text = fetchedPlace.title
        addressLabel.text = fetchedPlace.address
        distanceLabel.text = "50Km"
    }
    

    private func configureSelf() {
        isHidden = true
        backgroundColor = .white
        layer.cornerRadius = 6
        layer.borderWidth = 0.2
        layer.borderColor = UIColor.gray.cgColor
    }
    
    private func configureUI() {
        configureSelf()
        
        addSubview(titleNameLabel)
        titleNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleNameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: padding),
            titleNameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding),
            titleNameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            titleNameLabel.heightAnchor.constraint(equalToConstant: 35)
//            titleNameLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        addSubview(lowerStackView)
        lowerStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lowerStackView.topAnchor.constraint(equalTo: titleNameLabel.bottomAnchor),
            lowerStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding),
            lowerStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            lowerStackView.heightAnchor.constraint(equalToConstant: 42)
        ])

       
        lowerStackView.addArrangedSubview(addressLabel)
        lowerStackView.addArrangedSubview(distanceLabel)

        
        lowerStackView.axis = .vertical
        lowerStackView.distribution = .fillEqually
        
        addSubview(spacerView)
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spacerView.topAnchor.constraint(equalTo: lowerStackView.bottomAnchor, constant: 4),
            spacerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            spacerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            spacerView.heightAnchor.constraint(equalToConstant: 0.7)
        ])
        
        addSubview(favoriteImageView)
        favoriteImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            favoriteImageView.topAnchor.constraint(equalTo: spacerView.bottomAnchor, constant: 4),
            favoriteImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 50),
            favoriteImageView.widthAnchor.constraint(equalToConstant: 20),
            favoriteImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
}

