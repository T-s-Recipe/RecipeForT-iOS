//
//  Router.swift
//  RecipeForT
//
//  Created by Swain Yun on 6/20/25.
//

import SwiftUI

protocol RouterProtocol {
    associatedtype Destination: Routable where Destination == Route
    associatedtype Content: View
    
    var path: NavigationPath { get set }
    var sheet: Destination? { get set }
    var fullScreenCover: Destination? { get set }
    var floater: FloaterItem? { get set }
    
    @ViewBuilder func view(to destination: Destination) async -> Content
    func route(to destination: Destination)
    func dismiss()
    func popToRoot()
    func presentFloater(role: FloaterItem.Role, message: String)
}

protocol Routable: Identifiable, Hashable {
    associatedtype Content: View
    
    var presentingType: PresentingType { get }
    
    @ViewBuilder func view(with router: Router) async -> Content
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
    case searchView
    case editRecipeView(recipe: Recipe?)
    case myPageView
    case recipeGuideView(Recipe)
    case loginView
    
    var presentingType: PresentingType {
        switch self {
        case .mainView: .push
        case .searchView: .push
        case .editRecipeView: .fullScreenCover
        case .myPageView: .push
        case .recipeGuideView: .push
        case .loginView: .push
        }
    }
    
    @MainActor
    @ViewBuilder func view(with router: Router) -> some View {
        switch self {
        case .mainView: RecipeListFeature()
        case .searchView: SearchFeature()
        case .editRecipeView(let recipe): EditRecipeFeature(recipe: recipe)
        case .myPageView: PreferenceFeature()
        case .recipeGuideView(let recipe): RecipeGuideFeature(recipe: recipe)
        case .loginView: AuthFeature()
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

@Observable
final class Router: RouterProtocol {
    typealias Destination = Route
    
    var path = NavigationPath()
    var sheet: Destination?
    var fullScreenCover: Destination?
    var floater: FloaterItem?
    
    private var isModalPresented: Bool {
        sheet != nil || fullScreenCover != nil
    }
    
    private func _push(_ destination: Destination) {
        path.append(destination)
    }
    
    private func __sheet(_ destination: Destination) {
        guard isModalPresented == false else { return }
        sheet = destination
    }
    
    private func __fullScreenCover(_ destination: Destination) {
        guard isModalPresented == false else { return }
        fullScreenCover = destination
    }
}

// MARK: - Interfaces
extension Router {
    @MainActor @ViewBuilder func view(to destination: Destination) -> some View {
        destination.view(with: self)
            .environment(self)
    }
    
    func route(to destination: Destination) {
        switch destination.presentingType {
        case .push: _push(destination)
        case .sheet: __sheet(destination)
        case .fullScreenCover: __fullScreenCover(destination)
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
    
    func presentFloater(role: FloaterItem.Role = .normal, message: String) {
        let floaterItem = FloaterItem(role: role, message: message)
        self.floater = floaterItem
    }
}
