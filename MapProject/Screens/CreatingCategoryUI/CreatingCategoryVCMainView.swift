//
//  CreatingCategoryVcMainView.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/08/30.
//

import UIKit

protocol CreatingCategoryVCMainViewDelegate: AnyObject {
    func dismissTapped()
    func saveButtonTapped()
}

class CreatingCategoryVCMainView: UIView {
    
    //MARK: - Properties
    private var isReadyToSave: Bool = false {
        didSet {
            
            saveButton.backgroundColor = isReadyToSave ? .blue : .systemGray4
            saveButton.isUserInteractionEnabled = isReadyToSave
        }
    }
    
    weak var delegate: CreatingCategoryVCMainViewDelegate?
    
    private var activeTextField: UITextField?
    
    private let padding: CGFloat = 20
    
    private lazy var touchOutsideGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(touchedOutside(_:)))
        gesture.delegate = self
        return gesture
    }()
    
    let wholeContainerView: UIView = {
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
    
    private let TFContainerView = UIView()
    
    private let tfCountLabel: UILabel = {
        let label = UILabel()
        
        let attributedText = NSMutableAttributedString(string: "0", attributes: [.font: UIFont.systemFont(ofSize: 13)])
        attributedText.append(NSAttributedString(string: "/20", attributes: [.foregroundColor: UIColor.systemGray2, .font: UIFont.systemFont(ofSize: 13)]))
        label.attributedText = attributedText
        return label
    }()
    
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
    
    private(set) lazy var nameTextField: UITextField = {
        let tf = UITextField()
        tf.delegate = self
        tf.clearButtonMode = .whileEditing
        tf.attributedPlaceholder = NSAttributedString(string: "Enter a list name", attributes: [.font: UIFont.boldSystemFont(ofSize: 18)])
        return tf
    }()
    
    let collectionContainer = UIView()
    
    private let selecColorLabel: UILabel = {
        let label = UILabel()
        label.text = "Select color"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    private let descriptionContainerView = UIView()
    
    let descriptionLabel: UILabel = {
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
    
    let descriptionCountLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "0", attributes: [.font: UIFont.systemFont(ofSize: 13)])
        attributedText.append(NSAttributedString(string: "/30", attributes: [.foregroundColor: UIColor.systemGray2, .font: UIFont.systemFont(ofSize: 13)]))
        label.attributedText = attributedText
        return label
    }()
    
    private(set) lazy var descriptionTextField: UITextField = {
        let tf = UITextField()
        tf.delegate = self
        tf.layer.cornerRadius = 5
        tf.clearButtonMode = .whileEditing
        tf.attributedPlaceholder = NSAttributedString(string: "Enter a note", attributes: [.font: UIFont.boldSystemFont(ofSize: 18)])
        return tf
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
        delegate?.saveButtonTapped()
    }
    
    @objc func cancelImageTapped(_ gesture: UITapGestureRecognizer) {
        delegate?.dismissTapped()
    }
    
    @objc func touchedOutside(_ sender: UITapGestureRecognizer) {
        endEditing(true)
    }
    
    @objc func keyboarWillShow(sender: Notification) {
        
        addGestureRecognizer(touchOutsideGesture)
        // if active text field is not nil
        if activeTextField == descriptionTextField {
            print(activeTextField!)
            self.frame.origin.y = 0 - 80
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
    
    private func setAttributedText(sender: UITextField) { // service로 빼줄까?
        if sender == nameTextField {
            guard let textFieldCount = sender.text?.count else { return }
            let attributedText = NSMutableAttributedString(string: "\(textFieldCount)", attributes: [.font: UIFont.systemFont(ofSize: 13)])
            attributedText.append(NSAttributedString(string: "/20", attributes: [.foregroundColor: UIColor.systemGray2, .font: UIFont.systemFont(ofSize: 13)]))
            tfCountLabel.attributedText = attributedText
        } else {
            guard let textFieldCount = sender.text?.count else { return }
            
            let attributedText = NSMutableAttributedString(string: "\(textFieldCount)", attributes: [.font: UIFont.systemFont(ofSize: 13)])
            attributedText.append(NSAttributedString(string: "/30", attributes: [.foregroundColor: UIColor.systemGray2, .font: UIFont.systemFont(ofSize: 13)]))
            descriptionCountLabel.attributedText = attributedText
        }
    }
}

//MARK: - textfield Delegate

extension CreatingCategoryVCMainView: UITextFieldDelegate {
    
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        if textField == nameTextField {
            if let trimmedTextCount = textField.text?.trimmingCharacters(in: .whitespaces).count {
                isReadyToSave = trimmedTextCount == 0 ? false : true
            }
        }
        setAttributedText(sender: textField)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        activeTextField = textField
        
        if textField == descriptionTextField {
            enclosingDescriptionView.backgroundColor = .white
            enclosingDescriptionView.layer.borderColor = UIColor.blue.withAlphaComponent(0.8).cgColor
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let trimmedTextCount = textField.text?.trimmingCharacters(in: .whitespaces).count {
            if trimmedTextCount == 0 {
                textField.text = ""
                setAttributedText(sender: textField)
            }
        }
        activeTextField = nil
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // get the current text, or use an empty string if that failed
        var maxCount = 20
        if textField == descriptionTextField {
            maxCount = 30
        }
        
        let currentText = textField.text ?? ""
        
        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // make sure the result is under 16 characters
        return updatedText.count <= maxCount
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


//MARK: - UI

extension CreatingCategoryVCMainView {
    
    private func configureUI() {
        
        configureWholeContainerView()
        configureTopContainerView()
        configureTFContainerView()
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
        
        [titleContainerView, TFContainerView, collectionContainer, descriptionContainerView, bottomContainerView].forEach { wholeContainerView.addSubview($0)}
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
    
    private func configureTFContainerView() {
        let spacer = UIView()
        spacer.backgroundColor = .black
        
        [tfCountLabel, nameTextField, spacer, selecColorLabel].forEach { TFContainerView.addSubview($0)}
        
        TFContainerView.snp.makeConstraints { make in
            make.top.equalTo(titleContainerView.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(padding)
            make.height.equalTo(120)
        }
        
        tfCountLabel.snp.makeConstraints { make in
            make.centerY.trailing.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        nameTextField.snp.makeConstraints { make in
            make.centerY.leading.equalToSuperview()
            make.trailing.equalTo(tfCountLabel.snp.leading).offset(5)
            make.height.equalTo(40)
        }
        
       spacer.snp.makeConstraints { make in
           make.top.equalTo(nameTextField.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        selecColorLabel.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(35)
        }
    }
    
    private func configureCollectionContainer() {
        
        collectionContainer.snp.makeConstraints { make in
            make.top.equalTo(TFContainerView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
    }
    
    private func configureDescriptionContainerView() {
        
        let spacer = UIView()
        spacer.backgroundColor = .systemGray6
        
        descriptionContainerView.snp.makeConstraints { make in
            make.top.equalTo(collectionContainer.snp.bottom).offset(150)
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
        
        enclosingDescriptionView.addSubview(descriptionCountLabel)
        descriptionCountLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(10)
            make.width.height.equalTo(30)
        }
        
        enclosingDescriptionView.addSubview(descriptionTextField)
        descriptionTextField.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(leftSpacingView.snp.trailing)
            make.trailing.equalTo(descriptionCountLabel.snp.leading)
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
