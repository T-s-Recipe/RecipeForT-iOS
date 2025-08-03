//
//  TokenInterceptor.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/3/25.
//

import Foundation
import Alamofire
import Moya

final class TokenInterceptor: RequestInterceptor {
    private let tokenStorage: TokenStorageProtocol
    
    init(tokenStorage: TokenStorageProtocol) {
        self.tokenStorage = tokenStorage
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse,
                response.statusCode == 401
        else { return completion(.doNotRetry) }
        
        var refreshToken: String?
        do {
            let data = try tokenStorage.fetch()
            let tokens = try JSONDecoder().decode(Tokens.self, from: data)
            refreshToken = tokens.refreshToken
        } catch {
            return completion(.doNotRetryWithError(NetworkServiceError.unauthorized))
        }
        
        guard let refreshToken else { return completion(.doNotRetry) }
        let requestDTO = TokenReissueRequestDTO(refreshToken: refreshToken)
        let endpoint = Endpoint.reissueToken(requestDTO)
        
        let tokenManagerPlugin = TokenManagerPlugin(tokenStorage: tokenStorage)
        let reissueProvider = MoyaProvider<Endpoint>(plugins: [tokenManagerPlugin])
        reissueProvider.request(endpoint) { result in
            switch result {
            case .success:
                return completion(.retry)
            case .failure(let error):
                return completion(.doNotRetryWithError(error))
            }
        }
    }
}
