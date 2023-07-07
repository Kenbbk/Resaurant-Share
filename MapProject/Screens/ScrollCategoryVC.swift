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
//        tb.addGestureRecognizer(tableViewGestureRecognizer)
        return tb
    }()
    
    var tableViewGestureRecognizer: UIPanGestureRecognizer!
    
    private lazy var mapVC: MapVC = {
        let vc = self.getTopHierarchyViewController() as! MapVC
        return vc
    }()

        
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchcategories()
        configureUI()
        createObserver()
        navigationController?.isNavigationBarHidden = true
       
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("View did apeear")
        if tableViewGestureRecognizer != nil { return }
        tableViewGestureRecognizer = UIPanGestureRecognizer(target: mapVC, action: #selector(mapVC.bottomViewBeenScrolled(_:)))
        placeTableView.addGestureRecognizer(tableViewGestureRecognizer)
                tableViewGestureRecognizer.delegate = self

    }
    
    
    //MARK: - Actions
    
    @objc func tableViewDragged(_ sender: UIPanGestureRecognizer) {

    }
    
    @objc func categoryChanged() {
        print("DEBUG: user.info's category changed yay!")
        placeTableView.reloadData()
    }
    
    //MARK: - Helpers
    
   
    
    private func fetchcategories() {
        FavoriteSerivce.shared.fetchCategory { categories in
            
            for category in categories {
                FavoriteSerivce.shared.fetchFavorite(category: category) { result in
                    switch result {
                    case .failure(let error):
                        print(error)
                    case.success(let fetchedPlaces):
                        
                        var newCategory = category
                        newCategory.addedPlaces = fetchedPlaces
                        UserInfo.shared.categories.append(newCategory)
                        
                    }
                }
            }
            
            print("debug UserInfo.shared.categories has been set")
        }
    }
    
    
    private func createObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(categoryChanged), name: Notification.Name(UserInfo.shared.categoryChangedIdentifier), object: nil)
        
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
            
            mapVC.topConstraint.constant = mapVC.getHeight(position: .bottom)
            mapVC.currentHeight = mapVC.getHeight(position: .bottom)
            mapVC.currentPosition = .bottom
            mapVC.makeMarker(with: selectedCategory)
            mapVC.hideTextFieldAndShowCancelButton()
            
            

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
//            let gesture =  gestureRecognizer as! UIPanGestureRecognizer
            
            let translation = (gestureRecognizer as! UIPanGestureRecognizer).translation(in: placeTableView)
            let parentVC = self.getTopHierarchyViewController() as! MapVC
            // check if it is at top postion
            
            if parentVC.currentPosition == .top {
                print(parentVC.currentPosition)
                if placeTableView.contentOffset.y > 0 {
                    print(translation.y)
                    print("TableView should scroll")
                    return false
                } else {
                    if translation.y < 0 {
                        print(translation.y)
                        
                        print("TableView should scrool-----")
                        print("It is returning false")
                        return false
                    } else {
                        print(translation.y)
                        print("We should notify to parent Vc to adjust its size")
                        return true
                    }
                }
                
            } else {
                print("Container View is not at the top postion")
                print("of course notify")
                return true
            }
            
        }
        
        return true


    }
}
