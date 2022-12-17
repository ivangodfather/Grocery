//
//  GroceryRowView.swift
//  Grocery
//
//  Created by Iván Ruiz Monjo on 17/12/22.
//

import ComposableArchitecture
import SwiftUI

struct GroceryRow: ReducerProtocol {
    struct State: Identifiable, Equatable {
        let grocery: Grocery
        var id: UUID { grocery.id }
    }

    enum Action: Equatable {
        case deleteTapped
        case groceryDeleted(TaskResult<Grocery>)
    }

    @Dependency(\.groceryDataClient) var groceryDataClient

    var body: some ReducerProtocolOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .deleteTapped:
                return .task { [grocery = state.grocery] in
                    await .groceryDeleted(
                        TaskResult {
                            try await groceryDataClient.deleteGrocery(grocery)
                            return grocery
                        }
                    )
                }
            case .groceryDeleted:
                return .none
            }
        }
    }
}

struct GroceryRowView: View {
    let store: StoreOf<GroceryRow>

    var body: some View {
        WithViewStore(store, observe: \.grocery) { viewStore in
            LabeledContent(viewStore.name) {
                Text(viewStore.quantity.description)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) {
                    viewStore.send(.deleteTapped)
                } label: {
                    Text("Delete")
                }

            }
        }
    }
}

struct GroceryRowView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            GroceryRowView(store: .init(
                initialState: .init(grocery: .fish),
                reducer: GroceryRow())
            )
        }
    }
}
