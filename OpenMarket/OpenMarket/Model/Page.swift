//
//  Page.swift
//  OpenMarket
//
//  Created by Joey, Soll on 2021/08/11.
//

import Foundation

struct Page: Decodable {
    let page: Int
    let items: [Page.Item]
    
    struct Item: Decodable, Hashable {
        let id: Int
        let title: String
        let price: Int
        let currency: String
        let stock: Int
        let discountedPrice: Int?
        let thumbnails: [String]
        let registrationDate: Double
        
        enum CodingKeys: String, CodingKey {
            case id, title, price, currency, stock, thumbnails
            case discountedPrice = "discounted_price"
            case registrationDate = "registration_date"
        }
        
        static func == (lhs: Item, rhs: Item) -> Bool {
            lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}
