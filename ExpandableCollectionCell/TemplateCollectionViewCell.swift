//
//  TemplateCollectionViewCell.swift
//  ExpandableCollectionCell
//
//  Created by 朱彦谕 on 2021/9/15.
//

import UIKit
struct TemplateCollectionViewCellViewModel {
    let name: String
    let backgroundColor: UIColor
}

class TemplateCollectionViewCell: UICollectionViewCell {
    static let identifier = "TemplateCollectionViewCell"
    static let cellWidth = 64
    static let cellHeight = 64
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14)
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
    
    func configuer(with viewModel: TemplateCollectionViewCellViewModel) {
        contentView.backgroundColor = viewModel.backgroundColor
        label.text = viewModel.name
    }
}
