//
//  ContentViewModel.swift
//  RecipeForT
//
//  Created by Swain Yun on 6/10/25.
//

import SwiftUI

protocol RouterProtocol {
    associatedtype Destination: Routable where Destination == Route
    associatedtype Content: View
    
    var path: NavigationPath { get set }
    var sheet: Destination? { get set }
    var fullScreenCover: Destination? { get set }
    
    @ViewBuilder func view(to destination: Destination) -> Content
    func route(to destination: Destination)
    func dismiss()
    func popToRoot()
}

protocol Routable: Identifiable, Hashable {
    associatedtype Content: View
    
    var presentingType: PresentingType { get }
    
    @ViewBuilder func view(with router: Router) -> Content
}

extension Routable {
    var id: String { String(describing: self) }
}

enum PresentingType {
    case push
    case sheet
    case fullScreenCover
}

enum Route: Routable {
    case mainView
    case recipeUploadView
    case myPageView
    case recipeGuideView(Recipe)
    
    var presentingType: PresentingType {
        switch self {
        case .mainView: .push
        case .recipeUploadView: .push
        case .myPageView: .push
        case .recipeGuideView: .push
        }
    }
    
    @ViewBuilder func view(with router: Router) -> some View {
        switch self {
        case .mainView: MainView()
        case .recipeUploadView: Text("레시피 업로드 화면")
        case .myPageView: Text("마이페이지 화면")
        case .recipeGuideView(let recipe): RecipeGuideView(recipe: recipe)
        }
    }
}

extension Route: Equatable {
    static func == (lhs: Route, rhs: Route) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

extension Route: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

final class Router: ObservableObject, RouterProtocol {
    typealias Destination = Route
    
    @Published var path = NavigationPath()
    @Published var sheet: Destination?
    @Published var fullScreenCover: Destination?
    
    private var isModalPresented: Bool {
        sheet != nil || fullScreenCover != nil
    }
    
    private func _push(_ destination: Destination) {
        path.append(destination)
    }
    
    private func _sheet(_ destination: Destination) {
        guard isModalPresented == false else { return }
        sheet = destination
    }
    
    private func _fullScreenCover(_ destination: Destination) {
        guard isModalPresented == false else { return }
        fullScreenCover = destination
    }
}

// MARK: - Interfaces
extension Router {
    @ViewBuilder func view(to destination: Destination) -> some View {
        destination.view(with: self)
            .environmentObject(self)
    }
    
    func route(to destination: Destination) {
        switch destination.presentingType {
        case .push: _push(destination)
        case .sheet: _sheet(destination)
        case .fullScreenCover: _fullScreenCover(destination)
        }
    }
    
    func dismiss() {
        guard isModalPresented == false else {
            fullScreenCover = nil
            sheet = nil
            return
        }
        
        guard path.isEmpty == false else { return }
        path.removeLast()
    }
    
    func popToRoot() {
        if isModalPresented {
            fullScreenCover = nil
            sheet = nil
        }
        
        guard path.isEmpty == false else { return }
        path.removeLast(path.count)
    }
}
