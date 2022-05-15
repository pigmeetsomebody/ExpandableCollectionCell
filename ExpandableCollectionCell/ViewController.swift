//
//  ViewController.swift
//  Carausel
//
//  Created by 朱彦谕 on 2021/9/14.
//

import UIKit
import Hero


protocol CollectionViewCellLayoutInfoDelegate {
    func calculateSize(with viewModel:CollectionViewCellViewModel) -> CGSize
}



class CollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private let collectionView: UICollectionView = {
        let flowLayout = AnimationTemplateSelectLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        flowLayout.itemSize = CGSize(width: 50, height: 50)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
        collectionView.register(TemplateCollectionViewCell.self, forCellWithReuseIdentifier: TemplateCollectionViewCell.identifier)
        
        return collectionView
    }()
    
    private var expendableCollectionController: ExpendableCollectionController?
    private var expandedCell: ExpandedCellInfo?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .clear
        view.addSubview(collectionView)
        
        expendableCollectionController = ExpendableCollectionController(with: collectionView, infoProvider: self)
        
//        collectionView.dataSource = self
//        collectionView.delegate = self
        
        //collectionView
        //collectionView.visibleCells[0].heroID
        
    }
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        let i: Int = 0
//        for indexPath in collectionView.indexPathsForVisibleItems {
//            let cell = collectionView.cellForItem(at: indexPath)
//            cell?.alpha = 0
//            cell?.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).concatenating(
//                CGAffineTransform(translationX: 0, y: 0)
//            )
//        }
//        //collectionView.visibleCells.first?.heroID = "skyWalker"
//        for indexpath in collectionView.indexPathsForVisibleItems {
//            let cell = collectionView.cellForItem(at: indexpath)
//            let cellWidth: CGFloat = 100
//            let cellSpace: CGFloat = 8
//            let transX:CGFloat = -(cellWidth + cellSpace) * CGFloat(indexpath.item) * 0.2
//            cell?.hero.modifiers = [.beginWith([.fade, .scale(0.2), .translate(CGPoint(x: transX, y: 0))])];
//        }
//    }
    
//    - (VPSlider *)intensitySlider {
//        if (!_intensitySlider) {
//            _intensitySlider = [[VPSlider alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width - sliderMargin * 2 - labelAreaWidth, sliderHeight) type:VPSliderTypeDoubleEnded];
//            [_intensitySlider setThumbImage:[UIImage imageNamed:@"icon_slider_control"] forState:UIControlStateNormal];
//            [_intensitySlider addTarget:self action:@selector(handleSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
//            [_intensitySlider addTarget:self action:@selector(handleTouchUpSlider:) forControlEvents:UIControlEventTouchUpInside];
//            [_intensitySlider addTarget:self action:@selector(handleTouchUpSlider:) forControlEvents:UIControlEventTouchUpOutside];
//        }
//        return _intensitySlider;
//    }
    //private let intensitySlider = 

    private func toggleItem(at indexPath: IndexPath) {
        guard expandedCell?.insertIndexPath != indexPath else {
            expendableCollectionController?.unexpandCell(true) {
            }
            expandedCell = nil
            return
        }
        let viewModel = categoryViewModels[indexPath.row]
        let cellConstructor: CellConstructorClosure = { [weak self] index, indexPath -> (UICollectionViewCell) in
//            let cellIdentifier = "\(HorizontalScrollCollectionViewCell.identifier)_\(indexPath.section)_\(indexPath.item)"
//            self?.collectionView.register(HorizontalScrollCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
            guard let templateCollectionCell = self?.collectionView.dequeueReusableCell(withReuseIdentifier: TemplateCollectionViewCell.identifier, for: indexPath) as? TemplateCollectionViewCell else { fatalError() }
            let templateViewModel = viewModel.templateCollectionViewModels[index]
            templateCollectionCell.configuer(with: templateViewModel)
//            templateCollectionCell.configure(with: CollectionViewCellViewModel(viewModels: viewModel.templateCollectionViewModels))
            return templateCollectionCell
        }
        let cellSizeComputor: ExpendedCellSizeComputor = { index, indexPath -> (CGSize) in
            // 根据count 和 itemsize, edgeInsets 计算cell 的size
            let cellW = HorizontalScrollCollectionViewCell.itemWidth
            //return HorizontalScrollCollectionViewCell.calculateSize(with: CollectionViewCellViewModel(viewModels: viewModel.templateCollectionViewModels))
            return CGSize(width: cellW, height: cellW)
        }
        let cellInfo = ExpandedCellInfo(for: indexPath, cellNum: viewModel.templateCollectionViewModels.count, cellConstructor: cellConstructor, cellSizeComputor: cellSizeComputor)
        expandedCell = cellInfo
        expendableCollectionController?.expandCell(cellInfo) {}
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        
    }
    private var waitingForFirstApppearAnimation = false
    func prepareForDisplayAnimation() {
        waitingForFirstApppearAnimation = true
    }
    
//    private let viewModels: [CollectionViewCellViewModel] = [
//        CollectionViewCellViewModel(viewModels: [
//            TemplateCollectionViewCellViewModel(name: "Apple", backgroundColor: .systemBlue),
//            TemplateCollectionViewCellViewModel(name: "Google", backgroundColor: .systemOrange),
//            TemplateCollectionViewCellViewModel(name: "Nvida", backgroundColor: .systemRed),
//            TemplateCollectionViewCellViewModel(name: "Intel", backgroundColor: .systemPink),
//            TemplateCollectionViewCellViewModel(name: "Facebook", backgroundColor: .systemGray),
//            TemplateCollectionViewCellViewModel(name: "VMWare", backgroundColor: .systemYellow),
//            TemplateCollectionViewCellViewModel(name: "AMD", backgroundColor: .tertiarySystemBackground),
//        ])
//    ]
    
    private let categoryViewModels: [CategoryCollectionViewCellViewModel] = [
        CategoryCollectionViewCellViewModel(name: "Category1", backgroundColor: .systemPink, templateCollectionViewModels: [
            TemplateCollectionViewCellViewModel(name: "Apple", backgroundColor: .systemBlue),
            TemplateCollectionViewCellViewModel(name: "Google", backgroundColor: .systemOrange),
            TemplateCollectionViewCellViewModel(name: "Nvida", backgroundColor: .systemRed),
            TemplateCollectionViewCellViewModel(name: "Intel", backgroundColor: .systemPink),
            TemplateCollectionViewCellViewModel(name: "Facebook", backgroundColor: .systemGray),
            TemplateCollectionViewCellViewModel(name: "VMWare", backgroundColor: .systemYellow),
            TemplateCollectionViewCellViewModel(name: "AMD", backgroundColor: .tertiarySystemBackground),
        ]),
        CategoryCollectionViewCellViewModel(name: "Category2", backgroundColor: .systemPink, templateCollectionViewModels: [
            TemplateCollectionViewCellViewModel(name: "Vogue", backgroundColor: .systemBlue),
            TemplateCollectionViewCellViewModel(name: "Google", backgroundColor: .systemOrange),
            TemplateCollectionViewCellViewModel(name: "Nvida", backgroundColor: .systemRed),
            TemplateCollectionViewCellViewModel(name: "Intel", backgroundColor: .systemPink),
            TemplateCollectionViewCellViewModel(name: "Facebook", backgroundColor: .systemGray),
            TemplateCollectionViewCellViewModel(name: "VMWare", backgroundColor: .systemYellow),
            TemplateCollectionViewCellViewModel(name: "AMD", backgroundColor: .tertiarySystemBackground),
        ]),
        CategoryCollectionViewCellViewModel(name: "Category3", backgroundColor: .systemPink, templateCollectionViewModels: [
            TemplateCollectionViewCellViewModel(name: "Apple", backgroundColor: .systemBlue),
            TemplateCollectionViewCellViewModel(name: "Google", backgroundColor: .systemOrange),
            TemplateCollectionViewCellViewModel(name: "Nvida", backgroundColor: .systemRed),
            TemplateCollectionViewCellViewModel(name: "Intel", backgroundColor: .systemPink),
            TemplateCollectionViewCellViewModel(name: "Facebook", backgroundColor: .systemGray),
            TemplateCollectionViewCellViewModel(name: "VMWare", backgroundColor: .systemYellow),
            TemplateCollectionViewCellViewModel(name: "AMD", backgroundColor: .tertiarySystemBackground),
        ]),
        CategoryCollectionViewCellViewModel(name: "Category4", backgroundColor: .systemPink, templateCollectionViewModels: [
            TemplateCollectionViewCellViewModel(name: "Apple", backgroundColor: .systemBlue),
            TemplateCollectionViewCellViewModel(name: "Google", backgroundColor: .systemOrange),
            TemplateCollectionViewCellViewModel(name: "Nvida", backgroundColor: .systemRed),
            TemplateCollectionViewCellViewModel(name: "Intel", backgroundColor: .systemPink),
            TemplateCollectionViewCellViewModel(name: "Facebook", backgroundColor: .systemGray),
            TemplateCollectionViewCellViewModel(name: "VMWare", backgroundColor: .systemYellow),
            TemplateCollectionViewCellViewModel(name: "AMD", backgroundColor: .tertiarySystemBackground),
        ]),
        CategoryCollectionViewCellViewModel(name: "Category5", backgroundColor: .systemPink, templateCollectionViewModels: [
            TemplateCollectionViewCellViewModel(name: "Apple", backgroundColor: .systemBlue),
            TemplateCollectionViewCellViewModel(name: "Google", backgroundColor: .systemOrange),
            TemplateCollectionViewCellViewModel(name: "Nvida", backgroundColor: .systemRed),
            TemplateCollectionViewCellViewModel(name: "Intel", backgroundColor: .systemPink),
            TemplateCollectionViewCellViewModel(name: "Facebook", backgroundColor: .systemGray),
            TemplateCollectionViewCellViewModel(name: "VMWare", backgroundColor: .systemYellow),
            TemplateCollectionViewCellViewModel(name: "AMD", backgroundColor: .tertiarySystemBackground),
        ]),
    ]
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let height: CGFloat = 120
        collectionView.frame = CGRect(x: 0, y: (view.bounds.size.height - height) / 2, width: view.bounds.size.width, height: height)
        
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryViewModels.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let viewModel = categoryViewModels[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as? CategoryCollectionViewCell else { fatalError() }
        cell.configuer(with: viewModel)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //let viewModel = categoryViewModels[indexPath.item]
        // 根据count 和 itemsize, edgeInsets 计算cell 的size
        //let size = HorizontalScrollCollectionViewCell.calculateSize(with: viewModel)
        return CGSize(width: CategoryCollectionViewCell.cellWidth, height: CategoryCollectionViewCell.cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //collectionView.scrollToItem(at: indexPath, at: .right, animated: true)
        
        toggleItem(at: indexPath)
        
    }

}
class ViewController: UIViewController {
    let pinkBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .systemPink
        btn.layer.cornerRadius = 6
        btn.layer.borderWidth = 1.5
        btn.layer.borderColor = UIColor.quaternaryLabel.cgColor
        btn.addTarget(self, action: #selector(handleButtonClicked), for: .touchUpInside)
        return btn
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        self.view.addSubview(pinkBtn)
        pinkBtn.heroID = "skyWalker"
        self.isHeroEnabled = true
    }
    
    override func viewWillLayoutSubviews() {
        let btnWidth:CGFloat = 64
        pinkBtn.frame = CGRect(x: 8, y: view.bounds.size.height - btnWidth - 8, width: btnWidth, height: btnWidth)
        
    }
    @objc func handleButtonClicked() {
        let vc = CollectionViewController()
        pinkBtn.hero.modifiers = [.fade]
        self.present(vc, animated: true, completion: nil)
    }
}

// MARK: - AnimationTemplateSelectLayout

private class AnimationTemplateSelectLayout: UICollectionViewFlowLayout {
    
    fileprivate var needInsertPaths: [IndexPath] = []
    fileprivate var needDeletePaths: [IndexPath] = []

    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)?.copy() as? UICollectionViewLayoutAttributes else { return nil }
        if needInsertPaths.contains(itemIndexPath) && itemIndexPath.item <= 5,
            let category = super.initialLayoutAttributesForAppearingItem(at: IndexPath(item: 0, section: itemIndexPath.section))?.copy() as? UICollectionViewLayoutAttributes {
            
            var frame = attributes.frame
            frame.origin.x = category.frame.midX - frame.width * 0.5
            attributes.frame = frame
            
            attributes.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            attributes.alpha = 0
            
        }
        
        return attributes
    }
    
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)?.copy() as? UICollectionViewLayoutAttributes else { return nil }
        if needDeletePaths.contains(itemIndexPath),
            let category = super.finalLayoutAttributesForDisappearingItem(at: IndexPath(item: 0, section: itemIndexPath.section))?.copy() as? UICollectionViewLayoutAttributes {
            
            var frame = attributes.frame
            frame.origin.x = category.frame.midX - frame.width * 0.5
            attributes.frame = frame
            
            attributes.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            attributes.alpha = 0
        }
        
        return attributes
    }
    
}
