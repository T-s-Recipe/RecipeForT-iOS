//
//  DetailedStepsInfoViewModel.swift
//  RecipeForT
//
//  Created by Swain Yun on 7/29/25.
//

import Foundation

protocol DetailedStepsInfoViewModelDelegate: AnyObject {
    var detailedSteps: [CookingStep] { get set }
}

@Observable @MainActor
final class DetailedStepsInfoViewModel {
    var detailedSteps: [CookingStep] {
        get { delegate?.detailedSteps ?? [] }
        set { delegate?.detailedSteps = newValue }
    }
    
    weak var delegate: DetailedStepsInfoViewModelDelegate?
    
    func onAddStep() {
        detailedSteps.append(.init(title: "Step \(detailedSteps.count + 1)", detailedProcesses: []))
    }
    
    func onRemoveStep(with id: UUID) {
        detailedSteps.removeAll(where: { $0.id == id })
    }
    
    func onAddDetailedProcess(stepID: UUID) {
        guard let index = detailedSteps.firstIndex(where: { $0.id == stepID }) else { return }
        detailedSteps[index].detailedProcesses.append(.init(description: ""))
    }
    
    func onRemoveDetailedProcess(stepID: UUID, processID: UUID) {
        guard let stepIndex = detailedSteps.firstIndex(where: { $0.id == stepID }),
              let processIndex = detailedSteps[stepIndex].detailedProcesses.firstIndex(where: { $0.id == processID })
        else { return }
        detailedSteps[stepIndex].detailedProcesses.remove(at: processIndex)
    }
    
    func onMoveDetailedProcessUp(stepID: UUID, processID: UUID) {
        guard let stepIndex = detailedSteps.firstIndex(where: { $0.id == stepID }),
              let processIndex = detailedSteps[stepIndex].detailedProcesses.firstIndex(where: { $0.id == processID })
        else { return }
        detailedSteps[stepIndex].detailedProcesses.move(fromOffsets: IndexSet(integer: processIndex), toOffset: processIndex - 1)
    }
    
    func onMoveDetailedProcessDown(stepID: UUID, processID: UUID) {
        guard let stepIndex = detailedSteps.firstIndex(where: { $0.id == stepID }),
              let processIndex = detailedSteps[stepIndex].detailedProcesses.firstIndex(where: { $0.id == processID })
        else { return }
        detailedSteps[stepIndex].detailedProcesses.move(fromOffsets: IndexSet(integer: processIndex), toOffset: processIndex + 2)
    }
}
