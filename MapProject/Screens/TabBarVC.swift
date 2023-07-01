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
        
        tabBar.barTintColor = .systemGray
        tabBar.isTranslucent = false
    }
    
    private func setupTabs() {
        
        let home = createTab(title: "Hello", image: UIImage(systemName: "house")!, vc: ScrollCategoryVC())
        setViewControllers([home], animated: true)
    }
    
    private func createTab(title: String, image: UIImage, vc: UIViewController) -> UIViewController {
        vc.tabBarItem.title = title
        vc.tabBarItem.image = image
        
        return vc
    }

}

