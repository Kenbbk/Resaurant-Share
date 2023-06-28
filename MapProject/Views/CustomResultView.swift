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
    
    
    let padding: CGFloat                    = 10
    
    let titleNameLabel: UILabel = {
        let label = UILabel()
        
        label.text                          = "양산 물금한신더휴 아파트"
        label.textColor                     = .blue.withAlphaComponent(0.60)
        label.font                          = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    
    let addressLabel: UILabel = {
        let label = UILabel()
        label.text                          = "경상남도 양산시 가촌서로 11 물금한신더휴 아파트"
        label.font                          = UIFont.systemFont(ofSize: 14)
        label.adjustsFontSizeToFitWidth     = true
        return label
        
    }()
    
    let distanceLabel: UILabel = {
        let label                            = UILabel()
        label.text                          = "40km"
        label.font                          = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    let spacerView: UIView = {
        let myView                           = UIView()
        myView.backgroundColor              = .systemGray3
        return myView
    }()
    
    let favoriteImageView: UIImageView = {
        let imageView                        = UIImageView()
        imageView.image                     = UIImage(systemName: "star")
        imageView.tintColor                 = .gray
        imageView.clipsToBounds             = true
        imageView.isUserInteractionEnabled  = true
        return imageView
    }()
    
    let categoryView: CustomCategoryView = {
        let view = CustomCategoryView()
        
        return view
    }()
    
    lazy var savedLabel: UILabel = {
        let label                            = UILabel()
        label.numberOfLines                 = 1
        label.adjustsFontSizeToFitWidth     = true
        label.text                          = "and 1 more"
        return label
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
    
    func changelayOut() {
        
        resetCateogryViewAndSavedLabel()
        let addedCategory = UserInfo.shared.addedCategories
        
        DispatchQueue.main.async {
            switch addedCategory.isEmpty {
            case true:
                self.categoryView.isHidden                  = true
                self.savedLabel.isHidden                    = true
                self.favoriteImageView.image                = UIImage(systemName: "star")
                self.favoriteImageView.tintColor            = .gray
            case false:
                self.categoryView.isHidden                  = false
                self.savedLabel.isHidden                    = false
                self.favoriteImageView.image                = UIImage(systemName: "star.fill")
                self.favoriteImageView.tintColor            = .orange.withAlphaComponent(0.8)
                guard let firstAddedCategory                = addedCategory.first else { print("I cannot grab firstAddedCategory"); return }
                self.categoryView.label.text                = firstAddedCategory.title
                self.categoryView.leftImageView.tintColor   = CustomColor.colors[firstAddedCategory.colorNumber]
                self.savedLabel.text                        = addedCategory.count >= 2 ? "and \(addedCategory.count - 1) more" : " Saved"
            }
            
            self.categoryView.layer.cornerRadius            = self.categoryView.frame.height / 2
            
        }
    }
    func resetCateogryViewAndSavedLabel() {
        DispatchQueue.main.async {
            self.categoryView.isHidden              = true
            self.savedLabel.isHidden                = true
            self.favoriteImageView.image            = UIImage(named: "star")
            self.favoriteImageView.tintColor        = .gray
            
            
            
        }
    }
    
    func fetchCategories(completion:( () -> Void)? = nil) {
        
        guard let fetchedPlace = self.fetchedPlace else {
            print("There is no fetchedPlace")
            return
        }
        let group = DispatchGroup()
        var addedCategories: [Category] = []
        for category in UserInfo.shared.categories {
            group.enter()
            print("Entering")
            guard let categoryUID = category.categoryUID else { return }
            
            let query = COLLECTION_USERS.document(FavoriteSerivce.uid!).collection("categories").document(categoryUID).collection("places").whereField("title", isEqualTo: fetchedPlace.title)
            query.getDocuments { snapshot, error in
                defer { group.leave() }
                
                guard let document = snapshot?.documents else { return }
                
                if document.isEmpty == false {
                    
                    
                    addedCategories.append(category)
                    
                }
            }
        }
        group.notify(queue: .main) {
            UserInfo.shared.addedCategories = addedCategories
            completion?()
        }
    }
    
    func setPlaceAndLabels(fetchedPlace: FetchedPlace, thereIsUserLocation: Bool ) {
        self.fetchedPlace = fetchedPlace
        setLabels(thereIsUserLocation: thereIsUserLocation)
    }
    
    func setLabels(thereIsUserLocation: Bool) {
        guard let fetchedPlace else { return }
        
        DispatchQueue.main.async {
            self.titleNameLabel.text = fetchedPlace.title
            self.addressLabel.text   = fetchedPlace.address
            
            if thereIsUserLocation {
                if let distance = fetchedPlace.distance {
                    let roundedDistance = Int( ( distance / 1000 ).rounded())
                    self.distanceLabel.text  = "\(roundedDistance)Km"
                }
            } else {
                self.distanceLabel.text = ""
            }
        }
       
       
        
    }
    
    private func setSavedCategoryLabel() {
        if UserInfo.shared.addedCategories.count >= 2 {
            
        }
    }
    
    
    private func configureSelf() {
        isHidden                = true
        backgroundColor         = .white
        layer.cornerRadius      = 6
        layer.borderWidth       = 0.2
        layer.borderColor       = UIColor.gray.cgColor
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
            
        ])
        
        addSubview(addressLabel)
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addressLabel.topAnchor.constraint(equalTo: titleNameLabel.bottomAnchor),
            addressLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            addressLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            addressLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        addSubview(distanceLabel)
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            distanceLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor),
            distanceLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
//            distanceLabel.widthAnchor.constraint(equalToConstant: 45),
            distanceLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        addSubview(categoryView)
        categoryView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            categoryView.centerYAnchor.constraint(equalTo: distanceLabel.centerYAnchor),
            categoryView.leadingAnchor.constraint(equalTo: distanceLabel.trailingAnchor, constant: 5),
            
        ])
        
        addSubview(savedLabel)
        savedLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            savedLabel.centerYAnchor.constraint(equalTo: distanceLabel.centerYAnchor),
            savedLabel.leadingAnchor.constraint(equalTo: categoryView.trailingAnchor, constant: 5),
            
        ])
        
        
        addSubview(spacerView)
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spacerView.topAnchor.constraint(equalTo: distanceLabel.bottomAnchor, constant: 4),
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


// 내일배움단, 내일배움캠프
