//
//  CategoryVCMainView.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/08/28.
//

import UIKit
import FirebaseFirestore


protocol CategoryVCMainViewDelegate: AnyObject {
    func dismissTapped()
    func saveButtonTappedInCategoryVC()
    func cellTapped(indexPath: IndexPath)
    func cellDeselect()
    
}

class CategoryVCMainView: UIView {
    
    //MARK: - Properties
    
    private let padding: CGFloat = 15
    
    var buttonState: (title: String, isActive: Bool) {
        get { return (title: saveButton.currentTitle!, isActive: saveButton.isEnabled) }
        set {
            saveButton.setTitle(newValue.title, for: .normal)
            saveButton.backgroundColor = newValue.isActive ? .blue : .gray
            saveButton.isUserInteractionEnabled = newValue.isActive
        }
    }
    
    weak var delegate: CategoryVCMainViewDelegate?
    
    private let containerView: UIView = {
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
    
     let topLabel: UILabel = {
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
    
     private(set) lazy var saveButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGray4
        button.setTitle("Save", for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    
     private let bottomContainerView: UIView = {
        let myView = UIView()
        myView.backgroundColor = .white
        myView.layer.borderWidth = 0.17
        myView.layer.borderColor = UIColor.systemGray4.cgColor
        
        return myView
    }()
    
    private(set) lazy var myTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CreateCell.self, forCellReuseIdentifier: CreateCell.identifier)
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.identifier)
        tableView.delegate = self
        tableView.rowHeight = 50
        tableView.allowsMultipleSelection = true
        return tableView
    }()
    
    private lazy var outsideGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tappedOutside(_:)))
        
        return gesture
    }()
    
    private(set) var dataSource: UITableViewDiffableDataSource<Section, CategoryCellModel>!
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        configureUI()
        addGesutreonView()
        configureDataSource()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Actions
    
    @objc private func rightImageViewTapped(_ gesture: UITapGestureRecognizer) {
        backgroundColor = .clear
        delegate?.dismissTapped()
    }
    
    @objc private func tappedOutside(_ gesture: UITapGestureRecognizer) {
        backgroundColor = .clear
        delegate?.dismissTapped()
    }
    
    @objc private func saveButtonTapped() {
        backgroundColor = .clear
        delegate?.saveButtonTappedInCategoryVC()
    }
    
    //MARK: - Helpers
    
    private func configureDataSource() {
        dataSource = UITableViewDiffableDataSource(tableView: myTableView, cellProvider: { tableView, indexPath, cellModel in
            if Section(rawValue: indexPath.section) == .create {
                let cell = tableView.dequeueReusableCell(withIdentifier: CreateCell.identifier, for: indexPath) as! CreateCell
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.identifier, for: indexPath) as! CategoryCell
                if cellModel.shouldHighLighted == true {
                    
                    tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                    cell.isSelected = true
                    
                }
                cell.setOtherIndexPathLabel(with: cellModel)
                return cell
            }
        })
    }
    
    private func addGesutreonView() {
        addGestureRecognizer(outsideGesture)
        outsideGesture.delegate = self
    }
    
}

//MARK: - Gesture Delegate

extension CategoryVCMainView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == outsideGesture {
            let location = gestureRecognizer.location(in: self)
            if self.containerView.frame.contains(location) {
                
                return false
            }
        }
        return true
    }
}

extension CategoryVCMainView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            
        }
        delegate?.cellTapped(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        delegate?.cellDeselect()
    }
}

//MARK: - UI

extension CategoryVCMainView {
    
    private func configureUI() {
        configureContainerView()
        configureTopContainerView()
        configureBottomContainerView()
        configureTableView()
    }
    
    private func configureContainerView() {
        addSubview(containerView)
        
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
