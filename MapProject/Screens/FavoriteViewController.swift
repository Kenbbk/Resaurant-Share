//
//  FavoriteView.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/06/17.
//

import UIKit

class FavoriteViewController: UIViewController {
    
    
    
    //MARK: - Properties
    
    private lazy var currentSelected = FavoriteTableView.indexPathsForSelectedRows {
        didSet {
            changeSaveButtonUIAccordingly()
        }
    }
    
    private var fetchedPlace: FetchedPlace
    
    private var initialSelection: Set<Category> = []
    
    private var finishedSelection: Set<Category> = []
    var categories: [Category] = [] {
        didSet {
            DispatchQueue.main.async {
//                self.FavoriteTableView.reloadData()
                print("Tableview reloaded")
            }
        }
    }
    let containerView: UIView = {
        let myView = UIView()
        myView.backgroundColor = .white
        myView.layer.cornerRadius = 20
        return myView
    }()
    
    private let padding: CGFloat = 15
    
    private let topContainerView = UIView()
    
    private lazy var topLeftImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "mappin")
        iv.clipsToBounds = true
        return iv
    }()
    
    private let topLabel: UILabel = {
        let label = UILabel()
        label.text = "양산물금이지더원2차그랜드"
        return label
    }()
    
    private lazy var topRightImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "x.circle")
        iv.isUserInteractionEnabled = true
        iv.tintColor = .systemGray
        iv.clipsToBounds = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rightImageViewTapped(_:))))
        return iv
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGray4
        button.setTitle("Save", for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    private let bottomContainerView: UIView = {
        let myView = UIView()
        myView.backgroundColor = .white
        myView.layer.borderWidth = 0.17
        myView.layer.borderColor = UIColor.systemGray4.cgColor
        
        return myView
    }()
    
    lazy var FavoriteTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CreateCell.self, forCellReuseIdentifier: CreateCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelection = true
        return tableView
    }()
    
    private lazy var outsideGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tappedOutside(_:)))
        
        return gesture
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCategoriesAndInitalCategories()
        setTitleLabel()
        configureUI()
        addGesutreonView()

        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        markSelectedRow()
    }
    
    
    
    init(with place: FetchedPlace) {
        self.fetchedPlace = place
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.1) {
            self.view.backgroundColor = .systemGray.withAlphaComponent(0.55)
        }
        
    }
    
    
    //MARK: - Actions
    
    @objc private func buttonTapped() {
        let group = DispatchGroup()
        if let selectedIndexPath = FavoriteTableView.indexPathsForSelectedRows {
            for indexpath in selectedIndexPath {
                let category = categories[indexpath.row - 1]
                finishedSelection.insert(category)
            }
            
            group.enter()
            self.removeCategories {
                group.leave()
            }

            group.enter()
            addCategories {
                group.leave()
            }
        } else {
            if initialSelection.isEmpty {
                
                return
            } else {
                group.enter()
                removeCategories {
                    group.leave()
                }
                
            }
        }
        
        guard let vc = presentingViewController as? ViewController else { return }
        group.notify(queue: .main) {
            
            
            vc.resultView.changelayOut()
            print("Changelayout")
            
        }
        view.backgroundColor = .clear
        dismiss(animated: true)
        
        
        
    }
    
    @objc private func rightImageViewTapped(_ gesture: UITapGestureRecognizer) {
        
        view.backgroundColor = .clear
        dismiss(animated: true)
    }
    
    @objc private func tappedOutside(_ gesture: UITapGestureRecognizer) {
        view.backgroundColor = .clear
        dismiss(animated: true)
    }
    //MARK: - Helpers
    
    func setCategoriesAndInitalCategories() {
        
        
        categories = UserInfo.shared.categories
        initialSelection = Set(UserInfo.shared.addedCategories)
        print("Categories reset")
        
    }
    
    func setCategoriesAndInitalCategoriesThenReload() {
        
        
        categories = UserInfo.shared.categories
//        initialSelection = Set(UserInfo.shared.addedCategories)
        print("Categories reset")
        FavoriteTableView.reloadData()
        
        markSelectedRow()
    }
    
    private func changeSaveButtonUIAccordingly() {
        switch initialSelection.isEmpty {
        case true:
            saveButton.backgroundColor = currentSelected == nil ? .systemGray4 : .blue
            
        case false:
            let buttonTitle = currentSelected == nil ? "Delete" : "Save"
            saveButton.backgroundColor = .blue
            saveButton.setTitle(buttonTitle, for: .normal)
        }
        
    }
    
    private func removeCategories(completion: (() -> Void)? = nil) {
        
        let shouldRemoved = initialSelection.subtracting(finishedSelection)
        let group = DispatchGroup()
        for category in shouldRemoved {
            group.enter()
            FavoriteSerivce.deleteFavorite(category: category, place: fetchedPlace) {
                defer { group.leave() }
                UserInfo.shared.addedCategories.removeAll(where: { $0.categoryUID == category.categoryUID})
                print("Removed Category done")
                
            }
        }
        group.notify(queue: .main) {
            completion?()
        }
    }
    
    private func addCategories(completion: (() -> Void)? = nil ) {
        let shouldAdded = finishedSelection.subtracting(initialSelection)
        print(shouldAdded)
        print(fetchedPlace.title)
        let group = DispatchGroup()
        
        for item in shouldAdded {
            group.enter()
            FavoriteSerivce.addFavorite(category: item, place: fetchedPlace) {
                defer { group.leave() }
                UserInfo.shared.addedCategories.append(item)
//                print("Category is \(item.title)")
                print("Adding Category Done")
                
                print(UserInfo.shared.addedCategories.contains(item))
                
            }
        }
        group.notify(queue: .main) {
            completion?()
        }
    }
    
    private func setTitleLabel() {
        topLabel.text = fetchedPlace.title
    }
    
    func markSelectedRow() {
        
        for category in UserInfo.shared.addedCategories {
            if let index = self.categories.firstIndex(where: { $0.categoryUID == category.categoryUID}) {
                self.FavoriteTableView.selectRow(at: IndexPath(row: index + 1, section: 0), animated: true, scrollPosition: .none)
                print("low highlighted")
                self.currentSelected = self.FavoriteTableView.indexPathsForSelectedRows
                
            }
        }
    }
    
    
    
    
    
    
    
    func fetchCategories() {
        
        FavoriteSerivce.fetchCategory { categories in
            self.categories = categories.sorted(by: { $0.timeStamp.dateValue() > $1.timeStamp.dateValue()})
            
            for category in categories {
                guard let categoryUID = category.categoryUID else { return }
                let query = COLLECTION_USERS.document(FavoriteSerivce.uid!).collection("categories").document(categoryUID).collection("places").whereField("title", isEqualTo: self.fetchedPlace.title)
                
                query.getDocuments { snapshot, error in
                    guard let document = snapshot?.documents else { return }
                    
                    if document.isEmpty == false {
                        self.initialSelection.insert(category)
                        if let index = self.categories.firstIndex(where: { $0.categoryUID == category.categoryUID}) {
                            self.FavoriteTableView.selectRow(at: IndexPath(row: index + 1, section: 0), animated: true, scrollPosition: .none)
                            
                            self.currentSelected = self.FavoriteTableView.indexPathsForSelectedRows
                        }
                    }
                }
            }
        }
    }
        
        private func addGesutreonView() {
            view.addGestureRecognizer(outsideGesture)
            outsideGesture.delegate = self
        }
        
        private func configureUI() {
            configureContainerView()
            configureTopContainerView()
            configureBottomContainerView()
            configureTableView()
        }
        
        private func configureContainerView() {
            view.addSubview(containerView)
            containerView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                containerView.heightAnchor.constraint(equalToConstant: 700)
                
            ])
        }
        
        private func configureBottomContainerView() {
            containerView.addSubview(bottomContainerView)
            bottomContainerView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                bottomContainerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                bottomContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                bottomContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                bottomContainerView.heightAnchor.constraint(equalToConstant: 80)
            ])
            bottomContainerView.addSubview(saveButton)
            saveButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                saveButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
                saveButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
                saveButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
                saveButton.heightAnchor.constraint(equalToConstant: 50)
            ])
            
        }
        
        private func configureTableView() {
            containerView.addSubview(FavoriteTableView)
            FavoriteTableView.rowHeight = 50
            FavoriteTableView.register(FavoriteCell.self, forCellReuseIdentifier: FavoriteCell.identifier)
            FavoriteTableView.dataSource = self
            FavoriteTableView.delegate = self
            FavoriteTableView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                FavoriteTableView.topAnchor.constraint(equalTo: topContainerView.bottomAnchor),
                FavoriteTableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                FavoriteTableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                FavoriteTableView.bottomAnchor.constraint(equalTo: bottomContainerView.topAnchor)
            ])
        }
        
        private func configureTopContainerView() {
            
            let height: CGFloat = 20
            containerView.addSubview(topContainerView)
            topContainerView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                topContainerView.topAnchor.constraint(equalTo: containerView.topAnchor),
                topContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
                topContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
                topContainerView.heightAnchor.constraint(equalToConstant: 60)
            ])
            
            topContainerView.addSubview(topLeftImageView)
            topLeftImageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                topLeftImageView.centerYAnchor.constraint(equalTo: topContainerView.centerYAnchor),
                topLeftImageView.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor, constant: 20),
                topLeftImageView.widthAnchor.constraint(equalToConstant: 20),
                topLeftImageView.heightAnchor.constraint(equalToConstant: height)
            ])
            
            topContainerView.addSubview(topRightImageView)
            topRightImageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                topRightImageView.centerYAnchor.constraint(equalTo: topContainerView.centerYAnchor),
                topRightImageView.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor, constant: -5),
                topRightImageView.heightAnchor.constraint(equalToConstant: height),
                topRightImageView.widthAnchor.constraint(equalToConstant: 20)
            ])
            
            topContainerView.addSubview(topLabel)
            
            topLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                topLabel.centerYAnchor.constraint(equalTo: topContainerView.centerYAnchor),
                topLabel.leadingAnchor.constraint(equalTo: topLeftImageView.leadingAnchor, constant: 25),
                topLabel.heightAnchor.constraint(equalToConstant: height),
                topLabel.trailingAnchor.constraint(equalTo: topRightImageView.leadingAnchor, constant: -10)
            ])
        }
    }
    
    //MARK: - UITableViewDataSource
    extension FavoriteViewController: UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return categories.count + 1
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: CreateCell.identifier, for: indexPath) as! CreateCell
                return cell
                
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteCell.identifier, for: indexPath) as! FavoriteCell
                cell.setOtherIndexPathLabel(with: categories[indexPath.row - 1])
                return cell
            }
        }
    }
    
    //MARK: - UITableViewDelegate
    
    extension FavoriteViewController: UITableViewDelegate {
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
            
            if indexPath.row == 0 {
                let VC = AddNameViewController()
                VC.modalPresentationStyle = .overFullScreen
                tableView.deselectRow(at: indexPath, animated: true)
                present(VC, animated: true)
            }
            
            currentSelected = FavoriteTableView.indexPathsForSelectedRows
        }
        
        func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
            currentSelected = FavoriteTableView.indexPathsForSelectedRows
        }
    }
    
    //MARK: - UIGestureRecognizerDelegate
    
    extension FavoriteViewController: UIGestureRecognizerDelegate {
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            if gestureRecognizer == outsideGesture {
                let location = gestureRecognizer.location(in: view)
                if containerView.frame.contains(location) {
                    
                    return false
                }
            }
            return true
        }
    }
    
