//
//  HomeController.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/06/28.
//

import UIKit

class HomeController: UIViewController {
    
    
    //MARK: - Properties
    
    private lazy var placeTableView: UITableView = {
        let tb = UITableView(frame: .zero, style: .grouped)
        tb.backgroundColor = .white
        tb.dataSource = self
        tb.delegate = self
        tb.register(CreateCell.self, forCellReuseIdentifier: CreateCell.identifier)
        tb.register(BlackTableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: BlackTableViewHeaderFooterView.identifier)
        tb.register(FavoriteStoreageCell.self, forCellReuseIdentifier: FavoriteStoreageCell.identifier)
        return tb
    }()
    
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FavoriteSerivce.fetchCategory { categories in
            UserInfo.shared.categories = categories
            print("------------------------------------- debug UserInfo.shared.categories has been set from sean dealege")
//            let header = self.placeTableView.headerView(forSection: 0) as! BlackTableViewHeaderFooterView
//            header.textLabel?.text = "Hello There"
        }
        configureUI()
        createObserver()
    }
    
    //MARK: - Actions
    
    @objc func categoryChanged() {
        print("DEBUG: user.info's category changed yay!")
        placeTableView.reloadData()
    }
    
   
    
    //MARK: - Helpers
    
    private func createObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(categoryChanged), name: Notification.Name(UserInfo.shared.categoryChangedIdentifier), object: nil)
    }
    
    private func configureUI() {
        configureTB()
    }
    
    private func configureTB() {
        
        view.addSubview(placeTableView)
        placeTableView.frame = view.bounds
    }
}

extension HomeController: UITableViewDataSource, UITableViewDelegate {
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
        cell.setLabel(colorNumber: category.colorNumber, title: category.title, numberOfPlaces: 1)
        
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: BlackTableViewHeaderFooterView.identifier) as! BlackTableViewHeaderFooterView
        header.textLabel?.text = "All lists \(UserInfo.shared.categories.count)"
        print("------------------------------ debug UserInfo.shared.categories.count has been printed")
        header.textLabel?.font = .boldSystemFont(ofSize: 24)
        header.textLabel?.textColor = .black
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
    
    private var numberOfCategories: Int?
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        contentView.backgroundColor = .white

        textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        textLabel?.numberOfLines = 0
        textLabel?.textColor = .white
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
