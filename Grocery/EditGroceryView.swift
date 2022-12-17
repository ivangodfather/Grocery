//
//  EditGroceryView.swift
//  Grocery
//
//  Created by Iván Ruiz Monjo on 17/12/22.
//

import ComposableArchitecture
import SwiftUI

struct EditGrocery: ReducerProtocol {
    struct State: Equatable {
        var grocery: Grocery
    }

    enum Action: Equatable {
        case nameChanged(String)
        case decrementTapped
        case incrementTapped
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .nameChanged(let name):
                state.grocery.name = name
                return .none
            case .decrementTapped:
                state.grocery.quantity -= 1
                return .none
            case .incrementTapped:
                state.grocery.quantity += 1
                return .none
            }
        }
    }
}

struct EditGroceryView: View {
    let store: StoreOf<EditGrocery>
    typealias A = EditGrocery.Action
    var body: some View {
        WithViewStore(store, observe: \.grocery) { viewStore in
            TextField("Grocery name", text: viewStore.binding(get: \.name, send: A.nameChanged))
            Stepper("Quantity \(viewStore.quantity.description)") {
                viewStore.send(.incrementTapped)
            } onDecrement: {
                viewStore.send(.decrementTapped)
            }
        }
    }
}

struct EditGroceryView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            EditGroceryView(store: .init(
                initialState: .init(grocery: .fish),
                reducer: EditGrocery())
            )
        }
    }
}
