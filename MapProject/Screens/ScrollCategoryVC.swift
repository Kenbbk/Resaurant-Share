//
//  HomeController.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/06/28.
//

import UIKit
import NMapsMap

class ScrollCategoryVC: UIViewController {
    
    
    //MARK: - Properties
    
    lazy var placeTableView: UITableView = {
        let tb = UITableView(frame: CGRect(x: 0, y: 0, width: Int(view.frame.size.height), height: Int(view.frame.size.height - tabBarController!.tabBar.frame.height)), style: .grouped)
        tb.backgroundColor = .white
        
        tb.dataSource = self
        tb.delegate = self
        tb.register(CreateCell.self, forCellReuseIdentifier: CreateCell.identifier)
        tb.register(BlackTableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: BlackTableViewHeaderFooterView.identifier)
        tb.register(FavoriteStoreageCell.self, forCellReuseIdentifier: FavoriteStoreageCell.identifier)
        
        return tb
    }()
    
    var tableViewGestureRecognizer: UIPanGestureRecognizer!
    
    var mapVC: MapVC!
    
    var ScrollableContainer: RealScrollableView!
    
    var scrollableView: RealScrollableView!
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchcategories()
        configureUI()
        createObserver()
        navigationController?.isNavigationBarHidden = true
        
    }
    
    convenience init(scrollableView: RealScrollableView) {
        self.init(nibName: nil, bundle: nil)
        self.scrollableView = scrollableView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        mapVC = self.getTopHierarchyViewController() as! MapVC
        ScrollableContainer = mapVC.ScrollableCategoryView
        guard tableViewGestureRecognizer == nil else { return }
        
        tableViewGestureRecognizer = UIPanGestureRecognizer(target: ScrollableContainer, action: #selector(ScrollableContainer.viewTapped(_:)))
        tableViewGestureRecognizer.delegate = self
        placeTableView.addGestureRecognizer(tableViewGestureRecognizer)
        
    }
    
    
    
    
    //MARK: - Actions
    
    @objc func categoryChanged() {
        print("DEBUG: user.info's category changed yay!")
        placeTableView.reloadData()
    }
    
    //MARK: - Helpers
    
    
    
    private func fetchcategories() {
        
        var newCategories: [Category] = []
        
        FavoriteSerivce.shared.fetchCategory { categories in
            
            
            let group = DispatchGroup()
            
            for category in categories {
                
                group.enter()
                
                FavoriteSerivce.shared.fetchFavorite(category: category) { result in
                    
                    defer { group.leave() }
                    
                    switch result {
                    case .failure(let error):
                        print(error)
                    case.success(let fetchedPlaces):
                        
                        var newCategory = category
                        newCategory.addedPlaces = fetchedPlaces
                        newCategories.append(newCategory)
                        
                    }
                }
            }
            group.notify(queue: .main) {
                UserInfo.shared.categories = newCategories
            }
            
            print("debug UserInfo.shared.categories has been set")
        }
    }
    
    
    private func createObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(categoryChanged), name: Notification.Name.userInfoCategoriesChanged, object: nil)
        
    }
    
    private func configureUI() {
        configureTB()
    }
    
    private func configureTB() {
        
        view.addSubview(placeTableView)
        placeTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            placeTableView.topAnchor.constraint(equalTo: view.topAnchor),
            placeTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            placeTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            placeTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: tabBarController?.tabBar.frame.size.height ?? 0)
        ])
    }
}

//MARK: - TableView Data Source, TableView Delegate

extension ScrollCategoryVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        UserInfo.shared.categories.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CreateCell.identifier, for: indexPath) as! CreateCell
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteStoreageCell.identifier, for: indexPath) as! FavoriteStoreageCell
        let category = UserInfo.shared.categories[indexPath.row - 1]
        cell.setLabel(colorNumber: category.colorNumber, title: category.title, numberOfPlaces: category.addedPlaces.count)
        
        return cell
        
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let vc = NamingCategoryVC()
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true)
        } else {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            let selectedCategory = UserInfo.shared.categories[indexPath.row - 1]
            
            
            mapVC.makeMarker(with: selectedCategory)
            mapVC.hideTextFieldAndShowCancelButton()
            
            NotificationCenter.default.post(name: NSNotification.Name.selectedRowinScrollableCategoryVC, object: selectedCategory)
            
            
            
            
            
            
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: BlackTableViewHeaderFooterView.identifier) as! BlackTableViewHeaderFooterView
        header.setTextLabel()
        print("------------------------------ debug UserInfo.shared.categories.count has been printed")
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

class BlackTableViewHeaderFooterView : UITableViewHeaderFooterView {
    
    static let identifier = "BlackTableViewHeaderFooterView"
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .white
        
        textLabel?.numberOfLines = 0
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTextLabel() {
        textLabel?.text = UserInfo.shared.categories.isEmpty ? "All lists" : "All lists \(UserInfo.shared.categories.count)"
        textLabel?.font = .boldSystemFont(ofSize: 24)
        textLabel?.textColor = .black
    }
    
}

extension ScrollCategoryVC: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == tableViewGestureRecognizer {
            
            let translation = (gestureRecognizer as! UIPanGestureRecognizer).translation(in: view)
            
            if ScrollableContainer.currentPosition == .top {
                
                if placeTableView.contentOffset.y > 0 {
                    
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

//extension ScrollCategoryVC: UIGestureRecognizerDelegate {
//    
//    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        if gestureRecognizer == tableViewGestureRecognizer {
////            let gesture =  gestureRecognizer as! UIPanGestureRecognizer
//            
//            let translation = (gestureRecognizer as! UIPanGestureRecognizer).translation(in: placeTableView)
//            let parentVC = self.getTopHierarchyViewController() as! MapVC
//            // check if it is at top postion
//            
//            if parentVC.currentPosition == .top {
//                print(parentVC.currentPosition)
//                if placeTableView.contentOffset.y > 0 {
//                    print(translation.y)
//                    print("TableView should scroll")
//                    return false
//                } else {
//                    if translation.y < 0 {
//                        print(translation.y)
//                        
//                        print("TableView should scrool-----")
//                        print("It is returning false")
//                        return false
//                    } else {
//                        print(translation.y)
//                        print("We should notify to parent Vc to adjust its size")
//                        return true
//                    }
//                }
//                
//            } else {
//                print("Container View is not at the top postion")
//                print("of course notify")
//                return true
//            }
//            
//        }
//        
//        return true
//
//
//    }
//}
