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

enum ScrollViewPosition: CGFloat {
    //    case bottom = 0.87
    case bottom = 0.90
    case middle = 0.55
    case top = 0.085
    
}

class ViewController: UIViewController {
    
    //MARK: - Properties
    var selectedItem: Place!
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
    
    private lazy var resultView: CustomResultView = {
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
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        let user = Auth.auth().currentUser!
        
        containerView.isHidden = true
        FavoriteSerivce.fetchFavorite(category: "category") { places in
            for place in places {
                print(place)
                let lat = place.lat
                let lon = place.lon
                let marker = NMFMarker(position: NMGLatLng(lat: lat, lng: lon))
                marker.captionText = place.title
                marker.mapView = self.naverMap
            }
        }
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        topConstraint.constant = getHeight(position: startingPosition)
        let VC = AddNameViewController()
        VC.modalPresentationStyle = .overFullScreen
        present(VC, animated: true)
        
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
    
    //MARK: - UI
    
    private func configureUI() {
        view.backgroundColor = .white
        configureMap()
        configureTextField()
        configureTableView()
        configureContainerView()
        configureResultView()
        configureFavoriteView()
       
        
//        naverMap.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapInsde(_:))))
    }
    
//    @objc func tapInsde(_ gesture: UITapGestureRecognizer) {
//        let location = gesture.location(in: self.view)
//        if favoriteView.bounds.contains(location) == true {
//            print("It is inside")
//        } else {
//            print("It is ouside")
//        }
//
//    }
    
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
            return }
        isSearhcing = true
        
        NetworkManager.shared.getSearchResult(query: text) { places in
            guard let places else { return }
            print(places)
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
        selectedItem = searchResult[indexPath.row]
        let originalText = self.searchResult[indexPath.row].title
        let editedText = self.converHTMLString(with: originalText, targetString: "")
        resultView.fillInTheText(title: editedText.string, address: selectedItem.address, distance: 50)
        resultView.isHidden = false
        let address = searchResult[indexPath.row].roadAddress
        NetworkManager.shared.getLatLon(with: address) { address in
            guard let address else { return }
            let LatLon = NMGLatLng(lat: Double(address.y)! , lng: Double(address.x)!)
            
            let cameraUpdate = NMFCameraUpdate(scrollTo: LatLon)
            
            DispatchQueue.main.async {
                self.marker.position = LatLon
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
        print("Favorite image Tapped")
        let vc = FavoriteViewController()
        vc.modalPresentationStyle = .overFullScreen
        
        present(vc, animated: true)
        guard let currentUser = Auth.auth().currentUser else { return }
        let uid = currentUser.uid
        let convertedString = converHTMLString(with: selectedItem.title, targetString: "").string
        let address = selectedItem.address
        let user = User(email: currentUser.email!, uid: uid, nickname: "Leo")
        
        COLLECTION_USERS.document(uid).setData([
            "email": user.email, "uid": uid, "nickname": user.nickname
        ])
        FavoriteSerivce.uploadFavorite(title: convertedString, address: address, lat: self.marker.position.lat, lon: self.marker.position.lng)
        

        
    }
    
    
}


