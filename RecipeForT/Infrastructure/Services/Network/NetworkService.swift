//
//  NetworkService.swift
//  RecipeForT
//
//  Created by Swain Yun on 6/25/25.
//

import Foundation
import Moya

protocol NetworkServiceProtocol: Sendable {
    func request<T>(_ endpoint: T) async throws -> NetworkResponse where T: TargetType
}

enum NetworkServiceError: Error {
    case invalidResponse                  // 잘못된 HTTP 상태 코드
    case encodingFailed                   // 요청 인코딩 실패
    case decodingFailed                   // 응답 디코딩 실패
    case networkFailure                   // 네트워크 연결 실패 (예: 인터넷 끊김)
    case requestMapping                   // 요청 URL 또는 파라미터 매핑 실패
    case serverError                      // 서버 내부 에러 (500번대)
    case unauthorized                     // 인증 실패 (401)
    case notFound                         // 리소스 없음 (404)
    case timeout                          // 요청 시간 초과
}

struct NetworkResponse: Sendable {
    let statusCode: Int
    let data: Data
}

final class NetworkService: @unchecked Sendable {
    private let provider: MoyaProvider<MultiTarget>
    
    init(tokenStorage: TokenStorageProtocol) {
        let interceptor = TokenInterceptor(tokenStorage: tokenStorage)
        let session = Session(interceptor: interceptor)
        let plugins = [TokenManagerPlugin(tokenStorage: tokenStorage)]
        self.provider = MoyaProvider<MultiTarget>(session: session, plugins: plugins)
    }
}

// MARK: - NetworkServiceProtocol Conformation
extension NetworkService: NetworkServiceProtocol {
    func request<T>(_ endpoint: T) async throws -> NetworkResponse where T: TargetType {
        do {
            print("[NetworkService] - Requesting: \(String(describing: endpoint))")
            let response = try await provider.asyncRequest(MultiTarget(endpoint))
            
            if let responseString = String(data: response.data, encoding: .utf8) { print("\n\(responseString)") }
            return response
        } catch let error as NetworkServiceError {
            print("Network service error: \(error)")
            throw error
        } catch {
            print("Unexpected error: \(error.localizedDescription)")
            throw NetworkServiceError.networkFailure
        }
    }
}

// MARK: - MoyaProvider + HelperMethods
extension MoyaProvider {
    func asyncRequest(_ target: Target) async throws -> NetworkResponse {
        func mapError(_ error: MoyaError) -> NetworkServiceError {
            switch error {
            case .imageMapping(let response), .jsonMapping(let response), .stringMapping(let response):
                print("Failed to map response to expected format: \(response.description)")
                return .decodingFailed
            case .objectMapping(let error, let response):
                print("Object mapping failed: \(error.localizedDescription), \(response.description)")
                return .decodingFailed
            case .encodableMapping(let error):
                print("Encodable mapping failed: \(error.localizedDescription)")
                return .encodingFailed
            case .statusCode(let response):
                switch response.statusCode {
                case 401:
                    print("Unauthorized error (401): \(response.description)")
                    return .unauthorized
                case 404:
                    print("Resource not found (404): \(response.description)")
                    return .notFound
                case 500..<600:
                    print("Server error (\(response.statusCode): \(response.description)")
                    return .serverError
                default:
                    print("Invalid response: \(response.statusCode): \(response.description)")
                    return .invalidResponse
                }
            case .underlying(let error, _):
                print("Underlying error: \(error.localizedDescription)")
                guard (error as NSError).code == NSURLErrorTimedOut else { return .networkFailure }
                return .timeout
            case .requestMapping(let string):
                print("Request mapping failed: \(string)")
                return .requestMapping
            case .parameterEncoding(let error):
                print("Parameter encoding failed: \(error.localizedDescription)")
                return .encodingFailed
            }
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            request(target) { result in
                switch result {
                case .success(let response):
                    let networkResponse = NetworkResponse(statusCode: response.statusCode, data: response.data)
                    continuation.resume(returning: networkResponse)
                    
                case .failure(let moyaError):
                    let networkError = mapError(moyaError)
                    continuation.resume(throwing: networkError)
                }
            }
        }
    }
}
