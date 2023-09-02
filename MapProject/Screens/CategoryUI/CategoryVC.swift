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
    
    private var selectedIndex: [IndexPath] {
        let selectedIndex = rootView.myTableView.indexPathsForSelectedRows == nil ? [] : rootView.myTableView.indexPathsForSelectedRows!
        return selectedIndex
    }
    
    private var models: [CategoryCellModel] = []
    
    private var favoritedCategories: [Category] = []
    
    private var fetchedPlace: FetchedPlace
    
    private var categories: [Category] = []
    
    weak var delegate: CategoryVCDelegate?
    
    private var rootView: CategoryVCMainView {
        view as! CategoryVCMainView
    }
    
    //MARK: - Lifecycle
    
    override func loadView() {
        view = CategoryVCMainView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitleLabel()
        connectMainView()
        
        Task {
            await fetchCategoriesThenFetchFavoritedCategory()
            makeCellModel()
            await applySnapshot()
            rootView.buttonState = determineButtonState()
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
            self.rootView.backgroundColor = .systemGray.withAlphaComponent(0.55)
        }
    }
    
    //MARK: - Actions
    
    private func connectMainView() {
        rootView.delegate = self
    }
    
    //MARK: - Helpers
    
    private func makeCellModel() {
        models = categories.map {
            return CategoryCellModel(title: $0.title, colorNumber: $0.colorNumber, categoryUID: $0.categoryUID, shouldHighLighted: favoritedCategories.contains($0))
        }
    }
    
    private func applySnapshot() async {
        let dataSource = rootView.dataSource
        var snapshot = NSDiffableDataSourceSnapshot<Section, CategoryCellModel>()
        snapshot.appendSections([.create, .categories])
        snapshot.appendItems([CategoryCellModel(title: "dummy", colorNumber: 0, categoryUID: "dummy", shouldHighLighted: true)], toSection: .create)
        snapshot.appendItems(models, toSection: .categories)
        await dataSource?.apply(snapshot, animatingDifferences: false)
        
    }
    
    private func fetchCategoriesThenFetchFavoritedCategory() async {
        do {
            categories = try await CategoryService.shared.fetchCategories()
            favoritedCategories = try await CategoryService.shared.getFavoritedCategories(categories: categories, place: fetchedPlace)
            print("finished fetching")
        } catch {
            print(error)
        }
    }
    
    private func determineButtonState() -> (title: String, isActive: Bool) {
        
        switch favoritedCategories.isEmpty {
        case true:
            return selectedIndex.isEmpty ? ("Save", false) : ("Save", true)
            
        case false:
            
            return selectedIndex.isEmpty ? ("Save Delete", true) : ("Save", true)
        }
    }
    
    private func updateCategories() async {
        let initialSelection = Set(favoritedCategories)
        let finishedSelection = Set(selectedIndex.map { categories[$0.row]})
        
        let shouldRemoved = Array(initialSelection.subtracting(finishedSelection))
        let shouldAdded = Array(finishedSelection.subtracting(initialSelection))
        
        do {
            try await FavoriteSerivce.shared.addFavorite(the: fetchedPlace, to: shouldAdded)
            try await FavoriteSerivce.shared.deleteFavorite(categories: shouldRemoved, place: fetchedPlace)
        } catch {
            print(error)
        }
    }
    
    private func setTitleLabel() {
        rootView.topLabel.text = fetchedPlace.name
        
    }
}

extension CategoryVC: CreatingCategoryVCDelegate {
    func saveButtonTappedinCreatingCategoryVC() {
        Task {
            print("I will fetch categories")
            await fetchCategoriesThenFetchFavoritedCategory()
            print("makeCellModel")
            makeCellModel()
            await applySnapshot()
        }
    }
}

//MARK: - MainView Delegate

extension CategoryVC: CategoryVCMainViewDelegate {
    func saveButtonTappedInCategoryVC() {
        Task {
            await updateCategories()
        }
        print("why this is called?")
        self.dismiss(animated: true)
        self.delegate?.saveButtonTapped(sender: self)
    }
    
    func cellTapped(indexPath: IndexPath) {
        if indexPath.section == 0 {
            let vc = CreatingCategoryVC()
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            
            present(vc, animated: true)
        }
        print("cell tapped")
        rootView.buttonState = determineButtonState()
        
    }
    
    func cellDeselect() {
        rootView.buttonState = determineButtonState()
    }
    
    func dismissTapped() {
        dismiss(animated: true)
    }

}
