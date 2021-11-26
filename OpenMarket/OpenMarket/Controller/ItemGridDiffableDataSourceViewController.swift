//
//  ItemGridDiffableDataSourceViewController.swift
//  OpenMarket
//
//  Created by Dasoll Park on 2021/11/24.
//

import UIKit

class ItemGridDiffableDataSourceViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet private weak var indicator: UIActivityIndicatorView!
    
    private let manager = NetworkManager(session: URLSession.shared)
    private var items: [Page.Item]?
    private var itemListDataSource: UICollectionViewDiffableDataSource<ItemListSection, Page.Item>?
    
    private enum ItemListSection: Int {
        case main
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initializeItems()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.collectionViewLayout = createLayout()
        configureDataSource()
        applySnapshot()
    }
    
    private func initializeItems() {
        let serverURL = "https://camp-open-market-2.herokuapp.com/items/\(1)"
        
        guard let url = URL(string: serverURL) else { return }
        
        manager.fetchData(url: url) { [weak self] (result: Result<Page, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let decodedData):
                self.items = decodedData.items
                self.applySnapshot()
                DispatchQueue.main.async {
                    self.indicator.stopAnimating()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    private func configureDataSource() {
        let dataSource = UICollectionViewDiffableDataSource<ItemListSection, Page.Item>(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "gridViewCell",
                    for: indexPath) as? GridItemCollectionViewCell else {
                        print("셀 생성 실패")
                        return GridItemCollectionViewCell()
                    }
                cell.initialize(item: item)
                return cell
            })
        
        itemListDataSource = dataSource
    }
    
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<ItemListSection, Page.Item>()
        snapshot.appendSections([.main])
        guard let items = items else {
            print("items가 nil")
            return
        }
        snapshot.appendItems(items)
        itemListDataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(0.45))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        let spacing = CGFloat(10)
        group.interItemSpacing = .fixed(spacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}
