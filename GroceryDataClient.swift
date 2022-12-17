//
//  GroceryDataClient.swift
//  Grocery
//
//  Created by Iván Ruiz Monjo on 17/12/22.
//

import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay

struct GroceryDataClient {
    var loadGroceries: () async throws -> [Grocery]
    var saveGrocery: (Grocery) async throws -> Void
    var deleteGrocery: (Grocery) async throws -> Void
}

extension DependencyValues {
    var groceryDataClient: GroceryDataClient {
        get { self[GroceryDataClient.self] }
        set { self[GroceryDataClient.self] = newValue }
    }
}

extension GroceryDataClient: DependencyKey {
    static var liveValue: GroceryDataClient {
        .init(
            loadGroceries: loadGroceries,
            saveGrocery: { grocery in
                let groceries = try await loadGroceries() + [grocery]
                let encoded = try JSONEncoder().encode(groceries)
                UserDefaults.standard.set(encoded, forKey: "groceries")
                try await Task.sleep(for: .milliseconds(100))
            },
            deleteGrocery: { grocery in
                var groceries = try await loadGroceries()
                groceries.removeAll { $0.id == grocery.id }
                let encoded = try JSONEncoder().encode(groceries)
                UserDefaults.standard.set(encoded, forKey: "groceries")
                try await Task.sleep(for: .milliseconds(100))
            }
        )
    }

    private static func loadGroceries() async throws -> [Grocery] {
        guard let data = UserDefaults.standard.data(forKey: "groceries") else { return [] }
        try await Task.sleep(for: .milliseconds(100))
        let decoded = try JSONDecoder().decode([Grocery].self, from: data)
        return decoded
    }

    static var testValue: GroceryDataClient {
        GroceryDataClient(
            loadGroceries: unimplemented("GroceryDataClient.loadGroceries"),
            saveGrocery: unimplemented("GroceryDataClient.saveGroceries"),
            deleteGrocery: unimplemented("GroceryDataClient.deleteGroceries")
        )
    }

    static var previewValue: GroceryDataClient {
        var values = [Grocery]()
        values.append(.potatoes)
        return GroceryDataClient(
            loadGroceries: {
                return values
            },
            saveGrocery: { grocery in
                values.append(grocery)
            }, deleteGrocery: { grocery  in
                values.removeAll {  $0.id == grocery.id }
            }
        )
    }

    static var inMemory: Self {
        var values = [Grocery]()
        return GroceryDataClient(
            loadGroceries: {
                return values
            },
            saveGrocery: { grocery in
                values.append(grocery)
            }, deleteGrocery: { grocery  in
                values.removeAll {  $0.id == grocery.id }
            }
        )
    }

    enum GroceryDataClientError: Error {
        case diskCorrupted
        case diskFull
    }

    static var failureValue = Self (loadGroceries: {
        throw GroceryDataClientError.diskCorrupted
    }, saveGrocery: { _ in
        throw GroceryDataClientError.diskFull
    }, deleteGrocery: { _ in
        throw GroceryDataClientError.diskCorrupted
    })
}
