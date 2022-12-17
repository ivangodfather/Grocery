//
//  GroceryApp.swift
//  Grocery
//
//  Created by Iván Ruiz Monjo on 17/12/22.
//

import SwiftUI

@main
struct GroceryApp: App {
    var body: some Scene {
        WindowGroup {
            GroceryListView(store: .init(initialState: .init(), reducer: GroceryList()))
        }
    }
}
