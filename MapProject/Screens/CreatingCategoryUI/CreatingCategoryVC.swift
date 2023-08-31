//
//  AddNameViewController.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/06/18.
//

import UIKit
import FirebaseFirestore
import SnapKit

protocol CreatingCategoryVCDelegate: AnyObject {
    func saveButtonTapped()
}

class CreatingCategoryVC: UIViewController {
    
    //MARK: - Properties
    
    private let colors = CustomColor.colors
    
    weak var delegate: CreatingCategoryVCDelegate?
    
    var rootView: CreatingCategoryVCMainView {
        return view as! CreatingCategoryVCMainView
    }
    private var collectionVC: UICollectionViewController!
    
    //MARK: - Lifecycle
    override func loadView() {
        view = CreatingCategoryVCMainView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectMainView()
        connectCollectionVC()
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    private func connectMainView() {
        rootView.delegate = self
    }
    
    private func connectCollectionVC() {
        collectionVC = CreatingCategoryCollectionVC(collectionViewLayout: UICollectionViewLayout())
        add(collectionVC, to: rootView.collectionContainer)
        
    }
    
    //MARK: - Actions
    
    //MARK: - Helpers
    
    private func addCategory(category: Category) async {
        do {
            try await CategoryService.shared.addCategory(with: category)
            print("AddCategory finished")
        } catch {
            print(error)
        }
    }
}

extension CreatingCategoryVC: CreatingCategoryVCMainViewDelegate  {
    func dismissTapped() {
        dismiss(animated: true)
    }
    
    func saveButtonTapped() {
        guard let categoryTitle = rootView.nameTextField.text else { return }
        guard let colorNumber = collectionVC.collectionView.indexPathsForSelectedItems?.first?.row else { return }
        
        let description = rootView.descriptionTextField.text!
        let timeStamp = Timestamp(date: Date())
        
        let category = Category(title: categoryTitle, colorNumber: colorNumber, description: description, timeStamp: timeStamp)
        
        Task {
            await addCategory(category: category)
            print("Save button Tapped")
            delegate?.saveButtonTapped()
        }
        
       
        
//        dismiss(animated: true)
//        
        
    }
}















