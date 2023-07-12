//
//  FavPlaceCell.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/07/08.
//

import UIKit
import SnapKit
import GooglePlaces

class FavPlaceCell: UITableViewCell {
    
    static let identifier = "FavPlaceCell"
    
    //MARK: - Properties
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "서귀포매일올레시장"
        label.font = UIFont.boldSystemFont(ofSize: 22)
        return label
    }()
    
    let distanceLabel: UILabel = {
        let label = UILabel()
        label.text = "320Km"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.systemGray
        return label
    }()
    
    let addressLabel: UILabel = {
        let label = UILabel()
        label.text = "제주특별자치도 서귀포시 서귀동 340"
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 5
        view.distribution = .fillEqually
        return view
    }()
    
    let leftImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .systemGray6
        return iv
    }()
    
    let middleImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .systemGray6
        return iv
    }()
    
    let rightImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .systemGray6
        return iv
    }()
    
    //MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
    
    
    
    //MARK: - Actions
    
    //MARK: - Helpers
    
    func configureImage(fetchPlace: FetchedPlace) {
        
        GooglePlacesManager.shared.decodePhotoData(place: fetchPlace) { images in
            guard let images else { return }
//            print("\(fetchPlace.name) Image should be on")
            for (index, image) in images.enumerated() {
                switch index {
                    
                case 0:
                    DispatchQueue.main.async {
                        self.leftImageView.image = image
                        if fetchPlace.name == "RRACE" {
                            print("RRACE photo is already up")
                        }
                        
                        if fetchPlace.name == "RR쇼륨" {
                            print("RR쇼륨 photo is already up")
                        }
                    }
                    
                case 1:
                    DispatchQueue.main.async {
                        self.middleImageView.image = image
                    }
                    
                case 2:
                    DispatchQueue.main.async {
                        self.rightImageView.image = image
                    }
                    
                default:
                    break
                }
            }
        }
        
    }
    //        for (index, data) in photoData.enumerated() {
    //            GMSPlacesClient.shared().loadPlacePhoto(data) { image, error in
    //                if let error {
    //                    print(error)
    //                }
    //                guard let image else { return }
    //
    //                switch index {
    //                case 0:
    //                    self.leftImageView.image = image
    //                case 1:
    //                    self.middleImageView.image = image
    //                case 2:
    //                    self.rightImageView.image = image
    //                default:
    //                    break
    //                }
    //            }
    //        }
    //        let group = DispatchGroup()
    //        for photo in photoData {
    //            group.enter()
    //            GMSPlacesClient.shared().loadPlacePhoto(photo) { image, error in
    //                defer {
    //                    group.leave()
    //                }
    //                if let image = image {
    //                    imageArray.append(image)
    //                }
    //
    //
    //            }
    //        }
    //
    //        group.notify(queue: .main) {
    //            print("imageArray count \(imageArray.count)")
    //            self.leftImageView.image = imageArray.first
    //            if imageArray.count > 2 {
    //                self.middleImageView.image = imageArray[1]
    //            }
    //            self.rightImageView.image = imageArray.last
    //        }
    
    


func configureCell(addPlace: FetchedPlace) {
    nameLabel.text = addPlace.name
    addressLabel.text = addPlace.address
}

private func configureUI() {
    contentView.addSubview(nameLabel)
    nameLabel.snp.makeConstraints { make in
        make.top.leading.equalToSuperview()
        make.height.equalTo(30)
    }
    
    contentView.addSubview(distanceLabel)
    distanceLabel.snp.makeConstraints { make in
        make.top.equalTo(nameLabel.snp.bottom)
        make.leading.equalToSuperview()
        make.height.equalTo(20)
    }
    
    contentView.addSubview(addressLabel)
    addressLabel.snp.makeConstraints { make in
        make.centerY.equalTo(distanceLabel.snp.centerY)
        make.leading.equalTo(distanceLabel.snp.trailing).offset(5)
        make.height.equalTo(20)
    }
    
    contentView.addSubview(stackView)
    stackView.snp.makeConstraints { make in
        make.top.equalTo(distanceLabel.snp.bottom).offset(5)
        make.leading.trailing.equalToSuperview()
        make.height.equalTo(100)
    }
    stackView.addArrangedSubview(leftImageView)
    stackView.addArrangedSubview(middleImageView)
    stackView.addArrangedSubview(rightImageView)
    
}
}
