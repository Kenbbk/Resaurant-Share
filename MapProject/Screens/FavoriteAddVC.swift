//
//  FavoriteAddVC.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/06/17.
//

import UIKit

class FavoriteAddVC: UIViewController {
    
    //MARK: - Properties
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
    
    private let topRightImageView: UIImageView = {
       let iv = UIImageView()
        iv.image = UIImage(systemName: "x.circle")
        iv.tintColor = .systemGray
        iv.clipsToBounds = true
        return iv
    }()
    
    private let saveButton: UIButton = {
       let button = UIButton()
        button.backgroundColor = .systemGray4
        button.setTitle("Save", for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let bottomContainerView: UIView = {
       let myView = UIView()
        myView.layer.borderWidth = 0.17
        myView.layer.borderColor = UIColor.systemGray4.cgColor
        return myView
    }()
    
    private let FavoriteTableView: UITableView = {
       let tableView = UITableView()
        
        return tableView
    }()
    
    
    
   
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUI()
      
       
    }
    //MARK: - Actions
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        
        let touchLocation = gesture.location(in: view)
                
                // Check if the touch is outside the bounds of the SecondViewController's view
                if !view.bounds.contains(touchLocation) {
                    print("Hello")
                }
    }
    
    //MARK: - Helpers
    

    
    private func configureUI() {
        configureTopContainerView()
        configureBottomContainerView()
        configureTableView()
        
    }
    
    private func configureBottomContainerView() {
        view.addSubview(bottomContainerView)
        bottomContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomContainerView.heightAnchor.constraint(equalToConstant: 80)
        ])
        bottomContainerView.addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            saveButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
    }
    
    private func configureTableView() {
        view.addSubview(FavoriteTableView)
        FavoriteTableView.rowHeight = 50
        FavoriteTableView.register(FavoriteCell.self, forCellReuseIdentifier: FavoriteCell.identifier)
        FavoriteTableView.dataSource = self
        FavoriteTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            FavoriteTableView.topAnchor.constraint(equalTo: topContainerView.bottomAnchor),
            FavoriteTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            FavoriteTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            FavoriteTableView.bottomAnchor.constraint(equalTo: bottomContainerView.topAnchor)
        ])
    }
    
    private func configureTopContainerView() {
        
        let height: CGFloat = 20
        view.addSubview(topContainerView)
        topContainerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            topContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            topContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
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
        
        topContainerView.addSubview(topLabel)
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topLabel.centerYAnchor.constraint(equalTo: topContainerView.centerYAnchor),
            topLabel.leadingAnchor.constraint(equalTo: topLeftImageView.leadingAnchor, constant: 25),
            topLabel.heightAnchor.constraint(equalToConstant: height),
            topLabel.widthAnchor.constraint(equalToConstant: 150)
        ])
        
        topContainerView.addSubview(topRightImageView)
        topRightImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topRightImageView.centerYAnchor.constraint(equalTo: topContainerView.centerYAnchor),
            topRightImageView.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor, constant: -5),
            topRightImageView.heightAnchor.constraint(equalToConstant: height),
            topRightImageView.widthAnchor.constraint(equalToConstant: 20)
        ])
    }
}

extension FavoriteAddVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteCell.identifier) as! FavoriteCell
        
        return cell
    }
    
    
}

extension FavoriteAddVC: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldReceive touch: UITouch) -> Bool {
        print("Tapped")
      return (touch.view === self.view)
    }
  }
