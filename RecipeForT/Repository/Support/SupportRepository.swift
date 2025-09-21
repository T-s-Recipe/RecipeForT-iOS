//
//  SupportRepository.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/18/25.
//

import Foundation

protocol SupportRepositoryProtocol {
    func createInquiry(content: String) async throws
    func fetchInquiries() async throws -> [Inquiry]
    func fetchAnnouncements() async throws -> [Announcement]
}

final class SupportRepository {
    private let networkService: NetworkServiceProtocol
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    init(
        networkService: NetworkServiceProtocol,
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.networkService = networkService
        self.decoder = decoder
        self.encoder = encoder
    }
}

// MARK: - SupportRepositoryProtocol Conformation
extension SupportRepository: SupportRepositoryProtocol {
    func createInquiry(content: String) async throws {
        
    }
    
    func fetchInquiries() async throws -> [Inquiry] {
        []
    }
    
    func fetchAnnouncements() async throws -> [Announcement] {
        []
    }
}
