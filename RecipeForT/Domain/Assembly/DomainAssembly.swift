//
//  DomainAssembly.swift
//  RecipeForT
//
//  Created by Swain Yun on 7/25/25.
//

import Foundation
import Swinject

struct DomainAssembly: Assembly {
    func assemble(container: Container) {
        container.register(MemberModel.self) { resolver in
            MemberModel(memberRepository: resolver.resolve(MemberRepositoryProtocol.self)!)
        }
        .inObjectScope(.container)
    }
    
    func loaded(resolver: any Resolver) {
        guard let memberModel = resolver.resolve(MemberModel.self) else { return }
        memberModel.attemptAutoLogin()
    }
}
