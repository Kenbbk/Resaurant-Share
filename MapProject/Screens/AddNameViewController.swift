//
//  AddNameViewController.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/06/18.
//

import UIKit
import FirebaseFirestore

class AddNameViewController: UIViewController {
    
    //MARK: - Properties
    let colors = CustomColor.colors
    
    var isReadyToSave: Bool = false {
        didSet {
            
            saveButton.backgroundColor = isReadyToSave ? .blue : .systemGray4
            saveButton.isUserInteractionEnabled = isReadyToSave
        }
        
    }
    
    var activeTextField: UITextField?
    
    let padding: CGFloat = 20
    
    let scrollableView = UIScrollView()
    
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
    
    let nameTextField: UITextField = {
        let tf = UITextField()
        
        tf.clearButtonMode = .whileEditing
        
        tf.attributedPlaceholder = NSAttributedString(string: "Enter a list name", attributes: [.font: UIFont.boldSystemFont(ofSize: 18)])
        return tf
    }()
    
    private let colorContainverView: UIView = {
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
    
    private let descriptionTextField: UITextField = {
        let tf = UITextField()
        
        
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
        guard let title = nameTextField.text else { return }
        guard let colorNumber = collectionView.indexPathsForSelectedItems?.first?.row else { return }
        
        
        let description = descriptionTextField.text!
        let timeStamp = Timestamp(date: Date())
        
        
        let category = Category(title: title, colorNumber: colorNumber, description: description, timeStamp: timeStamp)
        FavoriteSerivce.addCategory(with: category) { 
            UserInfo.shared.categories.append(category)
            guard let presentingVC = self.presentingViewController as? FavoriteViewController else { return }
            presentingVC.setCategoriesAndInitalCategoriesThenReload()
            
            self.dismiss(animated: true)
            
            print("Saved")
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
        
        wholeContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            wholeContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            wholeContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            wholeContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            wholeContainerView.heightAnchor.constraint(equalToConstant: 700)
        ])
    }
    
    private func configureTopContainerView() {
        wholeContainerView.addSubview(titleContainerView)
        
        titleContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleContainerView.topAnchor.constraint(equalTo: wholeContainerView.topAnchor),
            titleContainerView.leadingAnchor.constraint(equalTo: wholeContainerView.leadingAnchor),
            titleContainerView.trailingAnchor.constraint(equalTo: wholeContainerView.trailingAnchor),
            titleContainerView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        titleContainerView.addSubview(addListLabel)
        addListLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addListLabel.centerYAnchor.constraint(equalTo: titleContainerView.centerYAnchor),
            addListLabel.centerXAnchor.constraint(equalTo: titleContainerView.centerXAnchor),
            addListLabel.heightAnchor.constraint(equalToConstant: 30),
            addListLabel.widthAnchor.constraint(equalToConstant: 100)
        ])
        
        titleContainerView.addSubview(cancelImageView)
        cancelImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cancelImageView.centerYAnchor.constraint(equalTo: titleContainerView.centerYAnchor),
            cancelImageView.trailingAnchor.constraint(equalTo: titleContainerView.trailingAnchor, constant: -padding),
            cancelImageView.heightAnchor.constraint(equalToConstant: 30),
            cancelImageView.widthAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func configureTFContainerView() {
        
        
        wholeContainerView.addSubview(TFContainerView)
        
        TFContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            TFContainerView.topAnchor.constraint(equalTo: titleContainerView.bottomAnchor, constant: 30),
            TFContainerView.leadingAnchor.constraint(equalTo: wholeContainerView.leadingAnchor, constant: padding),
            TFContainerView.trailingAnchor.constraint(equalTo: wholeContainerView.trailingAnchor, constant: -padding),
            TFContainerView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        TFContainerView.addSubview(tfCountLabel)
        tfCountLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tfCountLabel.centerYAnchor.constraint(equalTo: TFContainerView.centerYAnchor),
            tfCountLabel.trailingAnchor.constraint(equalTo: TFContainerView.trailingAnchor),
            tfCountLabel.heightAnchor.constraint(equalToConstant: 40),
            tfCountLabel.widthAnchor.constraint(equalToConstant: 40)
        ])
        
        TFContainerView.addSubview(nameTextField)
        nameTextField.delegate = self
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameTextField.centerYAnchor.constraint(equalTo: TFContainerView.centerYAnchor),
            nameTextField.leadingAnchor.constraint(equalTo: TFContainerView.leadingAnchor),
            nameTextField.trailingAnchor.constraint(equalTo: tfCountLabel.leadingAnchor, constant: 5),
            nameTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        
        
        let spacer = UIView()
        TFContainerView.addSubview(spacer)
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.backgroundColor = .black
        NSLayoutConstraint.activate([
            spacer.topAnchor.constraint(equalTo: TFContainerView.bottomAnchor, constant: 0),
            spacer.leadingAnchor.constraint(equalTo: TFContainerView.leadingAnchor),
            spacer.trailingAnchor.constraint(equalTo: TFContainerView.trailingAnchor),
            spacer.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    private func configureColorContainerView() {
        wholeContainerView.addSubview(colorContainverView)
        colorContainverView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            colorContainverView.topAnchor.constraint(equalTo: TFContainerView.bottomAnchor, constant: 10),
            colorContainverView.leadingAnchor.constraint(equalTo: wholeContainerView.leadingAnchor),
            colorContainverView.trailingAnchor.constraint(equalTo: wholeContainerView.trailingAnchor),
            colorContainverView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        colorContainverView.addSubview(selecColorLabel)
        selecColorLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selecColorLabel.topAnchor.constraint(equalTo: colorContainverView.topAnchor),
            selecColorLabel.leadingAnchor.constraint(equalTo: colorContainverView.leadingAnchor, constant: padding),
            selecColorLabel.trailingAnchor.constraint(equalTo: colorContainverView.trailingAnchor, constant: -padding),
            selecColorLabel.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        colorContainverView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        collectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: ColorCollectionViewCell.identifier)
        
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: selecColorLabel.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: colorContainverView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: colorContainverView.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        let spacer = UIView()
        colorContainverView.addSubview(spacer)
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.backgroundColor = .systemGray6
        
        NSLayoutConstraint.activate([
            spacer.leadingAnchor.constraint(equalTo: colorContainverView.leadingAnchor),
            spacer.trailingAnchor.constraint(equalTo: colorContainverView.trailingAnchor),
            spacer.bottomAnchor.constraint(equalTo: colorContainverView.bottomAnchor),
            spacer.heightAnchor.constraint(equalToConstant: 5)
        ])
    }
    
    private func configureFlowLayout() -> UICollectionViewFlowLayout{
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 40, height: 40)
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        return flowLayout
    }
    
    private func configureDescriptionContainerView() {
        wholeContainerView.addSubview(descriptionContainerView)
        
        descriptionContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionContainerView.topAnchor.constraint(equalTo: colorContainverView.bottomAnchor, constant: 0),
            descriptionContainerView.leadingAnchor.constraint(equalTo: wholeContainerView.leadingAnchor),
            descriptionContainerView.trailingAnchor.constraint(equalTo: wholeContainerView.trailingAnchor),
            descriptionContainerView.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        descriptionContainerView.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: descriptionContainerView.topAnchor, constant: 5),
            descriptionLabel.leadingAnchor.constraint(equalTo: descriptionContainerView.leadingAnchor, constant: padding),
            descriptionLabel.widthAnchor.constraint(equalToConstant: 200),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        descriptionContainerView.addSubview(enclosingDescriptionView)
        enclosingDescriptionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            enclosingDescriptionView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            enclosingDescriptionView.leadingAnchor.constraint(equalTo: descriptionContainerView.leadingAnchor, constant: padding),
            enclosingDescriptionView.trailingAnchor.constraint(equalTo: descriptionContainerView.trailingAnchor, constant: -padding),
            enclosingDescriptionView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        let leftSpacingView = UIView()
        
        enclosingDescriptionView.addSubview(leftSpacingView)
        leftSpacingView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            leftSpacingView.leadingAnchor.constraint(equalTo: enclosingDescriptionView.leadingAnchor),
            leftSpacingView.topAnchor.constraint(equalTo: enclosingDescriptionView.topAnchor),
            leftSpacingView.bottomAnchor.constraint(equalTo: enclosingDescriptionView.bottomAnchor),
            leftSpacingView.widthAnchor.constraint(equalToConstant: 10)
            
        ])
        
        enclosingDescriptionView.addSubview(descriptionCountLabel)
        descriptionCountLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionCountLabel.centerYAnchor.constraint(equalTo: enclosingDescriptionView.centerYAnchor),
            descriptionCountLabel.trailingAnchor.constraint(equalTo: enclosingDescriptionView.trailingAnchor, constant: -10),
            descriptionCountLabel.widthAnchor.constraint(equalToConstant: 30),
            descriptionCountLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        enclosingDescriptionView.addSubview(descriptionTextField)
        descriptionTextField.delegate = self
        descriptionTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionTextField.topAnchor.constraint(equalTo: enclosingDescriptionView.topAnchor),
            descriptionTextField.leadingAnchor.constraint(equalTo: leftSpacingView.trailingAnchor),
            descriptionTextField.trailingAnchor.constraint(equalTo: descriptionCountLabel.leadingAnchor),
            descriptionTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    
    
    private func configureBottomContainerView() {
        wholeContainerView.addSubview(bottomContainerView)
        bottomContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomContainerView.bottomAnchor.constraint(equalTo: wholeContainerView.bottomAnchor),
            bottomContainerView.leadingAnchor.constraint(equalTo: wholeContainerView.leadingAnchor),
            bottomContainerView.trailingAnchor.constraint(equalTo: wholeContainerView.trailingAnchor),
            bottomContainerView.heightAnchor.constraint(equalToConstant: 80)
        ])
        bottomContainerView.addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            saveButton.bottomAnchor.constraint(equalTo: bottomContainerView.bottomAnchor, constant: -20),
            saveButton.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: padding),
            saveButton.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -padding),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
    }
    
    
}

//MARK: - UITextFieldDelegate

extension AddNameViewController: UITextFieldDelegate {
    
    
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
extension AddNameViewController: UICollectionViewDataSource {
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

extension AddNameViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //add here
        
        let selectedIndexPath = IndexPath(item: 0, section: 0)
        collectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: [])
    }
}

extension AddNameViewController: UIGestureRecognizerDelegate {
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

