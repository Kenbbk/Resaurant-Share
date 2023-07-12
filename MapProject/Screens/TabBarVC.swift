//
//  TabBarController.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/06/28.
//

import UIKit

class TabBarVC: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        
        tabBar.isTranslucent = false
        
    }
    
    private func setupTabs() {
        
        let home = createTab(title: "Hello", image: UIImage(systemName: "house")!, vc: ScrollCategoryVC())
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
        let vc = self.getTopHierarchyViewController() as! MapVC
        
//        vc.scrollCategoryViewFilledTheSuperView(bool: item.title == "Share")
        
    }
    
    
}





