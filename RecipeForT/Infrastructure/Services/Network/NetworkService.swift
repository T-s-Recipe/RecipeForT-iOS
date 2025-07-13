//
//  NetworkService.swift
//  RecipeForT
//
//  Created by Swain Yun on 6/25/25.
//

import Foundation
import Moya

//protocol NetworkServiceProtocol {
//    func request<T: TargetType>(_ endpoint: T) async throws -> Data
//}
//
//enum NetworkError: Error {
//    case invalidResponse
//    case decodingFailed
//}
//
//final class NetworkService {
//    private let provider = MoyaProvider<MultiTarget>()
//    
//    private func performResult(_ result: Result<Response, MoyaError>) throws -> Data {
//        switch result {
//        case .success(let response):
//            <#code#>
//        case .failure(let error):
//            <#code#>
//        }
//    }
//    
//    private func mapError(_ error: MoyaError) -> NetworkError {
//        
//    }
//}
//
//// MARK: - NetworkServiceProtocol Conformation
//extension NetworkService: NetworkServiceProtocol {
//    func request<T: TargetType>(_ endpoint: T) async throws -> Data {
//        return try await withCheckedThrowingContinuation { continuation in
//            provider.request(MultiTarget(endpoint)) { result in
//                <#code#>
//            }
//        }
//    }
//}
