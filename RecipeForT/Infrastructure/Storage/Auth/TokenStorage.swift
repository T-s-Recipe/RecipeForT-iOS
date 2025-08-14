//
//  TokenStorage.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/1/25.
//

import Foundation
import Security

protocol TokenStorageProtocol: Sendable {
    typealias Query = [String: Any]
    
    func store(_ data: Data) throws
    func fetch() throws -> Data
    func delete() throws
}

private enum TokenStorageError: Error {
    case unknown
    case failedFindToken
    case failedCasting
}

final class TokenStorage {
    private let bundleIdentifier: String? = Bundle.main.bundleIdentifier
    
    private let lock: NSLock = NSLock()
    
    private func _create(_ data: Data, in query: Query) throws {
        var query = query
        query[kSecValueData as String] = data
        
        let status = SecItemAdd(query as CFDictionary, nil)
        try check(status, which: #function)
    }
    
    private func _read(_ query: Query) throws -> CFTypeRef? {
        var query = query
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        
        var dataTypeRef: CFTypeRef? = nil
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        try check(status, which: #function)
        
        return dataTypeRef
    }
    
    private func _update(_ data: Data, in query: Query) throws {
        let queryToUpdate: Query = [kSecValueData as String: data]
        let status = SecItemUpdate(query as CFDictionary, queryToUpdate as CFDictionary)
        try check(status, which: #function)
    }
    
    private func _delete(_ query: Query) throws {
        let status = SecItemDelete(query as CFDictionary)
        try check(status, which: #function)
    }
}

// MARK: Utility Methods for CRUD
extension TokenStorage {
    private func makeQuery() throws -> Query {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: bundleIdentifier ?? "",
            kSecAttrAccount as String: "\(bundleIdentifier ?? "").token"
        ]
    }
    
    private func check(_ status: OSStatus, which function: String) throws {
        guard status == noErr else {
            let errorMessage = SecCopyErrorMessageString(status, nil) as String? ?? "\(TokenStorageError.unknown)"
            print("Error occurred from TokenStorage: \(function): \(errorMessage)")
            
            if status == errSecItemNotFound {
                throw TokenStorageError.failedFindToken
            } else {
                throw TokenStorageError.unknown
            }
        }
    }
    
    private func convert(_ ref: CFTypeRef?) throws -> Data {
        guard let data = ref else {
            throw TokenStorageError.failedFindToken
        }
        
        guard let data = data as? Data else {
            throw TokenStorageError.failedCasting
        }
        return data
    }
}

// MARK: TokenStorage Conformation
extension TokenStorage: TokenStorageProtocol {
    func store(_ data: Data) throws {
        lock.lock()
        defer { lock.unlock() }
        
        let query = try makeQuery()
        
        do {
            if let _ = try _read(query) {
                try _update(data, in: query)
            }
        } catch TokenStorageError.failedFindToken {
            try _create(data, in: query)
        }
    }
    
    func fetch() throws -> Data {
        lock.lock()
        defer { lock.unlock() }
        
        let query = try makeQuery()
        let reference = try _read(query)
        let data = try convert(reference)
        return data
    }
    
    func delete() throws {
        lock.lock()
        defer { lock.unlock() }
        
        let query = try makeQuery()
        try _delete(query)
    }
}
