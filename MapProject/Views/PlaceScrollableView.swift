//
//  PlaceScrollableView.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/07/17.
//

import UIKit

class PlaceScrollableView: BluePrintScrollableView {
    
    override var isHidden: Bool {
        didSet {
            if isHidden {
                currentPosition = .bottom

            }
        }
    }
    
     let dragIcon: UIView = {
        let myView = UIView()
        myView.layer.cornerRadius = 2.5
        myView.backgroundColor = .systemGray3
        return myView
    }()
    
    let containerForTableView: UIView = {
       let view = UIView()
        view.backgroundColor = .systemBlue
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {

        scrollableView.addSubview(dragIcon)
        dragIcon.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(50)
            make.height.equalTo(5)
        }
        
        scrollableView.addSubview(containerForTableView)
        containerForTableView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.left.right.bottom.equalToSuperview()

        }
}
}
extension PlaceScrollableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = String(indexPath.row)
        return cell
    }
}


