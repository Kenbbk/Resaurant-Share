//
//  AddNameViewController.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/06/18.
//

import UIKit
import FirebaseFirestore
import SnapKit

protocol NamingCategoryVCDelegate: AnyObject {
    func saveButtonTapped(sender: NamingCategoryVC)
}

class NamingCategoryVC: UIViewController {
    
    //MARK: - Properties
    
    private let colors = CustomColor.colors
    
    private var isReadyToSave: Bool = false {
        didSet {
            
            saveButton.backgroundColor = isReadyToSave ? .blue : .systemGray4
            saveButton.isUserInteractionEnabled = isReadyToSave
        }
    }
    
    weak var delegate: NamingCategoryVCDelegate?
    
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
    
    private lazy var nameTextField: UITextField = {
        let tf = UITextField()
        tf.delegate = self
        tf.clearButtonMode = .whileEditing
        tf.attributedPlaceholder = NSAttributedString(string: "Enter a list name", attributes: [.font: UIFont.boldSystemFont(ofSize: 18)])
        
        return tf
    }()
    
    private let colorContainerView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    private let selecColorLabel: UILabel = {
        let label = UILabel()
        label.text = "Select color"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureFlowLayout())
        collectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: ColorCollectionViewCell.identifier)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
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
    
    private let descriptionCountLabel: UILabel = {
        let label = UILabel()
        
        let attributedText = NSMutableAttributedString(string: "0", attributes: [.font: UIFont.systemFont(ofSize: 13)])
        attributedText.append(NSAttributedString(string: "/30", attributes: [.foregroundColor: UIColor.systemGray2, .font: UIFont.systemFont(ofSize: 13)]))
        label.attributedText = attributedText
        return label
    }()
    
    private lazy var descriptionTextField: UITextField = {
        let tf = UITextField()
        tf.delegate = self
        tf.layer.cornerRadius = 5
        tf.clearButtonMode = .whileEditing
        tf.attributedPlaceholder = NSAttributedString(string: "Enter a note", attributes: [.font: UIFont.boldSystemFont(ofSize: 18)])
        return tf
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(saveButtonTapped(_:))))
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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        setupKeyboardHiding()
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Actions
    
    @objc func cancelImageTapped(_ gesture: UITapGestureRecognizer) {
        
        dismiss(animated: true)
    }
    
    @objc func saveButtonTapped(_ gesture: UITapGestureRecognizer) {
        guard let categoryTitle = nameTextField.text else { return }
        guard let colorNumber = collectionView.indexPathsForSelectedItems?.first?.row else { return }
        
        let description = descriptionTextField.text!
        let timeStamp = Timestamp(date: Date())
        
        let category = Category(title: categoryTitle, colorNumber: colorNumber, description: description, timeStamp: timeStamp)
        FavoriteSerivce.shared.addCategory(with: category) {
            
            self.delegate?.saveButtonTapped(sender: self)
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        }
    }
    
    @objc func keyboarWillShow(sender: Notification) {
        
        view.addGestureRecognizer(touchOutsideGesture)
        // if active text field is not nil
        if activeTextField == descriptionTextField {
            print(activeTextField!)
            view.frame.origin.y = 0 - 80
        }
    }
    
    @objc func keyboardWillHide(sender: Notification) {
        view.removeGestureRecognizer(touchOutsideGesture)
        view.frame.origin.y = 0
    }
    
    @objc func touchedOutside(_ sender: UITapGestureRecognizer) {
        
        view.endEditing(true)
        print("I am tapped")
    }
    
    //MARK: - Helpers
    
    
    private func setupKeyboardHiding() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboarWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setAttributedText(sender: UITextField) {
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
    
    private func configureFlowLayout() -> UICollectionViewFlowLayout{
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 40, height: 40)
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        return flowLayout
    }
    
    
    //MARK: - UI
    
    private func configureUI() {
        
        configureWholeContainerView()
        configureTopContainerView()
        configureTFContainerView()
        configureColorContainerView()
        configureDescriptionContainerView()
        configureBottomContainerView()
    }
    
    private func configureWholeContainerView() {
        
        view.addSubview(wholeContainerView)
        wholeContainerView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(700)
        }
    }
    
    private func configureTopContainerView() {
        
        wholeContainerView.addSubview(titleContainerView)
        titleContainerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(60)
        }
        
        titleContainerView.addSubview(addListLabel)
        addListLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(30)
        }
        
        titleContainerView.addSubview(cancelImageView)
        cancelImageView.snp.makeConstraints { make in
            make.centerY.equalTo(titleContainerView)
            make.trailing.equalTo(titleContainerView).inset(padding)
        }
    }
    
    private func configureTFContainerView() {
        
        wholeContainerView.addSubview(TFContainerView)
        TFContainerView.snp.makeConstraints { make in
            make.top.equalTo(titleContainerView.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(padding)
            make.height.equalTo(50)
        }
        
        TFContainerView.addSubview(tfCountLabel)
        tfCountLabel.snp.makeConstraints { make in
            make.centerY.trailing.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        TFContainerView.addSubview(nameTextField)
        nameTextField.snp.makeConstraints { make in
            make.centerY.leading.equalToSuperview()
            make.trailing.equalTo(tfCountLabel.snp.leading).offset(5)
            make.height.equalTo(40)
        }
        
        let spacer = UIView()
        TFContainerView.addSubview(spacer)
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.backgroundColor = .black
        
        spacer.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    private func configureColorContainerView() {
        wholeContainerView.addSubview(colorContainerView)
        colorContainerView.snp.makeConstraints { make in
            make.top.equalTo(TFContainerView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(200)
        }
        
        colorContainerView.addSubview(selecColorLabel)
        selecColorLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(padding)
            make.height.equalTo(35)
        }
        
        colorContainerView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(selecColorLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        
        let spacer = UIView()
        spacer.backgroundColor = .systemGray6
        colorContainerView.addSubview(spacer)
        
        spacer.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(5)
        }
    }
    
    private func configureDescriptionContainerView() {
        wholeContainerView.addSubview(descriptionContainerView)
        descriptionContainerView.snp.makeConstraints { make in
            make.top.equalTo(colorContainerView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(150)
        }
        
        descriptionContainerView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(5)
            make.leading.equalToSuperview().inset(padding)
            make.width.equalTo(200)
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
        wholeContainerView.addSubview(bottomContainerView)
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


//MARK: - UITextFieldDelegate

extension NamingCategoryVC: UITextFieldDelegate {
    
    
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

//MARK: - UICollectionViewDataSource
extension NamingCategoryVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        colors.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionViewCell.identifier, for: indexPath) as! ColorCollectionViewCell
        if indexPath.row == 0 {
            cell.setUpInitialColor(with: colors[indexPath.row])
            cell.isSelected = true
            
        } else {
            cell.setUpInitialColor(with: colors[indexPath.row])
        }
        
        return cell
    }
}

//MARK: - UICollectionViewdelegate

extension NamingCategoryVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let selectedIndexPath = IndexPath(item: 0, section: 0)
        collectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: [])
    }
}

extension NamingCategoryVC: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let location = gestureRecognizer.location(in: self.wholeContainerView)
        
        let convertedRectBounds = collectionView.convert(collectionView.bounds, to: self.wholeContainerView)
        
        if convertedRectBounds.contains(location) {
            return false
        } else {
            return true
        }
    }
}

