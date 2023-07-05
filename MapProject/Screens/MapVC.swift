//
//  ViewController.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/06/09.
//

//            let safeAreaFrameHeight = view.safeAreaLayoutGuide.layoutFrame.height
//            let heightInSafeArea = containerView.frame.height - view.safeAreaInsets.bottom
//            print("Ratio in safeAreaView \(heightInSafeArea / safeAreaFrameHeight)") // ratio 공식

import UIKit
import NMapsMap
import FirebaseFirestore
import FirebaseAuth
import CoreLocation
import GooglePlaces

enum ScrollViewPosition: CGFloat {
    
    case bottom = 0.85
    case middle = 0.55
    case top = 0.08
    
}

enum UpperViewConstraint: CGFloat {
    case exist = 40
    case none = 0
}

class MapVC: UIViewController {
    
    //MARK: - Properties
    
    
    
    var fetchedPlace: FetchedPlace?
    var markers: [NMFMarker] = []
    var marker = NMFMarker()
    let padding: CGFloat = 15
    var topConstraint: NSLayoutConstraint!
    var upperViewConstraint: NSLayoutConstraint!
    var startingHeight: CGFloat!
    lazy var currentHeight: CGFloat = getHeight(position: .bottom)
    var startingPosition: ScrollViewPosition = .bottom
    
    
    
    var searchResult: [Place] = [] {
        didSet {
            DispatchQueue.main.async {
                self.mytableView.reloadData()
            }
        }
    }
    var isSearhcing = false {
        didSet {
            if isSearhcing {
                rightImageView.isHidden = false
                
                
            } else {
                searchResult.removeAll()
                rightImageView.isHidden = true
                marker.mapView = nil
                resultView.isHidden = true
                
            }
        }
    }
    
    private lazy var mytableView: UITableView = {
        let tb = UITableView()
        tb.delegate = self
        tb.dataSource = self
        tb.isHidden = true
        return tb
    }()
    private lazy var naverMap = NMFMapView()
    
    
    private lazy var searchTF: UITextField = {
        let tf = UITextField()
        tf.delegate = self
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 10
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.systemGray4.cgColor
        
        return tf
    }()
    private lazy var leftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.image = UIImage(systemName: "map.circle")
        imageView.tintColor = .gray
        return imageView
    }()
    
    private lazy var rightImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.image = UIImage(systemName: "x.circle")
        imageView.tintColor = .gray
        return imageView
    }()
    
    lazy var containerView: UIView = {
        let myView = UIView()
        myView.backgroundColor = .white
        myView.layer.cornerRadius = 30
        return myView
    }()
    
    let upperView: UIView = {
        let myView = UIView()
        myView.layer.cornerRadius = 80
        myView.backgroundColor = .white
        return myView
    }()
    
    let dragIcon: UIView = {
        let myView = UIView()
        myView.layer.cornerRadius = 2.5
        myView.backgroundColor = .systemGray3
        return myView
    }()
    
    private lazy var lowerView: UIView = {
        let myView = UIView()
        
        return myView
    }()
    
    lazy var resultView: MPResultView = {
        let myView = MPResultView()
        
        return myView
        
    }()
    
    let infoWindow = NMFInfoWindow()
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        return manager
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        configureUI()
//        let tableView = ((self.children.first as! TabBarVC).viewControllers![0] as! ScrollCategoryVC).placeTableView
//        tableView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(bottomViewBeenScrolled(_:))))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        topConstraint.constant = getHeight(position: startingPosition)
        
    }
    
    //MARK: - Actions
    
    @objc func leftButtonTapped(_ sender: UITapGestureRecognizer) {
        
        naverMap.isHidden = false
        leftImageView.image = UIImage(systemName: "map.circle")
        searchTF.rightViewMode = .whileEditing
        mytableView.isHidden = true
        searchTF.endEditing(true)
        searchTF.text = ""
        isSearhcing = false
        containerView.isHidden = false
        
    }
    
    @objc func rightButtonTapped(_ sender: UITapGestureRecognizer) {
        if mytableView.isHidden == true {
            
            leftImageView.image = UIImage(systemName: "map.circle")
        }
        
        isSearhcing = false
        searchTF.text = ""
        containerView.isHidden = false
    }
    
    @objc func bottomViewBeenScrolled(_ sender: UIPanGestureRecognizer) {
        
        
        if sender.state == .began {
            let tableView = ((self.children.first as! TabBarVC).viewControllers![0] as! ScrollCategoryVC).placeTableView
            tableView.contentOffset.y = 0
            startingHeight = getHeight(position: startingPosition)
            print("Began")
        } else if sender.state == .changed {
            let translation = sender.translation(in: self.view)
            
            currentHeight = startingHeight + translation.y
            
            makeSureHeightIsInTheRange()
            
            topConstraint.constant = currentHeight
            print("Changed")
        } else if sender.state == .ended {
            
            changeTheHeightAtTheEnd()
            print("Ended")
        }
    }
    //MARK: - Helpers
    func scrollCategoryViewFilledTheSuperView(bool: Bool) {
        upperViewConstraint.constant = bool ? view.safeAreaInsets.top : 40
        topConstraint.constant = bool ? -(view.safeAreaInsets.top) : currentHeight
        dragIcon.isHidden = bool
        
        self.loadViewIfNeeded()
    }
    
    private func resetMarkers() {
        guard !markers.isEmpty else { return }
        
        markers.forEach { marker in
            marker.mapView = nil
            
            self.markers = []
            print("Marker Reset")
        }
    }
    
    func makeMarker(with category: Category) {
        resetMarkers()
        
        guard !category.addedPlaces.isEmpty else { return }
        
        for place in category.addedPlaces {
            
            let marker = NMFMarker(position: NMGLatLng(lat: place.lat, lng: place.lon))
            
            marker.captionText = place.name
            marker.mapView = naverMap
            markers.append(marker)
            print("current markers count = \(self.markers.count)")
            
            marker.touchHandler = { (overlay: NMFOverlay) -> Bool in
                print(place.name)
                print("오버레이 터치됨")
                self.resultView.isHidden = false
                
                self.fetchedPlace = place
                let myLocation = self.locationManager.location
                let distance = myLocation?.distance(from: CLLocation(latitude: place.lat, longitude: place.lon))
                
                GooglePlacesManager.shared.resolveLocation(with: place.placeID) { result in
                    switch result {
                    case .failure(let error):
                        print(error)
                        
                    case .success(let fetchedPlace):
                        print("Success")
                        self.fetchedPlace = fetchedPlace
                        self.resultView.setPlaceAndLabels(fetchedPlace: fetchedPlace, distance: NSNumber(floatLiteral: distance!))
                        self.resultView.fetchCategories()
                        self.resultView.changelayOut()
                        
                    }
                }
                return true
            }
        }
        
        DispatchQueue.main.async {
            
            self.marker.mapView = self.naverMap
            print("markers.count =\(self.markers.count)")
            let categoryLatAndLone: [NMGLatLng] = self.markers.compactMap({ $0.position})
            
            print("categoryLatAndLone count = \(categoryLatAndLone.count)")
            let bounds = NMGLatLngBounds(latLngs: categoryLatAndLone)
            
            let cameraUpdate = NMFCameraUpdate(fit: bounds, paddingInsets: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100))
            
            self.naverMap.moveCamera(cameraUpdate)
            
        }
        
        
    }
    
    func makeSureHeightIsInTheRange() {
        if currentHeight <= getHeight(position: .top) {
            currentHeight = getHeight(position: .top)
        }
        if currentHeight >= getHeight(position: .bottom) {
            currentHeight = getHeight(position: .bottom)
            
        }
    }
    
    func changeTheHeightAtTheEnd() {
        switch startingPosition {
        case .bottom:
            
            if currentHeight < getHeight(position: .middle) {
                startingPosition = .top
            } else if currentHeight < getHeight(position: .bottom) {
                startingPosition = .middle
            } else {
                startingPosition = .bottom
            }
            topConstraint.constant = getHeight(position: startingPosition)
            
        case .middle:
            if currentHeight < getHeight(position: .middle) {
                startingPosition = .top
            } else if currentHeight > getHeight(position: .middle) {
                startingPosition = .bottom
            } else {
                startingPosition = .middle
            }
            topConstraint.constant = getHeight(position: startingPosition)
            
        case .top:
            if currentHeight > getHeight(position: .middle) {
                startingPosition = .bottom
            } else if currentHeight > getHeight(position: .top) {
                startingPosition = .middle
            } else {
                startingPosition = .top
            }
            topConstraint.constant = getHeight(position: startingPosition)
            
        }
    }
    
    func getHeight(position: ScrollViewPosition) -> CGFloat {
        let ratio = position.rawValue
        let height = (view.safeAreaLayoutGuide.layoutFrame.height - view.safeAreaInsets.bottom) * ratio
        return height
    }
    
    private func placeTapped() {
        searchTF.endEditing(true)
        mytableView.isHidden = true
        naverMap.isHidden = false
        searchTF.rightViewMode = .always
        containerView.isHidden = true
        resetMarkers()
    }
    
    private func moveCamera() {
        
        print("Moving Camera ka")
        if let location = locationManager.location {
            print("There is a location")
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            let naverLatLon = NMGLatLng(lat: lat, lng: lon)
            print("______________________-\(lat), \(lon)")
            let cameraUpdate = NMFCameraUpdate(scrollTo: naverLatLon)
            
            self.naverMap.moveCamera(cameraUpdate)
            let locationOverlay = naverMap.locationOverlay
            locationOverlay.location = naverLatLon
            locationOverlay.hidden = false
        }
    }
    
    //MARK: - UI
    
    private func configureUI() {
        view.backgroundColor = .white
        configureMap()
        configureTextField()
        configureTableView()
        configureContainerView()
        configureResultView()
    }
    
    private func configureMap() {
        view.addSubview(naverMap)
        naverMap.frame = view.bounds
    }
    
    private func configureTableView() {
        view.addSubview(mytableView)
        
        mytableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mytableView.topAnchor.constraint(equalTo: searchTF.bottomAnchor, constant: 0),
            mytableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mytableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mytableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureTextField() {
        
        view.addSubview(searchTF)
        view.bringSubviewToFront(searchTF)
        
        searchTF.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchTF.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            searchTF.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            searchTF.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            searchTF.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        leftImageView.translatesAutoresizingMaskIntoConstraints = false
        leftImageView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        leftImageView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        
        searchTF.leftView = leftImageView
        searchTF.leftViewMode = .always
        searchTF.leftView?.isUserInteractionEnabled = true
        leftImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(leftButtonTapped(_:))))
        
        rightImageView.translatesAutoresizingMaskIntoConstraints = false
        rightImageView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        rightImageView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        searchTF.rightView = rightImageView
        searchTF.rightViewMode = .whileEditing
        searchTF.rightView?.isUserInteractionEnabled = true
        searchTF.rightView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rightButtonTapped(_:))))
    }
    
    private func configureResultView() {
        view.addSubview(resultView)
        resultView.translatesAutoresizingMaskIntoConstraints = false
        resultView.delegate = self
        NSLayoutConstraint.activate([
            resultView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            resultView.heightAnchor.constraint(equalToConstant: 122)
        ])
    }
    
    private func configureContainerView() {
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        topConstraint = containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: getHeight(position: .bottom))
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            topConstraint
        ])
        
        containerView.addSubview(upperView)
        upperView.translatesAutoresizingMaskIntoConstraints = false
        
        upperViewConstraint = upperView.heightAnchor.constraint(equalToConstant: UpperViewConstraint.exist.rawValue)
        NSLayoutConstraint.activate([
            upperView.topAnchor.constraint(equalTo: containerView.topAnchor),
            upperView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            upperView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            upperViewConstraint
        ])
        
        upperView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(bottomViewBeenScrolled(_:))))

        upperView.addSubview(dragIcon)
        dragIcon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dragIcon.centerYAnchor.constraint(equalTo: upperView.centerYAnchor),
            dragIcon.centerXAnchor.constraint(equalTo: upperView.centerXAnchor),
            dragIcon.widthAnchor.constraint(equalToConstant: 50),
            dragIcon.heightAnchor.constraint(equalToConstant: 5)
        ])
        
        containerView.addSubview(lowerView)
        lowerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lowerView.topAnchor.constraint(equalTo: upperView.bottomAnchor),
            lowerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            lowerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            lowerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        let myTabBarController = TabBarVC()
        myTabBarController.view.frame = lowerView.frame
        addChild(myTabBarController)
        lowerView.addSubview(myTabBarController.view)
        myTabBarController.didMove(toParent: self)
        
    }
}

//MARK: - UITextFieldDelegate

extension MapVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        leftImageView.image = UIImage(systemName: "chevron.backward")
        mytableView.isHidden = false
        naverMap.isHidden = true
        containerView.isHidden = true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else { return }
        if text.isEmpty {
            isSearhcing = false
            return
        }
        isSearhcing = true
        
        GooglePlacesManager.shared.findPlaces(query: text) { result in
            print("----------------------------------")
            switch result {
            case .failure(let error):
                print(error)
            case .success(let places):
                self.searchResult = places
                
            }
        }
    }
}

//MARK: - UITableViewDataSource, UITableViewDelegate
extension MapVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == mytableView {
            return searchResult.count
        } else {
            return 10
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        let selectedItem = searchResult[indexPath.row]
        cell.textLabel?.text = selectedItem.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedPlace = searchResult[indexPath.row]
        
        let distance = selectedPlace.distance
        
        resultView.isHidden = false
        
        GooglePlacesManager.shared.resolveLocation(with: selectedPlace.identifier) { result in
            switch result {
            case .failure(let error):
                print(error)
                return
            case .success(let place):
                
                self.fetchedPlace = place
                let location = NMGLatLng(lat: place.lat, lng: place.lon)
                let cameraUpdate = NMFCameraUpdate(scrollTo: location)
                self.resultView.setPlaceAndLabels(fetchedPlace: place, distance: distance)
                self.resultView.fetchCategories()
                self.resultView.changelayOut()
                
                
                DispatchQueue.main.async {
                    self.marker.position = location
                    self.marker.captionText = place.name
                    self.marker.mapView = self.naverMap
                    self.naverMap.moveCamera(cameraUpdate)
                    self.placeTapped()
                }
            }
        }
    }
}

extension MapVC: CustomResultViewDelegate {
    func favoriteButtonTapped() {
        guard let fetchedPlace else {
            print("There is no fetched Place")
            return }
        let vc = CategoryVC(with: fetchedPlace)
        vc.modalPresentationStyle = .overFullScreen
        
        present(vc, animated: true)
        
        print("Favorite image Tapped")
    }
}

extension MapVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //location5
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("GPS 권한 설정됨")
            //            self.locationManager.startUpdatingLocation() // 중요!
            moveCamera()
        case .restricted, .notDetermined:
            print("GPS 권한 설정되지 않음")
            locationManager.requestWhenInUseAuthorization()
        case .denied:
            print("GPS 권한 요청 거부됨")
            locationManager.requestWhenInUseAuthorization()
        default:
            print("GPS: Default")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.first == nil { return }
        print("LocationManager didupdateLocations called")
        
        
    }
}



