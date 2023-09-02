//
//  TabBarController.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/06/28.
//

import UIKit

class TabBarVC: UITabBarController {
    
    var mapVC: MapVC!
    
    var scrollableView: CategoryScrollableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        tabBar.isTranslucent = false
    }
    
    init(mapVC: MapVC ,scrollableView: CategoryScrollableView) {
        self.mapVC = mapVC
        self.scrollableView = scrollableView
        super.init(nibName: nil, bundle: nil)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTabs() {
        let scrollCategoryVC = ScrollCategoryVC(mapVC: mapVC, scrollableView: scrollableView)
        scrollCategoryVC.scrollCategoryVCDelegate = mapVC
        
        let home = createTab(title: "Hello", image: UIImage(systemName: "house")!, vc: scrollCategoryVC)
        
        let share = createTab(title: "Share", image: UIImage(systemName: "star")!, vc: NoViewController())
        let navHome = UINavigationController(rootViewController: home)
        let nav = UINavigationController(rootViewController: share)
        
        setViewControllers([home, nav], animated: true)
    }
    
    private func createTab(title: String, image: UIImage, vc: UIViewController) -> UIViewController {
        vc.tabBarItem.title = title
        vc.tabBarItem.image = image
        

        return vc
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
    }
    
    
}





