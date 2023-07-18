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
import SnapKit

class MapVC: UIViewController {
    
    //MARK: - Properties
    
    
    
    var fetchedPlace: FetchedPlace?
    var markers: [NMFMarker] = []
    var marker = NMFMarker()
    let padding: CGFloat = 15
    
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
    
    let ScrollableCategoryView: CategoryScrollableView = {
        let view = CategoryScrollableView()
        
        return view
    }()
    
    private lazy var scrollablePlacesView: PlaceScrollableView = {
        let view = PlaceScrollableView()
        view.isHidden = true
        return view
    }()
    
    lazy var resultView: MPResultView = {
        let myView = MPResultView()
        
        return myView
    }()
    
    private lazy var rightCancelImageView: UIImageView = {
        let iv = UIImageView()
        iv.isHidden = true
        iv.isUserInteractionEnabled = true
        iv.layer.cornerRadius = 15
        iv.tintColor = .systemGray3
        iv.backgroundColor = .systemGray6
        iv.image = UIImage(systemName: "x.circle.fill")
        iv.clipsToBounds = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rightCancelImageTapped(_:))))
        return iv
    }()
    
    private lazy var leftBackImageView: UIImageView = {
        let iv = UIImageView()
        iv.isHidden = true
        iv.layer.cornerRadius = 15
        iv.tintColor = .systemGray3
        iv.backgroundColor = .systemGray6
        iv.image = UIImage(systemName: "chevron.backward.circle.fill")
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(leftBackImageTapped(_:))))
        return iv
    }()
    
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
        ScrollableCategoryView.scrollableView.layer.cornerRadius = 20
        
    }
    
    
    
    //MARK: - Actions
    
    @objc func leftBackImageTapped(_ gesture: UITapGestureRecognizer) {
        resultView.isHidden = true
        scrollablePlacesView.isHidden = false
        leftBackImageView.isHidden = true
        
    }
    
    @objc func rightCancelImageTapped(_ gesture: UITapGestureRecognizer) {
        rightCancelImageView.isHidden = true
        ScrollableCategoryView.isHidden = false
        scrollablePlacesView.isHidden = true
        
        searchTF.isHidden = false
        
        resetMarkers()
    }
    
    @objc func leftButtonTapped(_ sender: UITapGestureRecognizer) {
        
        naverMap.isHidden = false
        leftImageView.image = UIImage(systemName: "map.circle")
        searchTF.rightViewMode = .whileEditing
        mytableView.isHidden = true
        searchTF.endEditing(true)
        searchTF.text = ""
        isSearhcing = false
        ScrollableCategoryView.isHidden = false
        
    }
    
    @objc func rightButtonTapped(_ sender: UITapGestureRecognizer) {
        if mytableView.isHidden == true {
            
            leftImageView.image = UIImage(systemName: "map.circle")
            ScrollableCategoryView.isHidden = false
        }
        
        
        isSearhcing = false
        searchTF.text = ""
        
    }
    
    
    //MARK: - Helpers
    
    private func resetMarkers() {
        guard !markers.isEmpty else { return }
        
        markers.forEach { marker in
            marker.mapView = nil
            
            self.markers = []
            
        }
    }
    
    func hideTextFieldAndShowCancelButton() {
        searchTF.isHidden = true
        ScrollableCategoryView.isHidden = true
        scrollablePlacesView.isHidden = false
        rightCancelImageView.isHidden = false
    }
    
    func fetchplaces(with category: Category, completion: @escaping ([FetchedPlace]) -> Void) {
        FavoriteSerivce.shared.fetchFavorite(category: category) { result in
            switch result {
            case .failure(let error):
                print(error)
                completion([])
            case .success(let places):
                completion(places)
            }
        }
    }
    
    func makeMarkers(with places: [FetchedPlace]) {
        guard !places.isEmpty else { return }
        
        for place in places {
            
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
                        
                        self.resultView.fetchedPlace = place
                        self.resultView.setLabels(distance: NSNumber(floatLiteral: distance!))
                        self.resultView.isHidden = false
                        self.scrollablePlacesView.isHidden = true
                        self.leftBackImageView.isHidden = false
                        
                    }
                }
                return true
            }
        }
        
        
        let categoryLatAndLone: [NMGLatLng] = markers.compactMap({ $0.position})
        
        let bounds = NMGLatLngBounds(latLngs: categoryLatAndLone)
        
        let cameraUpdate = NMFCameraUpdate(fit: bounds, paddingInsets: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100))
        
        self.naverMap.moveCamera(cameraUpdate)
        
    }
    
    private func placeTapped() {
        searchTF.endEditing(true)
        mytableView.isHidden = true
        naverMap.isHidden = false
        searchTF.rightViewMode = .always
        ScrollableCategoryView.isHidden = true
        resetMarkers()
        
    }
    
    private func moveCamera() {
        
        print("Moving Camera ka")
        if let location = locationManager.location {
            
            let naverLatLon = NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
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
        configureCategoryScrollableView()
        
        configureResultView()
        configureScrollablePlacesView()
        configureRightCancelImageView()
        configureLeftBackImageView()
        
    }
    
    private func configureMap() {
        view.addSubview(naverMap)
        naverMap.frame = view.bounds
    }
    
    private func configureTextField() {
        
        view.addSubview(searchTF)
        view.bringSubviewToFront(searchTF)
        searchTF.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview().inset(padding)
            make.height.equalTo(40)
        }
        
        leftImageView.snp.makeConstraints { make in
            make.width.height.equalTo(25)
        }
        
        searchTF.leftView = leftImageView
        searchTF.leftViewMode = .always
        searchTF.leftView?.isUserInteractionEnabled = true
        leftImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(leftButtonTapped(_:))))
        
        rightImageView.snp.makeConstraints { make in
            make.width.height.equalTo(25)
        }
        
        searchTF.rightView = rightImageView
        searchTF.rightViewMode = .whileEditing
        searchTF.rightView?.isUserInteractionEnabled = true
        searchTF.rightView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rightButtonTapped(_:))))
    }
    
    private func configureTableView() {
        view.addSubview(mytableView)
        mytableView.snp.makeConstraints { make in
            make.top.equalTo(searchTF.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    private func configureResultView() {
        view.addSubview(resultView)
        resultView.translatesAutoresizingMaskIntoConstraints = false
        resultView.delegate = self
        resultView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(122)
        }
    }
    
    private func configureCategoryScrollableView() {
        view.addSubview(ScrollableCategoryView)
        ScrollableCategoryView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let myTabBarController = TabBarVC(mapVC: self, scrollableView: ScrollableCategoryView)
        addChild(myTabBarController)
        myTabBarController.didMove(toParent: self)
        
        myTabBarController.view.frame = ScrollableCategoryView.containerForTableView.frame
        
        ScrollableCategoryView.containerForTableView.addSubview(myTabBarController.view)
    }
    
    private func configureScrollablePlacesView() {
        view.addSubview(scrollablePlacesView)
        scrollablePlacesView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let vc = ScrollFavPlaceVC(scrollableView: scrollablePlacesView)
        vc.delegate = self
        addChild(vc)
        didMove(toParent: self)
        scrollablePlacesView.containerForTableView.addSubview(vc.view)
    }
    
    private func configureRightCancelImageView() {
        view.addSubview(rightCancelImageView)
        rightCancelImageView.snp.makeConstraints { make in
            make.centerY.equalTo(searchTF.snp.centerY)
            make.trailing.equalToSuperview().inset(10)
            make.width.height.equalTo(30)
        }
    }
    
    private func configureLeftBackImageView() {
        view.addSubview(leftBackImageView)
        
        leftBackImageView.snp.makeConstraints { make in
            make.centerY.equalTo(searchTF.snp.centerY)
            make.leading.equalToSuperview().inset(10)
            make.height.width.equalTo(30)
        }
    }
    
}

//MARK: - UITextFieldDelegate

extension MapVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        leftImageView.image = UIImage(systemName: "chevron.backward")
        mytableView.isHidden = false
        naverMap.isHidden = true
        ScrollableCategoryView.isHidden = true
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
                self.resultView.fetchedPlace = place
                self.resultView.setLabels(distance: distance)
                
                
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
        vc.delegate = self
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

extension MapVC: ScrollCategoryVCDelegate {
    func categoryTapped(sender: ScrollCategoryVC, category: Category) {
        fetchplaces(with: category) { places in
            self.makeMarkers(with: places)
        }
        
        hideTextFieldAndShowCancelButton()
    }
}

extension MapVC: CategoryVCDelegate {
    func saveButtonTapped(sender: CategoryVC) {
        resultView.fetchedPlace = fetchedPlace
        
    }
}

extension MapVC: ScrollFavPlaceVCDelegate {
    func tbPlaceTapped(_ sender: ScrollFavPlaceVC, place: FetchedPlace) {
        let location = NMGLatLng(lat: place.lat, lng: place.lon)
        let cameraUpdate = NMFCameraUpdate(scrollTo: location)
        cameraUpdate.animation = .easeOut
        
        naverMap.moveCamera(cameraUpdate)
        scrollablePlacesView.currentPosition = .bottom
    }
}






