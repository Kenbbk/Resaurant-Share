//
//  NoViewController.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/07/04.
//

import UIKit

class NoViewController: UIViewController {
    
    //MARK: - Properties
    let myView: UIView = {
       let view = UIView(frame: CGRect(x: 200, y: 200, width: 200, height: 200))
        view.backgroundColor = .systemPink
        return view
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(myView)
        view.backgroundColor = .systemGreen
        
        
        
    }

   
    //MARK: - Actions

    //MARK: - Helpers
}
