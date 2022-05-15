//
//  CategoryCollectionViewCell.swift
//  ExpandableCollectionCell
//
//  Created by 朱彦谕 on 2021/9/15.
//

import UIKit

struct CategoryCollectionViewCellViewModel {
    let name: String
    let backgroundColor: UIColor
    let templateCollectionViewModels: [TemplateCollectionViewCellViewModel]
}

class CategoryCollectionViewCell: UICollectionViewCell {
    static let identifier = "CategoryCollectionViewCell"
    static let cellWidth = 100
    static let cellHeight = 100
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .medium)
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        contentView.layer.cornerRadius = 6
        contentView.layer.borderWidth = 1.5
        contentView.layer.borderColor = UIColor.quaternaryLabel.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = contentView.bounds
    }
    
    func configuer(with viewModel: CategoryCollectionViewCellViewModel) {
        contentView.backgroundColor = viewModel.backgroundColor
        label.text = viewModel.name
    }
}


