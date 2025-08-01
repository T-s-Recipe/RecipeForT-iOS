//
//  Tokens.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/1/25.
//

import Foundation

struct Tokens: Codable {
    enum Constants {
        static let accessTokenDuration: TimeInterval = 60 * 60                        // 유효기간: 1시간
        static let refreshTokenDuration: TimeInterval = 30 * 24 * 60 * 60             // 유효기간: 30일
        static let reissueThreshold: TimeInterval = 60 * 5                            // 재발급 임계기간: 5분
    }
    
    let accessToken: String
    let refreshToken: String
    let expiredAt: Date
    private let refreshTokenExpiredAt: Date
    var isAccessTokenExpired: Bool { Date(timeIntervalSinceNow: Constants.reissueThreshold) >= expiredAt }
    var isRefreshTokenExpired: Bool { Date() >= refreshTokenExpiredAt }
    
    init(
        accessToken: String,
        refreshToken: String
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiredAt = Date(timeIntervalSinceNow: Constants.accessTokenDuration)
        self.refreshTokenExpiredAt = Date(timeIntervalSinceNow: Constants.refreshTokenDuration)
    }
}
