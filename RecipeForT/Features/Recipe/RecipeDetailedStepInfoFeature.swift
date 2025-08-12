//
//  RecipeDetailedStepInfoFeature.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/12/25.
//

import SwiftUI

@MainActor
struct RecipeDetailedStepInfoFeature {
    @Bindable var state: EditRecipeState
}

extension RecipeDetailedStepInfoFeature: ViewFeature {
    enum UIEvent {
        case addStep
        case removeStep(UUID)
        case addProcess(stepID: UUID)
        case onRemoveProcess(stepID: UUID, processID: UUID)
        case onMoveProcessUp(stepID: UUID, processID: UUID)
        case onMoveProcessDown(stepID: UUID, processID: UUID)
    }
    
    func notify(_ event: UIEvent) {
        switch event {
        case .addStep:
            addStep()
        case .removeStep(let id):
            removeStep(id)
        case .addProcess(let stepID):
            addProcess(stepID)
        case .onRemoveProcess(let stepID, let processID):
            onRemoveProcess(stepID, processID)
        case .onMoveProcessUp(let stepID, let processID):
            onMoveProcessUp(stepID, processID)
        case .onMoveProcessDown(let stepID, let processID):
            onMoveProcessDown(stepID, processID)
        }
    }
}

extension RecipeDetailedStepInfoFeature: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Detailed Steps")
                .font(.title3.bold())
                .padding(.top, 16)
            
            LazyVStack {
                ForEach($state.steps) { $step in
                    Section {
                        ForEach($step.detailedProcesses) { $process in
                            DetailedProcessCell(process: $process) {
                                notify(.onRemoveProcess(stepID: step.id, processID: process.id))
                            } onMoveUp: {
                                notify(.onMoveProcessUp(stepID: step.id, processID: process.id))
                            } onMoveDown: {
                                notify(.onMoveProcessDown(stepID: step.id, processID: process.id))
                            }
                            
                            if process.id != step.detailedProcesses.last?.id {
                                Divider().padding(.vertical, 8)
                            }
                        }
                    } header: {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                TextField(step.title, text: $step.title)
                                    .font(.headline)
                                
                                Spacer()
                                
                                Button {
                                    notify(.removeStep(step.id))
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
                                notify(.addProcess(stepID: step.id))
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
            
            HStack {
                Button {
                    notify(.addStep)
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

private extension RecipeDetailedStepInfoFeature {
    func addStep() {
        state.steps.append(.init(title: "Step \(state.steps.count + 1)"))
    }
    
    func removeStep(_ id: UUID) {
        state.steps.removeAll(where: { $0.id == id })
    }
    
    func addProcess(_ stepID: UUID) {
        guard let index = state.steps.firstIndex(where: { $0.id == stepID }) else { return }
        state.steps[index].detailedProcesses.append(.init(description: ""))
    }
    
    func onRemoveProcess(_ stepID: UUID, _ processID: UUID) {
        guard let stepIndex = state.steps.firstIndex(where: { $0.id == stepID }),
              let processIndex = state.steps[stepIndex].detailedProcesses.firstIndex(where: { $0.id == processID })
        else { return }
        state.steps[stepIndex].detailedProcesses.remove(at: processIndex)
    }
    
    func onMoveProcessUp(_ stepID: UUID, _ processID: UUID) {
        guard let stepIndex = state.steps.firstIndex(where: { $0.id == stepID }),
              let processIndex = state.steps[stepIndex].detailedProcesses.firstIndex(where: { $0.id == processID })
        else { return }
        state.steps[stepIndex].detailedProcesses.swapAt(processIndex, processIndex - 1)
    }
    
    func onMoveProcessDown(_ stepID: UUID, _ processID: UUID) {
        guard let stepIndex = state.steps.firstIndex(where: { $0.id == stepID }),
              let processIndex = state.steps[stepIndex].detailedProcesses.firstIndex(where: { $0.id == processID })
        else { return }
        state.steps[stepIndex].detailedProcesses.swapAt(processIndex, processIndex + 1)
    }
}

struct DetailedProcessCell: View {
    @Binding var process: CookingDetailedProcess
    
    let onRemove: () -> Void
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            HStack {
                VStack(spacing: 0) {
                    Button {
                        onMoveUp()
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
                        onMoveDown()
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
                    onRemove()
                } label: {
                    Image(systemName: "minus.circle")
                }
                .tint(.gray)
            }
            
            VStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 5)
                    .fill(.clear)
                    .strokeBorder(.gray)
                    .frame(width: 80, height: 60)
                    .overlay {
                        Image(systemName: "camera.fill")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .padding(16)
                            .foregroundStyle(.gray)
                    }
                
                TextField("Description here", text: $process.description, axis: .vertical)
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
