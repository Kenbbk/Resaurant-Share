//
//  HomeController.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/06/28.
//

import UIKit
import NMapsMap

protocol ScrollCategoryVCDelegate: AnyObject {
    func categoryTapped(sender: ScrollCategoryVC, category: Category)
}

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
    
    var categories: [Category] = []
    
    var tableViewGestureRecognizer: UIPanGestureRecognizer!
    
    var mapVC: MapVC!
    
    weak var scrollCategoryVCDelegate: ScrollCategoryVCDelegate?
    
    var scrollableView: CategoryScrollableView!
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchcategories()
        configureUI()
        createObserver()
        navigationController?.isNavigationBarHidden = true
        addGesture()
        
    }
    
    convenience init(mapVC: MapVC ,scrollableView: CategoryScrollableView) {
        self.init(nibName: nil, bundle: nil)
        self.mapVC = mapVC
        self.scrollableView = scrollableView
        
    }
  
    
    //MARK: - Actions
    
    @objc func categoryChanged() {
        print("DEBUG: user.info's category changed yay!")
        placeTableView.reloadData()
    }
    
    //MARK: - Helpers
    
    private func addGesture() {
        tableViewGestureRecognizer = UIPanGestureRecognizer(target: scrollableView, action: #selector(scrollableView.viewTapped(_:)))
        tableViewGestureRecognizer.delegate = self
        placeTableView.addGestureRecognizer(tableViewGestureRecognizer)
    }
    
    private func fetchcategories() {
        
       FavoriteSerivce.shared.fetchCategories { categories in
            
            self.categories = categories
            DispatchQueue.main.async {
                self.placeTableView.reloadData()
            }
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
        categories.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CreateCell.identifier, for: indexPath) as! CreateCell
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteStoreageCell.identifier, for: indexPath) as! FavoriteStoreageCell
        let category = categories[indexPath.row - 1]
        cell.category = category
        
        return cell
        
        }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let vc = NamingCategoryVC()
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true)
        } else {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            let selectedCategory = categories[indexPath.row - 1]
            
            scrollCategoryVCDelegate?.categoryTapped(sender: self, category: selectedCategory)
            
            
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

extension ScrollCategoryVC: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == tableViewGestureRecognizer {
            
            let translation = (gestureRecognizer as! UIPanGestureRecognizer).translation(in: view)
            
            if scrollableView.currentPosition == .top {
                
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

extension ScrollCategoryVC: NamingCategoryVCDelegate {
    func saveButtonTapped(sender: NamingCategoryVC) {
        fetchcategories()
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
