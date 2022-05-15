//
//  HorizontalScrollCollectionViewCell.swift
//  Carausel
//
//  Created by 朱彦谕 on 2021/9/14.
//

import UIKit

struct CollectionViewCellViewModel {
    let viewModels: [TemplateCollectionViewCellViewModel]
}

class HorizontalScrollCollectionViewCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let viewModel = viewModels[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TemplateCollectionViewCell.identifier, for: indexPath) as? TemplateCollectionViewCell else { fatalError() }
        cell.configuer(with: viewModel)
        return cell
    }
    
    static let identifier = "HorizontalScrollCollectionViewCell"
    static let itemWidth: CGFloat = 64
    static let horizontalSpacing: CGFloat = 4
    static let verticalSpacing: CGFloat = 4
    
    class func calculateSize(with viewModel:CollectionViewCellViewModel) -> CGSize {
        var height: CGFloat = 0
        var width: CGFloat = 0
        if viewModel.viewModels.count > 0 {
            let itemCount = viewModel.viewModels.count
            let itemHeight = HorizontalScrollCollectionViewCell.itemWidth
            height = itemHeight + verticalSpacing * 2
            width =
                CGFloat(viewModel.viewModels.count) * itemWidth + CGFloat(itemCount - 1) * horizontalSpacing
        }
        return CGSize(width: width, height: height)
    }
    
    private var viewModels: [TemplateCollectionViewCellViewModel] = []
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = horizontalSpacing
        layout.sectionInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TemplateCollectionViewCell.self, forCellWithReuseIdentifier: TemplateCollectionViewCell.identifier)
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemBlue
        contentView.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        superview?.layoutSubviews()
        collectionView.frame = contentView.bounds
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    func configure(with viewModel: CollectionViewCellViewModel) {
        self.viewModels = viewModel.viewModels
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //let width: CGFloat = contentView.frame.size.width / 2.5
        return CGSize(width: HorizontalScrollCollectionViewCell.itemWidth, height: HorizontalScrollCollectionViewCell.itemWidth)
    }
    
    
}
