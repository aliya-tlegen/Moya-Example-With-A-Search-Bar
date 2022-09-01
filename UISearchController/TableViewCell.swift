//
//  TableViewCell.swift
//  UISearchController
//
//  Created by Алия Тлеген on 02.09.2022.
//

import UIKit
    
class TableViewCell: UITableViewCell {

    // MARK: - Private Variables -

    public let idLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    public let nameLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    // MARK: - Initialization -
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration -
    
    func configure(model: User) {
//        if let id = model.id {
//            idLabel.text = "\(id)"
//        }
//        idLabel.text = "(\(model.id)"
        nameLabel.text = model.name
    }
    
    // MARK: - Setup -
    
    func setupViews() {
        contentView.addSubview(idLabel)
        contentView.addSubview(nameLabel)
    }
    
    func setupConstraints() {
        idLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.left.equalToSuperview().offset(5)
        }
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
//            $0.top.equalTo(idLabel.snp.bottom).offset(7)
            $0.left.equalTo(idLabel.snp.right).offset(7)
        }
    }

}
