//
//  RecipeDetailedStepInfoFeature.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/12/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct RecipeDetailedStepInfoFeature {
    @ObservableState
    struct State: Equatable {
        var steps: IdentifiedArrayOf<RecipeStepFeature.State> = []
        
        init(recipe: Recipe?) {
            let steps = (recipe?.detailedSteps ?? []).map { RecipeStepFeature.State(step: $0) }
            self.steps = IdentifiedArray(uniqueElements: steps)
        }
    }
    
    enum Action {
        @CasePathable
        enum ViewAction {
            case addStepButtonTapped
        }
        
        case view(ViewAction)
        case step(IdentifiedAction<RecipeStepFeature.State.ID, RecipeStepFeature.Action>)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(.addStepButtonTapped):
                let newStep = CookingStep(title: "Step \(state.steps.count + 1)", detailedProcesses: [])
                state.steps.append(.init(step: newStep))
                return .none
                
            case let .step(.element(id, .delegate(.removeStepButtonTapped))):
                state.steps.remove(id: id)
                return .none
                
            case .step:
                return .none
            }
        }
    }
}

struct RecipeDetailedStepInfoView: View {
    @Bindable var store: StoreOf<RecipeDetailedStepInfoFeature>
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Detailed Steps")
                .font(.title3.bold())
                .padding(.top, 16)
            
            LazyVStack {
                ForEachStore(store.scope(state: \.steps, action: \.step)) { stepStore in
                    RecipeStepView(store: stepStore)
                }
            }
            
            HStack {
                Button {
                    store.send(.view(.addStepButtonTapped))
                } label: {
                    Label("Next Step", systemImage: "plus.circle")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(.gray)
                        )
                }
                .tint(.white)
                .padding([.horizontal, .bottom])
            }
        }
    }
}

@Reducer
struct RecipeStepFeature {
    @ObservableState
    struct State: Equatable, Identifiable {
        let id: UUID
        var title: String
        var processes: IdentifiedArrayOf<DetailProcessCellFeature.State> = []
        
        init(step: CookingStep) {
            id = step.id
            title = step.title
            processes = IdentifiedArray(uniqueElements: step.detailedProcesses.map { DetailProcessCellFeature.State(id: $0.id, process: $0)})
        }
    }
    
    enum Action {
        @CasePathable
        enum ViewAction {
            case titleChanged(String)
            case addProcessButtonTapped
        }
        
        @CasePathable
        enum Delegate {
            case removeStepButtonTapped
        }
        
        case view(ViewAction)
        case delegate(Delegate)
        case process(IdentifiedAction<DetailProcessCellFeature.State.ID, DetailProcessCellFeature.Action>)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(.titleChanged(let title)):
                state.title = title
                return .none
                
            case .view(.addProcessButtonTapped):
                let newProcess = CookingDetailedProcess(description: "")
                state.processes.append(.init(id: newProcess.id, process: newProcess))
                return .none
                
            case let .process(.element(id, .delegate(.removeButtonTapped))):
                state.processes.remove(id: id)
                return .none
                
            case let .process(.element(id, .delegate(.moveUpButtonTapped))):
                guard let index = state.processes.index(id: id),
                      index > 0 else
                { return .none }
                state.processes.swapAt(index, index - 1)
                return .none
                
            case let .process(.element(id, .delegate(.moveDownButtonTapped))):
                guard let index = state.processes.index(id: id),
                      index < state.processes.count - 1
                else { return .none }
                state.processes.swapAt(index, index + 1)
                return .none
                
            case .delegate, .process:
                return .none
            }
        }
        .forEach(\.processes, action: \.process) { DetailProcessCellFeature() }
    }
}

struct RecipeStepView: View {
    @Bindable var store: StoreOf<RecipeStepFeature>
    
    var body: some View {
        Section {
            ForEachStore(store.scope(state: \.processes, action: \.process)) { processStore in
                DetailedProcessCellView(store: processStore)
                
                if processStore.id != store.state.processes.last?.id {
                    Divider().padding(.vertical, 8)
                }
            }
        } header: {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    TextField(store.title, text: $store.title.sending(\.view.titleChanged))
                        .font(.headline)
                    
                    Spacer()
                    
                    Button {
                        store.send(.delegate(.removeStepButtonTapped))
                    } label: {
                        Image(systemName: "trash")
                    }
                }
                
                Rectangle()
                    .frame(height: 2)
                
                Text("Detailed process *")
                
                Text("Photo: Optional / Recipe: Required")
                    .foregroundStyle(.secondary)
            }
            .padding([.top, .horizontal])
        } footer: {
            HStack {
                Button {
                    store.send(.view(.addProcessButtonTapped))
                } label: {
                    Label("Add Ingredient", systemImage: "plus.circle")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(.gray)
                        )
                }
                .tint(.white)
                .padding([.horizontal, .bottom])
            }
        }
    }
}

@Reducer
struct DetailProcessCellFeature {
    @ObservableState
    struct State: Equatable, Identifiable {
        let id: UUID
        var process: CookingDetailedProcess
        
        static func == (lhs: DetailProcessCellFeature.State, rhs: DetailProcessCellFeature.State) -> Bool {
            lhs.id == rhs.id && lhs.process.id == rhs.process.id
        }
    }
    
    enum Action {
        @CasePathable
        enum ViewAction {
            case descriptionChanged(String)
        }
        
        @CasePathable
        enum Delegate {
            case removeButtonTapped
            case moveUpButtonTapped
            case moveDownButtonTapped
        }
        
        case view(ViewAction)
        case delegate(Delegate)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(.descriptionChanged(let text)):
                state.process.description = text
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}

struct DetailedProcessCellView: View {
    @Bindable var store: StoreOf<DetailProcessCellFeature>
    
    var body: some View {
        HStack(alignment: .top) {
            HStack {
                VStack(spacing: 0) {
                    Button {
                        store.send(.delegate(.moveUpButtonTapped))
                    } label: {
                        Image(systemName: "chevron.up")
                            .padding(.horizontal, 7)
                            .padding(.vertical, 9)
                            .background(
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(.clear)
                                    .strokeBorder(.gray)
                            )
                    }
                    .tint(.gray)
                    
                    Button {
                        store.send(.delegate(.moveDownButtonTapped))
                    } label: {
                        Image(systemName: "chevron.down")
                            .padding(.horizontal, 7)
                            .padding(.vertical, 9)
                            .background(
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(.clear)
                                    .strokeBorder(.gray)
                            )
                    }
                    .tint(.gray)
                }
                
                Button {
                    store.send(.delegate(.removeButtonTapped))
                } label: {
                    Image(systemName: "minus.circle")
                }
                .tint(.gray)
            }
            
            VStack(alignment: .leading) {
                TextField("Description here", text: $store.process.description.sending(\.view.descriptionChanged), axis: .vertical)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .foregroundStyle(.primary)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.clear)
                            .strokeBorder(.gray)
                    )
                    .lineLimit(5)
            }
        }
        .padding()
    }
}
