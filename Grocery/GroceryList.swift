//
//  GroceryList.swift
//  Grocery
//
//  Created by Iván Ruiz Monjo on 17/12/22.
//

import ComposableArchitecture
import SwiftUI

struct GroceryListView: View {
    let store: StoreOf<GroceryList>
    struct ViewState: Equatable {
        let isAddGroceryPresented: Bool
        init(_ state: GroceryList.State) {
            isAddGroceryPresented = state.addGrocery != nil
        }
    }

    typealias A = GroceryList.Action
    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            NavigationStack {
                List {
                    ForEachStore(store.scope(state: \.groceries, action: GroceryList.Action.groceryRow)) { groceryRowStore in
                        GroceryRowView(store: groceryRowStore)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Add") {
                            viewStore.send(.addTapped)
                        }
                    }
                }
                .sheet(
                    isPresented: viewStore.binding(
                        get: \.isAddGroceryPresented,
                        send: GroceryList.Action.setAddGroceryPresented)
                ) {
                    NavigationStack {
                        IfLetStore(store.scope(state: \.addGrocery, action: A.addGrocery), then: AddGroceryView.init)
                            .navigationTitle("Add grocery")
                    }
                }
                .onAppear {
                    viewStore.send(.onAppear)
                }
            }
        }
    }
}

struct GroceryListView_Previews: PreviewProvider {
    static var previews: some View {
        GroceryListView(store: .init(
            initialState: .init(),
            reducer: GroceryList())
        )
    }
}

struct GroceryList: ReducerProtocol {
    struct State: Equatable {
        var addGrocery: AddGrocery.State?
        var groceries = IdentifiedArrayOf<GroceryRow.State>(uniqueElements: [])
    }


    enum Action: Equatable {
        case addTapped
        case addGrocery(AddGrocery.Action)
        case groceryRow(GroceryRow.State.ID, GroceryRow.Action)
        case setAddGroceryPresented(Bool)
        case onAppear
        case onGroceriesLoaded(TaskResult<[Grocery]>)
    }

    @Dependency(\.uuid) var uuidGenerator
    @Dependency(\.groceryDataClient) var groceryDataClient

    func setAddGroceryPresented(isPresented: Bool, state: inout State) -> EffectTask<Action> {
        let grocery = Grocery(id: uuidGenerator(), name: "", quantity: 1)
        state.addGrocery = isPresented ? .init(editGrocery: .init(grocery: grocery)) : nil
        return .none
    }

    var body: some ReducerProtocolOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .addGrocery(.onGrocerySaved(.success)):
                state.addGrocery = nil
                return loadGroceries()
            case .addGrocery(.cancelTapped):
                state.addGrocery = nil
                return .none
            case .addGrocery:
                return .none
            case .addTapped:
                return setAddGroceryPresented(isPresented: true, state: &state)
            case .groceryRow(let id, .deleteTapped):
                state.groceries.remove(id: id)
                return .none
            case .groceryRow:
                return .none
            case let .setAddGroceryPresented(isPresented):
                return setAddGroceryPresented(isPresented: isPresented, state: &state)
            case .onAppear:
                return loadGroceries()
            case .onGroceriesLoaded(.success(let grocery)):
                let groceriesState = grocery.map { GroceryRow.State(grocery: $0) }
                state.groceries = IdentifiedArray(uniqueElements: groceriesState)
                return .none
            case .onGroceriesLoaded(.failure(let error)):
                print(error)
                return .none
            }

        }
        .ifLet(\.addGrocery, action: /GroceryList.Action.addGrocery) {
            AddGrocery()
        }
        .forEach(\.groceries, action: /GroceryList.Action.groceryRow) {
            GroceryRow()
        }
    }

    private func loadGroceries() -> EffectTask<GroceryList.Action> {
        return .task {
            await .onGroceriesLoaded(
                TaskResult {
                    try await groceryDataClient.loadGroceries()
                }
            )
        }
    }
}
