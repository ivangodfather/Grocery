//
//  GroceryTests.swift
//  GroceryTests
//
//  Created by Iván Ruiz Monjo on 19/12/22.
//

@testable import Grocery
import ComposableArchitecture
import XCTest

@MainActor
final class GroceryTests: XCTestCase {

    let banana = Grocery(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!, name: "banana", quantity: 0)

    func testEditGrocery() {
        let testStore = TestStore(initialState: .init(grocery: banana), reducer: EditGrocery())

        testStore.send(.incrementTapped) {
            $0.grocery.quantity = 1
        }

        testStore.send(.decrementTapped) {
            $0.grocery.quantity = 0
        }

        testStore.send(.nameChanged("bananas")) {
            $0.grocery.name = "bananas"
        }
    }

    func testAddGrocery() async {
        let testStore = TestStore(
            initialState: GroceryList.State(addGrocery: nil, groceries: []),
            reducer: GroceryList()
        )
        let chicken = Grocery(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
            name: "Chicken",
            quantity: 1
        )
        testStore.dependencies.uuid = .incrementing
        testStore.dependencies.groceryDataClient = .inMemory

        await testStore.send(.onAppear)

        await testStore.receive(.onGroceriesLoaded(.success([])))

        await testStore.send(.addTapped) {
            $0.addGrocery = .init(editGrocery: .init(
                grocery: .init(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                    name: "",
                    quantity: 1
                ))
            )
        }

//        testStore.exhaustivity = .off
        await testStore.send(.addGrocery(.editGrocery(.nameChanged("Chicken")))) {
            $0.addGrocery?.editGrocery.grocery.name = "Chicken"

        }
//        testStore.exhaustivity = .on

        await testStore.send(.addGrocery(.saveTapped))

        await testStore.receive(.addGrocery(.onGrocerySaved(.success(chicken)))) {
            $0.addGrocery = nil
        }

        await testStore.receive(.onGroceriesLoaded(.success([chicken]))) {
            $0.groceries = [.init(grocery: chicken)]
        }
    }

}
