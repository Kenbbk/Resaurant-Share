//
//  CreatingCategoryCollectionVC.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/08/31.
//

import UIKit
import SnapKit

class CreatingCategoryCollectionVC: UICollectionViewController {
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, String>!
    
    private let colors = CustomColor.colors
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureDataSource()
        applySnapshot()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        remove()
    }
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: ColorCollectionViewCell.identifier)
        collectionView.showsHorizontalScrollIndicator = false
    }
    
    private func makeLayout() -> UICollectionViewCompositionalLayout {
        
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .absolute(40), heightDimension: .absolute(40)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 20
        section.contentInsets = .init(top: 0, leading: 15, bottom: 0, trailing: 15)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionViewCell.identifier, for: indexPath) as! ColorCollectionViewCell
            if indexPath.row == 0 {
                cell.setUpInitialColor(with: self.colors[indexPath.row])
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .left)
                
            } else {
                cell.setUpInitialColor(with: self.colors[indexPath.row])
            }
            
            return cell
            
        })
    }
    
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        snapshot.appendSections([0])
        snapshot.appendItems(["1", "2", "3", "4", "5", "6", "7","8","9","10","11"])
        dataSource.apply(snapshot)
    }
    
    
}


