//
//  OpenMarket - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

class ItemsGridViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
//    private let manager = NetworkManager(session: URLSession.shared)
    private let manager = NetworkManager(session: MockURLSession())
    private var items: [Page.Item]?
    private var isNotLoading = true
    private var lastPage = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeItems()
        // MARK: 3번 방식 - itemSize로 계산하기 방식. Estimate Size는 스토리보드에서 바꿀 수 있어요
//        collectionView.collectionViewLayout = configureItemSize()
    }
    
    private func initializeItems() {
        let serverURL = "https://camp-open-market-2.herokuapp.com/items/\(lastPage)"
        let mockURL = MockURL.mockItems.description
        
        guard let url = URL(string: mockURL) else { return }
        
        manager.fetchData(url: url) { (result: Result<Page, Error>) in
            switch result {
            case .success(let decodedData):
                self.items = decodedData.items
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.indicator.stopAnimating()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func configureItemSize() -> UICollectionViewFlowLayout {
        collectionView.layoutIfNeeded()
        
        let layout = UICollectionViewFlowLayout()
        let defaultInset: CGFloat = 8
        let numberOfItemPerRow: CGFloat = 4
        let sizeRatio: CGFloat = 1.7
        
        layout.sectionInset = UIEdgeInsets(top: defaultInset,
                                           left: defaultInset,
                                           bottom: .zero,
                                           right: defaultInset)
        
        let contentWidth = collectionView.bounds.width
        
        let cellWidth = (contentWidth - layout.minimumInteritemSpacing) / numberOfItemPerRow
        let cellHeight = cellWidth * sizeRatio
        
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        
        return layout
    }
}

extension ItemsGridViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let gridItemCellID = "gridViewCell"
        guard let item = items?[indexPath.item],
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: gridItemCellID,
                                                            for: indexPath) as? GridItemCollectionViewCell
        else { return UICollectionViewCell() }
        
        cell.initialize(item: item, indexPath: indexPath, collectionView: collectionView)
        
        return cell
    }
}

extension ItemsGridViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let itemsCount = items?.count else { return }
        
        if indexPath.row == itemsCount - 4 && self.isNotLoading {
            loadMoreData(indexPath: indexPath)
        }
    }
    
    func loadMoreData(indexPath: IndexPath) {
        if self.isNotLoading {
            self.isNotLoading = false
            self.lastPage += 1
            let serverURL = "https://camp-open-market-2.herokuapp.com/items/\(lastPage)"
            
            guard let url = URL(string: serverURL) else { return }
            
            manager.fetchData(url: url) { (result: Result<Page, Error>) in
                switch result {
                case .success(let decodedData):
                    self.items?.append(contentsOf: decodedData.items)
                    DispatchQueue.main.async {
                        self.collectionView.reloadItems(at: [indexPath])
                        self.isNotLoading = true
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}

// MARK: 1, 2번 방식 - 메서드에서 셀크기를 리턴해주는 방식. Estimate Size는 스토리보드에서 바꿀 수 있어요
extension ItemsGridViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return CGSize.zero}
        let defaultInset: CGFloat = 8
        let numberOfItemPerRow: CGFloat = 4
        let sizeRatio: CGFloat = 1.7

        layout.sectionInset = UIEdgeInsets(top: defaultInset,
                                           left: defaultInset,
                                           bottom: .zero,
                                           right: defaultInset)

        let contentWidth = collectionView.bounds.width - (layout.sectionInset.left + layout.sectionInset.right)

        let cellWidth = (contentWidth - layout.minimumInteritemSpacing) / numberOfItemPerRow
        let cellHeight = cellWidth * sizeRatio

        return CGSize(width: cellWidth, height: cellHeight)
    }
}
