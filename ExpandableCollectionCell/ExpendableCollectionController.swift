//
//  ExpendableCollectionController.swift
//  ExpendableCollectionController
//
//  Created by 朱彦谕 on 2021/9/15.
//

import UIKit
import CoreMedia

protocol ExpandedCellDelegate: NSObjectProtocol {
    func didSelect(at index: Int, realIndexPath: IndexPath)
}

// 用来构造cell的block
typealias CellConstructorClosure = ((Int, IndexPath) -> (UICollectionViewCell))
// 用来计算cell大小的block
typealias ExpendedCellSizeComputor = ((Int, IndexPath) -> (CGSize))

struct ExpandedCellInfo: Equatable {
    
    // MARK: Public Properties
    
    // 开始插入的位置的indexPath
    var insertIndexPath: IndexPath
    // 插入的个数
    var insertNum: Int = 0
    // 插入的IndexPaths
    var insertIndexPaths: [IndexPath] = []
    // delegate
    weak var delegate: ExpandedCellDelegate?
    
    var cellConstructor: CellConstructorClosure
    
    var cellSizeComputor: ExpendedCellSizeComputor
    
    // MARK: Lifecycle
    init(for indexPath: IndexPath, cellNum: Int, cellConstructor: @escaping CellConstructorClosure, cellSizeComputor: @escaping ExpendedCellSizeComputor) {
        self.insertIndexPath = indexPath
        self.insertNum = cellNum
        self.cellConstructor = cellConstructor
        self.cellSizeComputor = cellSizeComputor
        self.buildInsertIndexPaths()
    }
    
    // MARK: Public
    public static func ==(lhs: ExpandedCellInfo, rhs: ExpandedCellInfo) -> Bool {
        return lhs.insertIndexPaths.elementsEqual(rhs.insertIndexPaths)
    }
    
//    fileprivate func computedIndexPaths(from indexPath: IndexPath, offset: Int) -> IndexPath {
//        for i in 0...offset {
//
//        }
//    }
    fileprivate func isExpandedCell(at indexPath: IndexPath) -> Bool {
        return indexPath.section == indexPath.section && indexPath.item > insertIndexPath.item && indexPath.item <= (insertIndexPath.item + insertNum)
    }
    
    fileprivate func computeExpandedCellIndex(from indexPath: IndexPath) -> Int {
        return indexPath.row - insertIndexPath.row - 1
    }
    
    private mutating func buildInsertIndexPaths() {
        var indexPaths: [IndexPath] = []
        for i in 1...insertNum {
            var indexPath = insertIndexPath
            indexPath.item += i
            indexPaths.append(indexPath)
        }
        insertIndexPaths = indexPaths
    }
    
    fileprivate func isExceedInsertCells(for indexPath: IndexPath) -> Bool {
        return indexPath.item > insertIndexPath.item + insertNum
    }
    
    
//    func isHigherInSameSection(than hint: ExpandedCellInfo) -> Bool {
//        return hint.indexPath.section == indexPath.section
//            && hint.indexPath.row > indexPath.row
//    }
    
//    func computedIndexPath(from indexPath: IndexPath) -> IndexPath {
//        var computedIndexPath = indexPath
//        if indexPath.section == self.indexPath.section
//            && indexPath.row > self.indexPath.row {
//            computedIndexPath.decrementRow()
//        }
//        return computedIndexPath
//    }

}


typealias CollectionViewInfoProvider = UICollectionViewDelegate & UICollectionViewDataSource & UICollectionViewDelegateFlowLayout
typealias CompletionBlock = () -> ()
class ExpendableCollectionController: NSObject {
    private var proxy: ExpandableCollectionViewProxy?
    private var expendedCell: ExpandedCellInfo? {
        didSet {
            print("expendedCell")
        }
    }
    private weak var collectionView: UICollectionView?
    // 这里用叹号是因为数据源方法中必须要返回有效的cell
    private weak var infoProvider: CollectionViewInfoProvider?
    
    // MARK: Lifecycle
    init(with collectionView: UICollectionView, infoProvider: CollectionViewInfoProvider) {
        self.collectionView = collectionView
        self.infoProvider = infoProvider
        super.init()
        // todo
        proxy = ExpandableCollectionViewProxy(collectionDelegate: infoProvider, proxyDelegate: self)
        collectionView.dataSource = proxy
        collectionView.delegate = proxy
    }
    
    func expandCell(_ cell: ExpandedCellInfo, _ completion: @escaping CompletionBlock) {
        //resultCell.indexPath.incrementRow()
        guard !(expendedCell == cell) else {
            completion()
            return
        }
        if expendedCell != nil {
            unexpandCell(false) { [weak self] in
                self?.expendedCell = cell
                self?.collectionView?.performBatchUpdates({
                    self?.collectionView?.insertItems(at: cell.insertIndexPaths)
                }, completion: { (finished) in
                    self?.collectionView?.layoutIfNeeded()
                    completion()
                })
            }

        } else {
            self.expendedCell = cell
            self.collectionView?.performBatchUpdates({
                self.collectionView?.insertItems(at: cell.insertIndexPaths)
            }, completion: { [weak self] (finished) in
                self?.collectionView?.layoutIfNeeded()
                completion()
            })
        }
        
    }
    
    func unexpandCell(_ animated: Bool, _ completion: @escaping CompletionBlock) {
        guard let insertIndexPaths = expendedCell?.insertIndexPaths, !insertIndexPaths.isEmpty else {
            completion()
            return
        }
        
        expendedCell = nil

        if !animated {
            collectionView?.reloadData()
            completion()
        } else {
            collectionView?.performBatchUpdates({
                collectionView?.deleteItems(at: insertIndexPaths)
            }, completion: { [weak self] (finished) in
                self?.collectionView?.layoutIfNeeded()
                completion()
            })
        }
        

    }
}

extension ExpendableCollectionController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let expendedCell = expendedCell, expendedCell.isExpandedCell(at: indexPath) {
            let index = expendedCell.computeExpandedCellIndex(from: indexPath)
            expendedCell.delegate?.didSelect(at: index, realIndexPath: indexPath)
        } else  {
            var realIndexPath = indexPath
            if let expendedCell = expendedCell, expendedCell.isExceedInsertCells(for: indexPath) {
                realIndexPath.item -= expendedCell.insertNum
            }
            infoProvider?.collectionView?(collectionView, didSelectItemAt: realIndexPath)
        }
    }
}


extension ExpendableCollectionController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let expendedCell = expendedCell, expendedCell.isExpandedCell(at: indexPath) {
            let index = expendedCell.computeExpandedCellIndex(from: indexPath)
            let expandCell = expendedCell.cellConstructor(index, indexPath)
            return expandCell
        }
        var realIndexPath = indexPath
        if let expendedCell = expendedCell, expendedCell.isExceedInsertCells(for: indexPath) {
            realIndexPath.item -= expendedCell.insertNum
        }
        guard let realCell = infoProvider?.collectionView(collectionView, cellForItemAt: realIndexPath) else {
            fatalError()
        }
        return realCell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let rows = infoProvider?.collectionView(collectionView, numberOfItemsInSection: section) ?? 0
        guard let expandCell = expendedCell else {
            return rows
        }
        return expandCell.insertIndexPath.section == section ? rows + (expendedCell?.insertNum ?? 0) : rows
    }
}

extension ExpendableCollectionController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let expendedCell = expendedCell, expendedCell.isExpandedCell(at: indexPath) {
            let index = expendedCell.computeExpandedCellIndex(from: indexPath)
            return expendedCell.cellSizeComputor(index, indexPath)
        }
        var realIndexPath = indexPath
        if let expendedCell = expendedCell, expendedCell.isExceedInsertCells(for: indexPath) {
            realIndexPath.item -= expendedCell.insertNum
        }
        return infoProvider?.collectionView?(collectionView, layout: collectionViewLayout, sizeForItemAt: realIndexPath) ?? .zero
    }
}
