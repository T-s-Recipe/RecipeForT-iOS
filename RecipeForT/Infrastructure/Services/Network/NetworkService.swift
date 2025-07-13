//
//  NetworkService.swift
//  RecipeForT
//
//  Created by Swain Yun on 6/25/25.
//

import Foundation
import Moya

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

final class NetworkService {
    private let provider = MoyaProvider<MultiTarget>()
    
    private func performResult(_ result: Result<Response, MoyaError>) throws(NetworkServiceError) -> Data {
        switch result {
        case .success(let response):
            return try performResponse(response)
        case .failure(let error):
            throw mapError(error)
        }
    }
    
    private func performResponse(_ response: Response) throws(NetworkServiceError) -> Data {
        switch response.statusCode {
        case 200..<300: return response.data
        case 401: throw .unauthorized
        case 404: throw .notFound
        case 500..<600: throw .serverError
        default: throw .invalidResponse
        }
    }
    
    private func mapError(_ error: MoyaError) -> NetworkServiceError {
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
            print("Invalid response. code: \(response.statusCode)")
            return .invalidResponse
        case .underlying(let error, let response):
            print("Underlying error")
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
}

// MARK: - NetworkServiceProtocol Conformation
extension NetworkService: NetworkServiceProtocol {
    func request<T: TargetType>(_ endpoint: T) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(MultiTarget(endpoint)) {[weak self] result in
                guard let self else { return }
                
                do {
                    let data = try performResult(result)
                    continuation.resume(returning: data)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func request<T: TargetType>(_ endpoint: T) async throws {
        
    }
}
