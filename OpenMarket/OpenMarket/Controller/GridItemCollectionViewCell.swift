//
//  GridItemCollectionViewCell.swift
//  OpenMarket
//
//  Created by 홍정아 on 2021/08/17.
//

import UIKit

class GridItemCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var discountedPriceLabel: UILabel!
    @IBOutlet weak var stockLabel: UILabel!
    
    private var urlString: String?
    
    func initialize(item: Page.Item, indexPath: IndexPath, collectionView: UICollectionView) {
        updateImage(item: item, indexPath: indexPath, collectionView: collectionView)
        configureLabels(item: item)
        configureCellBorder()
    }
    
    private func updateImage(item: Page.Item, indexPath: IndexPath, collectionView: UICollectionView) {
        let currentURLString = item.thumbnails[0]
        self.urlString = currentURLString
        
        ImageLoader.shared.loadImage(from: currentURLString) { imageData in
            print("-indexPath(for:) \(collectionView.indexPath(for: self))")
            print("cellForItem(at:) \(collectionView.cellForItem(at: indexPath)?.frame.width)")
            
            // MARK: indexPath 비교
            if indexPath == collectionView.indexPath(for: self) {
                self.thumbnailImageView?.image = imageData
            }
            
            // MARK: 셀의 프로퍼티 비교
//            if self.urlString == currentURLString {
//                self.thumbnailImageView?.image = imageData
//            }
        }
    }
    
    private func configureLabels(item: Page.Item) {
        self.titleLabel.text = item.title
        
        handlePriceLabel(item: item)
        handleStockLabel(item: item)
    }
    
    private func handlePriceLabel(item: Page.Item) {
        let priceWithCurrency = combine(price: format(item.price), currency: item.currency)
        
        if let discountedPrice = item.discountedPrice {
            let discountAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.red,
                .strikethroughStyle: true
            ]
            
            discountedPriceLabel.isHidden = false
            self.discountedPriceLabel.text = combine(price: format(discountedPrice),
                                                     currency: item.currency)
            self.priceLabel.attributedText = NSAttributedString(string: priceWithCurrency,
                                                                attributes: discountAttributes)
        } else {
            discountedPriceLabel.isHidden = true
            self.priceLabel.text = priceWithCurrency
        }
    }
    
    private func handleStockLabel(item: Page.Item) {
        let outOfStock = "품절"
        let residualQuantity = "잔여수량 : "
        
        if item.stock == .zero {
            self.stockLabel.text = outOfStock
            self.stockLabel.textColor = .orange
        } else {
            self.stockLabel.text = residualQuantity + item.stock.description
        }
    }
    
    private func combine(price: String, currency: String) -> String {
        return currency + " " + price
    }
    
    private func format(_ number: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal

        if let formattedNumber = numberFormatter.string(from: number as NSNumber) {
            return formattedNumber
        }
        return number.description
    }
    
    private func configureCellBorder() {
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.cornerRadius = 10
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.thumbnailImageView.image = nil
        self.priceLabel.attributedText = nil
        self.stockLabel.textColor = .lightGray
    }
}
