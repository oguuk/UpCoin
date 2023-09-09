//
//  ViewController.swift
//  UpCoin
//
//  Created by oguuk on 2023/09/05.
//

import UIKit

final class HomeView: UIView {
    
    private enum Constant {
        static let padding: CGFloat = 10
        static let textFieldHeight: CGFloat = 30
    }
    
    lazy var textField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = .white
        tf.layer.cornerRadius = Constant.textFieldHeight / 2
        tf.layer.shadowColor = UIColor.black.cgColor
        tf.layer.shadowOffset = CGSize(width: 0, height: 2)
        tf.layer.shadowRadius = 4
        tf.layer.shadowOpacity = 0.25

        let vacantView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 20.0, height: 2.0))
        tf.leftView = vacantView
        tf.leftViewMode = .always
        tf.rightView = vacantView
        tf.rightViewMode = .always
        
        return tf
    }()

    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .black
        tableView.register(StockListCell.self, forCellReuseIdentifier: StockListCell.identifier)
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        [textField, tableView]
            .forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                addSubview($0)
            }
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: Constant.padding),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constant.padding),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constant.padding),
            textField.heightAnchor.constraint(equalToConstant: Constant.textFieldHeight),
            
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: Constant.padding),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
