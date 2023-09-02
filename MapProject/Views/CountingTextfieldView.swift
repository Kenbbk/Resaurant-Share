//
//  CountingTextField.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/09/01.
//

import UIKit

protocol CountingTextFieldViewDelegate: AnyObject {
    
    func becomeEditing(sender: CountingTextfieldView)
    func endEditing(sender: CountingTextfieldView)
    func didChange(sender: CountingTextfieldView, letterCount: Int)
}

class CountingTextfieldView: UIView {
    
    var maxCount: Int
    
    weak var delegate: CountingTextFieldViewDelegate?
    
    private(set) lazy var textField: UITextField = {
        let tf = UITextField()
        tf.delegate = self
        tf.clearButtonMode = .whileEditing
        tf.attributedPlaceholder = NSAttributedString(string: "Enter a list name", attributes: [.font: UIFont.boldSystemFont(ofSize: 18)])
        return tf
    }()
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        
        let attributedText = NSMutableAttributedString(string: "0", attributes: [.font: UIFont.systemFont(ofSize: 13)])
        attributedText.append(NSAttributedString(string: "/\(maxCount)", attributes: [.foregroundColor: UIColor.systemGray2, .font: UIFont.systemFont(ofSize: 13)]))
        label.attributedText = attributedText
        return label
    }()
    
    init(maxCount: Int) {
        self.maxCount = maxCount
        super.init(frame: .zero)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        configureCountLabel()
        configureTextField()
        
    }
    
    private func configureCountLabel() {
        addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.centerY.trailing.equalToSuperview()
            make.width.height.equalTo(40)
        }
    }
    
    private func configureTextField() {
        addSubview(textField)
        textField.snp.makeConstraints { make in
            make.centerY.leading.equalToSuperview()
            make.trailing.equalTo(countLabel.snp.leading).offset(5)
            make.height.equalTo(40)
        }
    }
    
    private func setAttributedText(sender: UITextField) { // service로 빼줄까?
        
            guard let textFieldCount = sender.text?.count else { return }
            let attributedText = NSMutableAttributedString(string: "\(textFieldCount)", attributes: [.font: UIFont.systemFont(ofSize: 13)])
            attributedText.append(NSAttributedString(string: "/20", attributes: [.foregroundColor: UIColor.systemGray2, .font: UIFont.systemFont(ofSize: 13)]))
            countLabel.attributedText = attributedText
    }
}

extension CountingTextfieldView: UITextFieldDelegate {
    
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        
            if let trimmedTextCount = textField.text?.trimmingCharacters(in: .whitespaces).count {
                delegate?.didChange(sender: self, letterCount: trimmedTextCount)

            }
        
        setAttributedText(sender: textField)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.becomeEditing(sender: self)

    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let trimmedTextCount = textField.text?.trimmingCharacters(in: .whitespaces).count {
            if trimmedTextCount == 0 {
                textField.text = ""
                setAttributedText(sender: textField)
            }
        }
        delegate?.endEditing(sender: self)

    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // get the current text, or use an empty string if that failed
        let maxCount = self.maxCount
        
        let currentText = textField.text ?? ""
        
        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // make sure the result is under 16 characters
        return updatedText.count <= maxCount
    }
    
}
