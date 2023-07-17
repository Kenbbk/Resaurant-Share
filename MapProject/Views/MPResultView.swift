//
//  CustomResultView.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/06/16.
//

import UIKit
import GooglePlaces

protocol CustomResultViewDelegate: AnyObject {
    func favoriteButtonTapped()
}

class MPResultView: UIView {
    
    //MARK: - Properties
    
    var fetchedPlace: FetchedPlace? {
        didSet {
            fetchCategories {
                self.fetchFavoritedCategories {
                    
                    self.resetUI()
                    self.changelayOut()
                }
            }
        }
    }
    
    var categories: [Category] = []
    
    var favoritedCategories: [Category] = []
    
    let padding: CGFloat                    = 10
    
    private let titleNameLabel: UILabel = {
        let label = UILabel()
        
        label.text                          = "양산 물금한신더휴 아파트"
        label.textColor                     = .blue.withAlphaComponent(0.60)
        label.font                          = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.systemGray
        label.text = "Cafe"
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.text                          = "경상남도 양산시 가촌서로 11 물금한신더휴 아파트"
        label.font                          = UIFont.systemFont(ofSize: 14)
        label.adjustsFontSizeToFitWidth     = true
        return label
        
    }()
    
    private let distanceLabel: UILabel = {
        let label                            = UILabel()
        label.text                          = "40km"
        label.font                          = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    private let spacerView: UIView = {
        let myView                           = UIView()
        myView.backgroundColor              = .systemGray3
        return myView
    }()
    
    private let favoriteImageView: UIImageView = {
        let imageView                        = UIImageView()
        imageView.image                     = UIImage(systemName: "star")
        imageView.tintColor                 = .gray
        imageView.clipsToBounds             = true
        imageView.isUserInteractionEnabled  = true
        return imageView
    }()
    
    private let categoryView: MPSavedSignView = {
        let view = MPSavedSignView()
        
        return view
    }()
    
    private lazy var savedLabel: UILabel = {
        let label                            = UILabel()
        label.numberOfLines                 = 1
        return label
    }()
    
    lazy var placePhotoImageView: UIImageView = {
        let iv = UIImageView()
        
        iv.clipsToBounds = true
        return iv
    }()
    
    weak var delegate: CustomResultViewDelegate?
    
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
    
    private func changelayOut() {
        
        switch favoritedCategories.isEmpty {
            
        case true:
            categoryView.isHidden                  = true
            savedLabel.isHidden                    = true
            favoriteImageView.image                = UIImage(systemName: "star")
            favoriteImageView.tintColor            = .gray
            
        case false:
            categoryView.isHidden                  = false
            savedLabel.isHidden                    = false
            favoriteImageView.image                = UIImage(systemName: "star.fill")
            favoriteImageView.tintColor            = .orange.withAlphaComponent(0.8)
            
            guard let firstAddedCategory           = favoritedCategories.first else { return }
            categoryView.label.text                = firstAddedCategory.title
            categoryView.leftImageView.tintColor   = CustomColor.colors[firstAddedCategory.colorNumber]
            savedLabel.text                        = favoritedCategories.count >= 2 ? "and \(favoritedCategories.count - 1) more" : " Saved"
        }
        categoryView.layer.cornerRadius            = categoryView.frame.height / 2
    }
    
    private func resetUI() {
        
            self.categoryView.isHidden              = true
            self.savedLabel.isHidden                = true
            self.favoriteImageView.image            = UIImage(named: "star")
            self.favoriteImageView.tintColor        = .gray
    }
    
    private func fetchCategories(completion: @escaping () -> Void) {
        FavoriteSerivce.shared.fetchCategories { categories in
            self.categories = categories
            completion()
        }
    }
    
    private func fetchFavoritedCategories(completion: @escaping () -> Void) {
        guard let fetchedPlace else { return }
        FavoriteSerivce.shared.getFavoritedCategories(categories: categories, place: fetchedPlace) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let categories):
                self.favoritedCategories = categories
                completion()
            }
        }
    }
    
    func setLabels(distance: NSNumber) {
        
        resetPlacePhotoImageView()
        
        guard let fetchedPlace else { return }
        
        titleNameLabel.text = fetchedPlace.name
        typeLabel.text = fetchedPlace.type
        addressLabel.text = fetchedPlace.address
        distanceLabel.text = distance.getDistanceString()
        
        loadPhoto { image in
            self.placePhotoImageView.image = image
        }
    }
    
    private func resetPlacePhotoImageView() {
        placePhotoImageView.image = UIImage()
    }
    
    
    private func loadPhoto(completion: @escaping (UIImage?) -> Void) {
        if let photoData = fetchedPlace?.image.first {
            
            GMSPlacesClient.shared().loadPlacePhoto(photoData) { image, error in
                
                if let error {
                    print(error)
                    completion(nil)
                    return
                }
                
                completion(image)
            }
        }
    }
    
    //MARK: - UI
    private func configureSelf() {
        isHidden                = true
        backgroundColor         = .white
        layer.cornerRadius      = 6
        layer.borderWidth       = 0.2
        layer.borderColor       = UIColor.gray.cgColor
    }
    
    private func configureUI() {
        configureSelf()
        
        addSubview(placePhotoImageView)
        placePhotoImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            placePhotoImageView.topAnchor.constraint(equalTo: topAnchor, constant: 7),
            placePhotoImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -7),
            placePhotoImageView.heightAnchor.constraint(equalToConstant: 75),
            placePhotoImageView.widthAnchor.constraint(equalToConstant: 75)
        ])
        
        addSubview(titleNameLabel)
        titleNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleNameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: padding),
            titleNameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding),
            //            titleNameLabel.trailingAnchor.constraint(equalTo: placePhotoImageView.leadingAnchor),
            titleNameLabel.heightAnchor.constraint(equalToConstant: 35)
            
        ])
        
        addSubview(typeLabel)
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            typeLabel.centerYAnchor.constraint(equalTo: titleNameLabel.centerYAnchor),
            typeLabel.leadingAnchor.constraint(equalTo: titleNameLabel.trailingAnchor, constant: 5),
            typeLabel.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        addSubview(addressLabel)
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addressLabel.topAnchor.constraint(equalTo: titleNameLabel.bottomAnchor),
            addressLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            addressLabel.trailingAnchor.constraint(equalTo: placePhotoImageView.leadingAnchor, constant: -10),
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
            savedLabel.trailingAnchor.constraint(lessThanOrEqualTo: placePhotoImageView.leadingAnchor, constant: -5)
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


