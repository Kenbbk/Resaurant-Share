//
//  CreatingCategoryVcMainView.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/08/30.
//

import UIKit

protocol CreatingCategoryVCMainViewDelegate: AnyObject {
    func dismissTapped()
    func saveButtonTappedInCreatingCategory()
    
}

class CreatingCategoryVCMainView: UIView {
    
    //MARK: - Properties
    
    weak var delegate: CreatingCategoryVCMainViewDelegate?
    
    private var activeTextField: UITextField?
    
    private let padding: CGFloat = 20
    
    private lazy var touchOutsideGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(touchedOutside(_:)))
        gesture.delegate = self
        return gesture
    }()
    
    private let wholeContainerView: UIView = {
        let myView = UIView()
        myView.layer.cornerRadius = 20
        myView.backgroundColor = .white
        return myView
    }()
    
    private let titleContainerView: UIView = {
        let myView = UIView()
        myView.layer.borderWidth = 0.5
        myView.layer.borderColor = UIColor.systemGray4.cgColor
        return myView
    }()
    
    private let nameTFContainerView = UIView()
    
    private let addListLabel: UILabel = {
        let label = UILabel()
        label.text = "Add list"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    private lazy var cancelImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "x.circle")
        iv.isUserInteractionEnabled = true
        iv.tintColor = .systemGray
        iv.isUserInteractionEnabled = true
        iv.clipsToBounds = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelImageTapped(_:))))
        
        return iv
    }()
    
    private(set) lazy var nameTextfFieldView: CountingTextfieldView = {
        let view = CountingTextfieldView(maxCount: 20)
        view.delegate = self
        return view
    }()
    
    let collectionContainer = UIView()
    
    private let selecColorLabel: UILabel = {
        let label = UILabel()
        label.text = "Select color"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    private let descriptionContainerView = UIView()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "Description", attributes: [.font: UIFont.boldSystemFont(ofSize: 18)])
        attributedText.append(NSAttributedString(string: " option", attributes: [.foregroundColor: UIColor.systemGray2, .font: UIFont.systemFont(ofSize: 13)]))
        label.attributedText = attributedText
        
        return label
    }()
    
    private let enclosingDescriptionView: UIView = {
        let myView = UIView()
        myView.layer.borderWidth = 0.7
        myView.layer.borderColor = UIColor.systemGray6.cgColor
        myView.backgroundColor = .systemGray6
        myView.layer.cornerRadius = 5
        return myView
    }()
    
    private(set) lazy var descriptionTextFieldView: CountingTextfieldView = {
        let view = CountingTextfieldView(maxCount: 30)
        view.delegate = self
        return view
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(saveButtonTapped(_:)), for: .touchUpInside)
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
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        configureUI()
        setupKeyboardHiding()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Actions
    
    @objc func saveButtonTapped(_ sender: UIButton) {
        delegate?.saveButtonTappedInCreatingCategory()
    }
    
    @objc func cancelImageTapped(_ gesture: UITapGestureRecognizer) {
        delegate?.dismissTapped()
    }
    
    @objc func touchedOutside(_ sender: UITapGestureRecognizer) {
        endEditing(true)
    }
    
    @objc func keyboarWillShow(sender: Notification) {
        
        addGestureRecognizer(touchOutsideGesture)

        if descriptionTextFieldView.textField.isEditing {
            self.frame.origin.y = 0 - 160
        }
       
    }
    
    @objc func keyboardWillHide(sender: Notification) {
        self.removeGestureRecognizer(touchOutsideGesture)
        self.frame.origin.y = 0
    }
    
    //MARK: - Helpers
    
    private func setupKeyboardHiding() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboarWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

//MARK: - Gesture Delegate

extension CreatingCategoryVCMainView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let location = gestureRecognizer.location(in: self.wholeContainerView)
        
        let convertedRectBounds = collectionContainer.convert(collectionContainer.bounds, to: self.wholeContainerView)
        
        if convertedRectBounds.contains(location) {
            return false
        } else {
            return true
        }
    }
}

extension CreatingCategoryVCMainView: CountingTextFieldViewDelegate {
    func didChange(sender: CountingTextfieldView, letterCount: Int) {
        if sender == nameTextfFieldView {
            saveButton.backgroundColor = letterCount == 0 ? .systemGray4 : .blue
            saveButton.isUserInteractionEnabled = letterCount == 0 ? false : true
        }
    }
    
    func becomeEditing(sender: CountingTextfieldView) {
        if sender == descriptionTextFieldView {
            enclosingDescriptionView.layer.borderColor = UIColor.systemBlue.cgColor
            enclosingDescriptionView.backgroundColor = .white
        }
    }
    
    func endEditing(sender: CountingTextfieldView) {
        if sender == descriptionTextFieldView {
            enclosingDescriptionView.layer.borderColor = UIColor.systemGray6.cgColor
            enclosingDescriptionView.backgroundColor = .systemGray6
        }
    }
}


//MARK: - UI

extension CreatingCategoryVCMainView {
    
    private func configureUI() {
        
        configureWholeContainerView()
        configureTopContainerView()
        configureNameTFContainerView()
        configureCollectionContainer()
        configureDescriptionContainerView()
        configureBottomContainerView()
    }
    
    private func configureWholeContainerView() {
        
        addSubview(wholeContainerView)
        wholeContainerView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(700)
        }
        
        [titleContainerView, nameTFContainerView, collectionContainer, descriptionContainerView, bottomContainerView].forEach { wholeContainerView.addSubview($0)}
    }
    
    private func configureTopContainerView() {
        
        [addListLabel, cancelImageView].forEach { titleContainerView.addSubview($0)}
        titleContainerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(60)
        }
        
        addListLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(30)
        }
        
        cancelImageView.snp.makeConstraints { make in
            make.centerY.equalTo(titleContainerView)
            make.trailing.equalTo(titleContainerView).inset(padding)
        }
    }
    
    private func configureNameTFContainerView() {
        let spacer = UIView()
        spacer.backgroundColor = .black
        
        [nameTextfFieldView, spacer, selecColorLabel].forEach { nameTFContainerView.addSubview($0)}
        nameTFContainerView.snp.makeConstraints { make in
            make.top.equalTo(titleContainerView.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(padding)
            make.height.equalTo(150)
        }
        
        nameTextfFieldView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(35)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
        }
        
        spacer.snp.makeConstraints { make in
            make.top.equalTo(nameTextfFieldView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        selecColorLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(10)
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(35)
        }
    }
    
    private func configureCollectionContainer() {
        
        collectionContainer.snp.makeConstraints { make in
            make.top.equalTo(nameTFContainerView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
    }
    
    private func configureDescriptionContainerView() {

        let spacer = UIView()
        spacer.backgroundColor = .systemGray6
    
        descriptionContainerView.snp.makeConstraints { make in
            make.top.equalTo(collectionContainer.snp.bottom).offset(100)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(155)
        }
        
        descriptionContainerView.addSubview(spacer)
        spacer.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(5)
        }
        
        descriptionContainerView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(spacer.snp.bottom)
            make.leading.equalToSuperview().inset(padding)
            make.height.equalTo(35)
        }
        
        descriptionContainerView.addSubview(enclosingDescriptionView)
        enclosingDescriptionView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(padding)
            make.height.equalTo(40)
        }
        
        let leftSpacingView = UIView()
        enclosingDescriptionView.addSubview(leftSpacingView)
        leftSpacingView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(10)
        }
        
        enclosingDescriptionView.addSubview(descriptionTextFieldView)
        descriptionTextFieldView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.leading.equalTo(leftSpacingView.snp.trailing)
            make.height.equalTo(40)
        }
    }
    
    private func configureBottomContainerView() {
        
        bottomContainerView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(80)
        }
        
        bottomContainerView.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(20)
            make.leading.trailing.equalToSuperview().inset(padding)
            make.height.equalTo(50)
        }
    }
}
