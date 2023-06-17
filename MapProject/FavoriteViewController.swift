//
//  FavoriteView.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/06/17.
//

import UIKit

class FavoriteViewController: UIViewController {
    
    
    
    //MARK: - Properties
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
    
    private let topRightImageView: UIImageView = {
       let iv = UIImageView()
        iv.image = UIImage(systemName: "x.circle")
        iv.isUserInteractionEnabled = true
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
        myView.backgroundColor = .white
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
        
        
        configureUI()
        addActionOnTopRightImage()
        addGesutreonView()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.1) {
            self.view.backgroundColor = .systemGray.withAlphaComponent(0.55)
        }
        
    }
    
   
    //MARK: - Actions
    
    @objc private func rightImageViewTapped(_ gesture: UITapGestureRecognizer) {
        print("right image tapped")
        view.backgroundColor = .clear
        dismiss(animated: true)
    }
    
    @objc private func checkIfTapIsInside(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self.view)
        if !containerView.frame.contains(location) {
            view.backgroundColor = .clear
            dismiss(animated: true)
        }
    }
    //MARK: - Helpers
    
    private func addGesutreonView() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(checkIfTapIsInside(_:))))
    }
    
    private func addActionOnTopRightImage() {
        
        topRightImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rightImageViewTapped(_:))))
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

extension FavoriteViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteCell.identifier) as! FavoriteCell
        
        return cell
    }
    
    
}

