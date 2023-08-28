//
//  FavoriteView.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/06/17.
//

import UIKit
import SnapKit

protocol CategoryVCDelegate: AnyObject {
    func saveButtonTapped(sender: CategoryVC)
}

class CategoryVC: UIViewController {
    
    
    //MARK: - Properties
    
    private let padding: CGFloat = 15
    
    private lazy var currentSelected = myTableView.indexPathsForSelectedRows {
        didSet {
            ModifySaveButtonUIAccordingly()
        }
    }
    
    private var favoritedCategories: [Category] = []
    
    private var fetchedPlace: FetchedPlace
    
    private var initialSelection: Set<Category> = []
    
    private var finishedSelection: Set<Category> = []
    
    var categories: [Category] = []
    
    weak var delegate: CategoryVCDelegate?
    
    let containerView: UIView = {
        let myView = UIView()
        myView.backgroundColor = .white
        myView.layer.cornerRadius = 20
        return myView
    }()
    
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
    
    lazy var myTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CreateCell.self, forCellReuseIdentifier: CreateCell.identifier)
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 50
        tableView.allowsMultipleSelection = true
        return tableView
    }()
    
    private lazy var outsideGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tappedOutside(_:)))
        
        return gesture
    }()
    
    //MARK: - Lifecycle
    
    override func loadView() {
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitleLabel()
        configureUI()
        addGesutreonView()
        
        Task {
            await fetchCategoriesThenFetchFavoritedCategory()
            myTableView.reloadData()
            
            setInitialCategories()
            HighlightAddedCategories()
        }
        
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
    
    @objc private func buttonTapped() async {
        
        let group = DispatchGroup()
        do {
            if let selectedIndexPath = myTableView.indexPathsForSelectedRows {
                
                selectedIndexPath.forEach({
                    let category = categories[$0.row - 1]
                    finishedSelection.insert(category)
                })
                
                try await removeFromCategories()
                try await addToCategories()
                
                
            } else {
                
                guard initialSelection.isEmpty == false else { return }
                
                try await removeFromCategories()
                
            }
            
            self.view.backgroundColor = .clear
            self.dismiss(animated: true)
            self.delegate?.saveButtonTapped(sender: self)
            
         
        } catch {
            print(error)
        }
        
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
    
    private func fetchCategoriesThenFetchFavoritedCategory() async {
        do {
            try await fetchCategories()
            try await fetchFavoritedCategories()
        } catch {
            print(error)
            
        }
        
    }
    
    private func fetchCategories() async throws {
        let categories = try await CategoryService.shared.fetchCategories()
        self.categories = categories
        //        return categories
        
    }
    
    
    //    private func fetchCategories(completion: @escaping () -> Void) {
    //        FavoriteSerivce.shared.fetchCategories { categories in
    //            self.categories = categories
    //            completion()
    //        }
    //    }
    
    private func fetchFavoritedCategories() async throws {
        let favoritedCategories = try await CategoryService.shared.getFavoritedCategories(categories: categories, place: fetchedPlace)
        
        self.favoritedCategories = favoritedCategories
        
    }
    
    //    private func fetchFavoritedCategories(completion: @escaping () -> Void) {
    //        FavoriteSerivce.shared.getFavoritedCategories(categories: categories, place: fetchedPlace) { result in
    //            defer {
    //                completion()
    //
    //            }
    //            switch result {
    //
    //            case .failure(let error):
    //                print(error)
    //            case .success(let categories):
    //                self.favoritedCategories = categories
    //            }
    //        }
    //    }
    
    func setInitialCategories() {
        
        initialSelection = Set(favoritedCategories)
    }
    
    private func ModifySaveButtonUIAccordingly() {
        switch initialSelection.isEmpty {
        case true:
            saveButton.backgroundColor = currentSelected == nil ? .systemGray4 : .blue
            
        case false:
            let buttonTitle = currentSelected == nil ? "Delete" : "Save"
            saveButton.backgroundColor = .blue
            saveButton.setTitle(buttonTitle, for: .normal)
        }
    }
    
    private func removeFromCategories() async throws {
        
        let shouldRemoved = Array(initialSelection.subtracting(finishedSelection))
        
        let group = DispatchGroup()
        
        try await FavoriteSerivce.shared.deleteFavorite(categories: shouldRemoved, place: fetchedPlace)
    }
    
    //    private func removeFromCategories(completion: @escaping (() -> Void)) {
    //
    //        let shouldRemoved = initialSelection.subtracting(finishedSelection)
    //
    //        let group = DispatchGroup()
    //
    //        for category in shouldRemoved {
    //            group.enter()
    //
    //            FavoriteSerivce.shared.deleteFavorite(category: category, place: fetchedPlace) {
    //                group.leave()
    //            }
    //        }
    //
    //        group.notify(queue: .main) {
    //            completion()
    //        }
    //    }
    
    private func addToCategories() async throws {
        let shouldAdded = Array(finishedSelection.subtracting(initialSelection))
        
        let group = DispatchGroup()
        
        try await FavoriteSerivce.shared.deleteFavorite(categories: shouldAdded, place: fetchedPlace)
        
    }
    
    private func setTitleLabel() {
        topLabel.text = fetchedPlace.name
    }
    
    func HighlightAddedCategories() {
        
        for category in favoritedCategories {
            print("-------------------------- \(favoritedCategories)")
            if let index = self.categories.firstIndex(where: { $0.categoryUID == category.categoryUID}) {
                
                self.myTableView.selectRow(at: IndexPath(row: index + 1, section: 0), animated: true, scrollPosition: .none)
                
                self.currentSelected = self.myTableView.indexPathsForSelectedRows
                
            }
        }
    }
    
    private func addGesutreonView() {
        view.addGestureRecognizer(outsideGesture)
        outsideGesture.delegate = self
    }
    
    
    //MARK: - UI
    
    private func configureUI() {
        configureContainerView()
        configureTopContainerView()
        configureBottomContainerView()
        configureTableView()
    }
    
    private func configureContainerView() {
        view.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(700)
        }
    }
    
    private func configureBottomContainerView() {
        containerView.addSubview(bottomContainerView)
        
        bottomContainerView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(80)
        }
        
        bottomContainerView.addSubview(saveButton)
        
        saveButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(20) //
            make.leading.trailing.equalToSuperview().inset(padding) //
            make.height.equalTo(50)
        }
    }
    
    private func configureTableView() {
        containerView.addSubview(myTableView)
        
        myTableView.snp.makeConstraints { make in
            make.top.equalTo(topContainerView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(bottomContainerView.snp.top)
        }
    }
    
    private func configureTopContainerView() {
        
        let height: CGFloat = 20
        containerView.addSubview(topContainerView)
        
        topContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(padding)
            make.height.equalTo(60)
        }
        
        topContainerView.addSubview(topLeftImageView)
        
        topLeftImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(20)
            make.width.height.equalTo(height)
        }
        
        topContainerView.addSubview(topRightImageView)
        
        topRightImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(5)
            make.width.height.equalTo(height)
        }
        
        topContainerView.addSubview(topLabel)
        
        topLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(topLeftImageView.snp.leading).inset(25)
            make.height.equalTo(height)
            make.trailing.equalTo(topRightImageView.snp.leading).inset(10)
        }
    }
}

//MARK: - UITableViewDataSource
extension CategoryVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CreateCell.identifier, for: indexPath) as! CreateCell
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.identifier, for: indexPath) as! CategoryCell
            cell.setOtherIndexPathLabel(with: categories[indexPath.row - 1])
            
            return cell
        }
    }
}

//MARK: - UITableViewDelegate

extension CategoryVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            let vc = NamingCategoryVC()
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            tableView.deselectRow(at: indexPath, animated: true)
            present(vc, animated: true)
        }
        
        currentSelected = myTableView.indexPathsForSelectedRows
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        currentSelected = myTableView.indexPathsForSelectedRows
    }
}

//MARK: - UIGestureRecognizerDelegate

extension CategoryVC: UIGestureRecognizerDelegate {
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

extension CategoryVC: NamingCategoryVCDelegate {
    func saveButtonTapped(sender: NamingCategoryVC) async {
        await fetchCategoriesThenFetchFavoritedCategory()
        
        self.myTableView.reloadData()
        self.setInitialCategories()
        self.HighlightAddedCategories()
        
        //        fetchCategories {
        //
        //            self.fetchFavoritedCategories {
        //
        //                self.myTableView.reloadData()
        //
        //                self.setInitialCategories()
        //                self.HighlightAddedCategories()
        //            }
        //        }
    }
}
