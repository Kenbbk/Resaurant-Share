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

enum ScrollViewPosition: CGFloat {
    //    case bottom = 0.87
    case bottom = 0.90
    case middle = 0.55
    case top = 0.085
    
}

class ViewController: UIViewController {
    
    //MARK: - Properties
    
    var lat: Double = 0 {
        didSet {
            print("Lat has been set ,\(lat)")
            //            let cameraUpdate = NMFCameraUpdate(scrollTo: searchedLocation)
            //            self.naverMap.moveCamera(cameraUpdate)
        }
    }
    var fetchedPlace: FetchedPlace?
    
    var marker = NMFMarker()
    let padding: CGFloat = 15
    var topConstraint: NSLayoutConstraint!
    var startingHeight: CGFloat!
    var currentHeight: CGFloat!
    var startingPosition: ScrollViewPosition = .bottom
    
    let dragIcon: UIView = {
        let myView = UIView()
        myView.layer.cornerRadius = 2.5
        myView.backgroundColor = .systemGray3
        return myView
    }()
    
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
        tb.isHidden = true
        return tb
    }()
    private lazy var naverMap = NMFMapView()
    
    
    private lazy var searchTF: UITextField = {
        let tf = UITextField()
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
    
    private lazy var containerView: UIView = {
        let myView = UIView()
        myView.backgroundColor = .systemPink
        return myView
    }()
    
    private lazy var upperView: UIView = {
        let myView = UIView()
        myView.backgroundColor = .white
        return myView
    }()
    
    private lazy var lowerView: UIView = {
        let myView = UIView()
        
        return myView
    }()
    
    private lazy var myTableView2: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    private lazy var disappearingView: UIView = {
        let myView = UIView()
        myView.backgroundColor = .systemPink
        return myView
    }()
    
    lazy var resultView: CustomResultView = {
        let myView = CustomResultView()
        
        return myView
        
    }()
    
    private lazy var favoriteView: UIView = {
        let myView = UIView()
        myView.isHidden = true
        return myView
    }()
    let infoWindow = NMFInfoWindow()
    var customInfoWindowDataSource = CustomInfoWindowDataSource()
    
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
        //        locationManager.startUpdatingLocation()
        //        if let location = locationManager.location {
        //            print("There is location")
        //            let lat = location.coordinate.latitude
        //            let lon = location.coordinate.longitude
        //            print("---------4-4-4-4-4-4-\(lat), \(lon)")
        //        }
        configureUI()
        
        
        let marker = NMFMarker()
        marker.position = NMGLatLng(lat: 37.3588603, lng: 127.1052063)
        marker.mapView = naverMap
        infoWindow.anchor = CGPoint(x: 0, y: 1)
        infoWindow.dataSource = customInfoWindowDataSource
        infoWindow.offsetX = -40
        infoWindow.offsetY = -5
        
        infoWindow.open(with: marker)
        
        infoWindow.touchHandler = { [weak self] (overlay: NMFOverlay) -> Bool in
            //            customInfoWindowDataSource.rootView.
            //            print("I am")
            return true
        }
        infoWindow.open(with: marker)
        
        guard let _ = Auth.auth().currentUser else { return }
        
        containerView.isHidden = true
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        topConstraint.constant = getHeight(position: startingPosition)
        
        
    }
    
    //MARK: - Actions
    @objc func customViewTapped() {
        print("Custom View Tapped")
    }
    
    @objc func leftButtonTapped(_ sender: UITapGestureRecognizer) {
        if mytableView.isHidden {
            
            mytableView.isHidden = false
            naverMap.isHidden = true
            searchTF.rightViewMode = .never
        } else {
            mytableView.isHidden = true
            naverMap.isHidden = false
            leftImageView.image = UIImage(systemName: "map.circle")
            
            searchTF.rightViewMode = .whileEditing
        }
        searchTF.endEditing(true)
        searchTF.text = ""
        isSearhcing = false
        
    }
    
    @objc func rightButtonTapped(_ sender: UITapGestureRecognizer) {
        if mytableView.isHidden == true {
            
            leftImageView.image = UIImage(systemName: "map.circle")
            
        }
        
        isSearhcing = false
        searchTF.text = ""
    }
    
    @objc func bottomViewBeenScrolled(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            
            startingHeight = getHeight(position: startingPosition)
            
        } else if sender.state == .changed {
            let translation = sender.translation(in: self.view)
            
            currentHeight = startingHeight + translation.y
            
            makeSureHeightIsInTheRange()
            
            topConstraint.constant = currentHeight
            
        } else if sender.state == .ended {
            
            changeTheHeightAtTheEnd()
            
        }
    }
    //MARK: - Helpers
    
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
        //        leftImageView.image = UIImage(systemName: "map.circle")
        searchTF.rightViewMode = .always
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
        configureFavoriteView()
        
        
        
    }
    
    private func configureMap() {
        view.addSubview(naverMap)
        
        naverMap.frame = view.bounds
        
    }
    
    private func configureFavoriteView() {
        
        view.addSubview(favoriteView)
        favoriteView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            favoriteView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            favoriteView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            favoriteView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            favoriteView.heightAnchor.constraint(equalToConstant: 500)
        ])
        let favoriteAddVC = FavoriteAddVC()
        addChild(favoriteAddVC)
        favoriteView.addSubview(favoriteAddVC.view)
        favoriteAddVC.view.frame = favoriteView.frame
        favoriteAddVC.didMove(toParent: self)
    }
    private func configureTableView() {
        view.addSubview(mytableView)
        mytableView.delegate = self
        mytableView.dataSource = self
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
        searchTF.delegate = self
        searchTF.backgroundColor = .white
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
        NSLayoutConstraint.activate([
            upperView.topAnchor.constraint(equalTo: containerView.topAnchor),
            upperView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            upperView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            upperView.heightAnchor.constraint(equalToConstant: 20)
        ])
        upperView.backgroundColor = .black
        
        upperView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(bottomViewBeenScrolled(_:))))
        
        upperView.addSubview(dragIcon)
        dragIcon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dragIcon.centerYAnchor.constraint(equalTo: upperView.centerYAnchor),
            dragIcon.centerXAnchor.constraint(equalTo: upperView.centerXAnchor),
            dragIcon.widthAnchor.constraint(equalToConstant: 50),
            dragIcon.heightAnchor.constraint(equalToConstant: 5)
        ])
        
        
        
        
        
        containerView.addSubview(myTableView2)
        myTableView2.translatesAutoresizingMaskIntoConstraints = false
        myTableView2.dataSource = self
        myTableView2.delegate = self
        //        myTableView2.sectionHeaderHeight = 100
        myTableView2.sectionHeaderTopPadding = 0
        //        myTableView2.register(PlaceTableViewHeader.self, forHeaderFooterViewReuseIdentifier: PlaceTableViewHeader.identifier)
        myTableView2.tableHeaderView?.isUserInteractionEnabled = false
        NSLayoutConstraint.activate([
            myTableView2.topAnchor.constraint(equalTo: upperView.bottomAnchor),
            myTableView2.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            myTableView2.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            myTableView2.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        
    }
    
    func converHTMLString(with HTMLString: String, targetString: String) -> NSMutableAttributedString {
        
        var mutableString = NSMutableAttributedString()
        guard let data = HTMLString.data(using: .utf8) else {
            return mutableString
        }
        
        do {
            mutableString = try NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
            mutableString.addAttributes([.foregroundColor: UIColor.black, .font: UIFont(name: "AppleSDGothicNeo-Regular", size: 15)!], range: NSRange(location: 0, length: mutableString.length))
            
            let range = (mutableString.string as NSString).range(of: targetString)
            if (range.length > 0) {
                mutableString.addAttributes([.foregroundColor: UIColor.blue], range: range)
            }
            
        } catch {
            
        }
        
        return mutableString
    }
}

//MARK: - UITextFieldDelegate

extension ViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        leftImageView.image = UIImage(systemName: "chevron.backward")
        mytableView.isHidden = false
        naverMap.isHidden = true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else { return }
        if text.isEmpty {
            isSearhcing = false
            return
        }
        isSearhcing = true
        
        NetworkManager.shared.getSearchResult(query: text) { places in
            guard let places else { return }
            print(places)
//            for place in places {
//                print("_________________________\(place.mapx), \(place.mapy)")
//            }
            self.searchResult = places
        }
    }
    
}

//MARK: - UITableViewDataSource, UITableViewDelegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == mytableView {
            return searchResult.count
        } else {
            return 10
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == mytableView {
            let cell = UITableViewCell()
            let originalText = searchResult[indexPath.row].title
            let editedText = converHTMLString(with: originalText, targetString: searchTF.text!)
            
            cell.textLabel?.attributedText = editedText
            
            return cell
        } else {
            let cell = UITableViewCell()
            cell.textLabel?.text = String(indexPath.row)
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedPlace = searchResult[indexPath.row]
        let originalText = selectedPlace.title
        let editedText = self.converHTMLString(with: originalText, targetString: "")
        let roadAddress = selectedPlace.roadAddress
        
        resultView.isHidden = false
        
        
        
       
        let currentLocation = locationManager.location
        
        
        NetworkManager.shared.getLatLon(with: roadAddress, location: currentLocation) { coordinateAndDistance in
            guard let coordinateAndDistance else { return }
            let distance = coordinateAndDistance.distance
            
            
            print("---------------------------------------\(distance)")
            guard let lat = Double(coordinateAndDistance.y), let lon = Double(coordinateAndDistance.x) else { return }
            
            
            let searchedLocation = NMGLatLng(lat: lat, lng: lon)
            let cameraUpdate = NMFCameraUpdate(scrollTo: searchedLocation)
            
            let fetchedPlace = FetchedPlace(title: editedText.string, address: roadAddress, lat: lat, lon: lon, distance: distance )
            
            self.fetchedPlace = fetchedPlace
            self.resultView.setPlaceAndLabels(fetchedPlace: fetchedPlace, thereIsUserLocation: currentLocation !== nil)
            self.resultView.resetCateogryViewAndSavedLabel()
            
            self.resultView.fetchCategories {
                self.resultView.changelayOut()
            }
            
            
            
            DispatchQueue.main.async {
                self.marker.position = searchedLocation
                self.marker.captionText = editedText.string
                self.marker.mapView = self.naverMap
                self.naverMap.moveCamera(cameraUpdate)
                self.placeTapped()
            }
        }
        
        searchTF.resignFirstResponder()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}

extension ViewController: CustomResultViewDelegate {
    func favoriteButtonTapped() {
        guard let fetchedPlace else { return }
        let vc = FavoriteViewController(with: fetchedPlace)
        vc.modalPresentationStyle = .overFullScreen
        
        present(vc, animated: true)
        
        print("Favorite image Tapped")
    }
}

extension ViewController: CLLocationManagerDelegate {
    
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
        
//        let location = locations[locations.count - 1]
//
//        let lon = location.coordinate.longitude
//        let lat = location.coordinate.latitude
//        self.lat = lat
//        print("0-0-0-0-0-0-0-0-0-0-0-0-\(lat), \(lon)")
        
    }
}



