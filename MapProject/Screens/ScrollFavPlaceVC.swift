//
//  experimentVC.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/07/07.
//

import UIKit
import SnapKit
import GooglePlaces

protocol ScrollFavPlaceVCDelegate: AnyObject {
    func tbPlaceTapped(_ sender: ScrollFavPlaceVC, place: FetchedPlace)
}

class ScrollFavPlaceVC: UIViewController {
    
    
    //MARK: - Properties
    lazy var myTableView: UITableView = {
        let tb = UITableView()
        tb.dataSource = self
        tb.delegate = self
        tb.register(FavPlaceCell.self, forCellReuseIdentifier: FavPlaceCell.identifier)
        tb.rowHeight = 190
        
        return tb
    }()
    
    weak var delegate: ScrollFavPlaceVCDelegate?
    
    var category: Category?
    
    var addedPlaces: [FetchedPlace] = []
    
    var tablePanGesutre: UIPanGestureRecognizer!
    
    var scrollableView: PlaceScrollableView!
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        addGestureToTableView()
        createObserver()
    }
    
    
    
    convenience init(scrollableView: PlaceScrollableView) {
        self.init(nibName: nil, bundle: nil)
        self.scrollableView = scrollableView
    }
    
    //MARK: - Actions
    
    @objc func selectedRowinScrollableCategoryVC(_ notification: Notification) {
        
        guard let category = notification.object as? Category else { return }
        self.category = category
        Task {
            do {
                let places = try await fetchAddedPlace()
                resolvePlaces(with: places)
            } catch {
                print(error)
            }
            
        }
       
    }
    
    //MARK: - Helpers
    
    func fetchAddedPlace() async throws -> [FetchedPlace] {
        guard let category else { throw FBError.noCategory }
        
        return try await FavoriteSerivce.shared.fetchFavoritePlaces(from: category)
        
    }
    
//    func fetchAddedPlace(completion: @escaping ([FetchedPlace]?) -> Void) {
//        guard let category else { return }
//        FavoriteSerivce.shared.fetchFavorite(category: category) { result in
//            switch result {
//            case .failure(let error):
//                print(error)
//                completion(nil)
//            case .success(let places):
//
//                completion(places)
//            }
//        }
//    }
    
    func resolvePlaces(with places: [FetchedPlace]) {
        var tempFetchedplaces: [FetchedPlace] = []
        let group = DispatchGroup()
        for place in places {
            group.enter()
            GooglePlacesManager.shared.resolveLocation(with: place.placeID) { result in
                defer {
                    group.leave()
                }
                switch result {
                case .failure(let error):
                    
                    print(error)
                    
                case .success(let place):
                    tempFetchedplaces.append(place)
                    
                }
            }
        }
        group.notify(queue: .main) {
            self.addedPlaces = tempFetchedplaces
            
            self.myTableView.reloadData()
        }
    }
    
    private func createObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(selectedRowinScrollableCategoryVC(_:)), name: Notification.Name.selectedRowinScrollableCategoryVC, object: nil )
        
    }
    
    private func configureTableView() {
        view.addSubview(myTableView)
        
        myTableView.frame = CGRect(x: 0, y: 0, width: Int(view.frame.size.width), height: Int(view.frame.size.height - 200))
        
    }
    
    private func addGestureToTableView() {
        tablePanGesutre = UIPanGestureRecognizer(target: scrollableView, action: #selector(scrollableView.viewTapped(_:)))
        tablePanGesutre.delegate = self
        myTableView.addGestureRecognizer(tablePanGesutre)
    }
}

extension ScrollFavPlaceVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addedPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: FavPlaceCell.identifier, for: indexPath) as! FavPlaceCell
        
        let place = addedPlaces[indexPath.row]
        
        cell.place = place
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Place tapped")
        delegate?.tbPlaceTapped(self, place: addedPlaces[indexPath.row])
        
    }
}

extension ScrollFavPlaceVC: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == tablePanGesutre {
            
            let translation = (gestureRecognizer as! UIPanGestureRecognizer).translation(in: view)
            
            if scrollableView.currentPosition == .top {
                
                if myTableView.contentOffset.y > 0 {
                    
                    return false
                    
                } else {
                    
                    return translation.y > 0
                }
                
            } else {
                
                return true
            }
        }
        
        return true
    }
}


    

