//
//  CustomInfoWindowView.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/06/14.
//

import UIKit

class CustomInfoWindowView: UIView {
    var iconView = UIImageView()
    var textLabel = UILabel()
    //    let button: UIButton = {
    //        let button = UIButton(type: .system)
    //        button.setTitle("Hello", for: .normal)
    //        button.backgroundColor = .systemPink
    //        return button
    //    }()
    
    let TF = UITextField()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        backgroundColor = .white
        iconView.backgroundColor = .systemCyan
        //        textLabel.backgroundColor = .red
        //        addSubview(iconView)
        //        addSubview(textLabel)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        addSubview(iconView)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: self.topAnchor),
            iconView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 10),
            iconView.heightAnchor.constraint(equalToConstant: 10)
        ])
        
        
        addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints =  false
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: self.topAnchor),
            textLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 5),
            textLabel.widthAnchor.constraint(equalToConstant: 10),
            textLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        addSubview(TF)
        TF.backgroundColor = .systemPink
        TF.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            TF.topAnchor.constraint(equalTo: self.topAnchor),
            TF.leadingAnchor.constraint(equalTo: textLabel.trailingAnchor, constant: 5),
            TF.widthAnchor.constraint(equalToConstant: 100),
            TF.heightAnchor.constraint(equalToConstant: 20)
        ])
        //        addSubview(button)
        //        button.translatesAutoresizingMaskIntoConstraints = false
        //        NSLayoutConstraint.activate([
        //            button.topAnchor.constraint(equalTo: self.topAnchor),
        //            button.leadingAnchor.constraint(equalTo: textLabel.trailingAnchor, constant: 5),
        //            button.widthAnchor.constraint(equalToConstant: 30),
        //            button.heightAnchor.constraint(equalToConstant: 20)
        //        ])
        //
        //        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        textLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapped(_:))))
    }
    
    @objc func didTapped(_ gesture: UITapGestureRecognizer) {
        print("I am Tapped")
    }
    
    @objc func buttonTapped() {
        print("Button Tapped")
    }
}
