//
//  AddGroceryView.swift
//  Grocery
//
//  Created by Iván Ruiz Monjo on 17/12/22.
//

import ComposableArchitecture
import SwiftUI

struct AddGrocery: ReducerProtocol {
    struct State: Equatable {
        var editGrocery: EditGrocery.State
    }

    enum Action: Equatable {
        case editGrocery(EditGrocery.Action)
        case cancelTapped
        case onGrocerySaved(TaskResult<Grocery>)
        case saveTapped
    }

    @Dependency(\.groceryDataClient) var groceryDataClient

    var body: some ReducerProtocolOf<Self> {
        Scope(state: \.editGrocery, action: /Action.editGrocery) {
            EditGrocery()
        }
        Reduce<State, Action> { state, action in
            switch action {
            case .cancelTapped:
                return .none
            case .editGrocery:
                return .none
            case .onGrocerySaved:
                return .none
            case .saveTapped:
                return .task { [grocery = state.editGrocery.grocery] in
                    await .onGrocerySaved(
                        TaskResult {
                            try await groceryDataClient.saveGrocery(grocery)
                            return grocery
                        }
                    )
                }
            }
        }
    }
}

struct AddGroceryView: View {
    let store: StoreOf<AddGrocery>

    var body: some View {
        Form {
            EditGroceryView(store: store.scope(state: \.editGrocery, action: AddGrocery.Action.editGrocery))
        }.toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    ViewStore(store).send(.saveTapped)
                } label: {
                    Text("Save")
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    ViewStore(store).send(.cancelTapped)
                } label: {
                    Text("Cancel")
                }
            }
        }
    }
}

struct AddGroceryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AddGroceryView(store: .init(
                initialState: .init(editGrocery: .init(grocery: .fish)),
                reducer: AddGrocery())
            )
        }
    }
}
