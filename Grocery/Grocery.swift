//
//  Grocery.swift
//  Grocery
//
//  Created by Iván Ruiz Monjo on 17/12/22.
//

import Foundation

struct Grocery: Equatable, Codable {
    let id: UUID
    var name: String
    var quantity: Int
}

extension Grocery {
    static let fish = Grocery(id: UUID(uuidString: "00000000-0000-0000-C000-000000000046")!, name: "fish", quantity: 1)
    static let potatoes = Grocery(id: UUID(uuidString: "00000000-0000-0000-C000-000000000047")!, name: "potatoes", quantity: 1)

}
