//
//  TokenManagerPlugin.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/3/25.
//

import Foundation
import Moya

struct TokenManagerPlugin: PluginType {
    private let tokenStorage: TokenStorageProtocol
    
    init(tokenStorage: TokenStorageProtocol) {
        self.tokenStorage = tokenStorage
    }
    
    func prepare(_ request: URLRequest, target: any TargetType) -> URLRequest {
        guard let wrappedTarget = target as? MultiTarget,
              let endpoint = wrappedTarget.target as? Endpoint,
              endpoint.usingToken
        else {
            print("[TokenManagerPlugin] - Skipping token for request, Endpoint: \(target)")
            return request
        }
        
        var mutableRequest = request
        
        do {
            let data = try tokenStorage.fetch()
            let tokens = try JSONDecoder().decode(Tokens.self, from: data)
            mutableRequest.setValue("Bearer \(tokens.accessToken)", forHTTPHeaderField: "Authorization")
        } catch {
            print("[TokenManagerPlugin] - Failed to get token for request: \(error.localizedDescription)")
        }
        
        return mutableRequest
    }
    
    func didReceive(_ result: Result<Response, MoyaError>, target: any TargetType) {
        guard case .success(let response) = result,
              let endpoint = target as? Endpoint,
              endpoint.receivingToken,
              (200..<300).contains(response.statusCode)
        else { return }
        
        do {
            let responseDTO = try JSONDecoder().decode(AuthTokenResponseDTO.self, from: response.data)
            let tokens = Tokens(accessToken: responseDTO.accessToken, refreshToken: responseDTO.refreshToken)
            let data = try JSONEncoder().encode(tokens)
            try tokenStorage.store(data)
        } catch {
            print("[TokenManagerPlugin] - Failed to store tokens: \(error.localizedDescription)")
        }
    }
}
