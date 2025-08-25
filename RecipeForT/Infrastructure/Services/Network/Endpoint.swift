//
//  Endpoint.swift
//  RecipeForT
//
//  Created by Swain Yun on 7/5/25.
//

import Foundation
import Moya

enum Endpoint {
    // MARK: - Auth
    case signIn(SignInRequestDTO)                                                                               // 사용자 로그인
    case reissueToken(TokenReissueRequestDTO)                                                                   // 토큰 재발급
    case logout(LogoutRequestDTO)                                                                               // 사용자 로그아웃
    
    // MARK: - Member
    case fetchMemberInfo(id: String?, providerID: String?, ci: String?)                                         // 회원정보 단건 조회
    case register(SignUpRequestDTO)                                                                             // 회원가입
    case fetchRandomNickname                                                                                    // 랜덤 닉네임 조회
    case updateMemberInfo(UpdateMemberRequestDTO)                                                               // 회원정보 수정
    case unregister(id: String)                                                                                 // 회원탈퇴
    
    // MARK: - Recipe
    case uploadRecipe(dtoData: Data, image: ImageItem?)                                                         // 레시피 등록
    case fetchRecipeDetail(recipeID: String)                                                                    // 레시피 단건 조회
    case fetchRecipeList(nextPageID: String?, limit: Int32)                                                     // 페이지네이션 레시피 목록 조회
}

extension Endpoint {
    var usingToken: Bool {
        switch self {
        case .fetchMemberInfo, .uploadRecipe:
            true
        default:
            false
        }
    }
    
    var receivingToken: Bool {
        guard case .reissueToken = self else { return false }
        return true
    }
}

// MARK: - TargetType Conformation
extension Endpoint: TargetType {
    var baseURL: URL {
        guard let baseURL = URL(string: "https://dev.tsrecipe.shop") else { fatalError("Invalid baseURL") }
        return baseURL
    }
    
    var path: String {
        switch self {
        case .signIn: "/auths/sign-in"
        case .reissueToken: "/auths/reissue"
        case .logout: "/auths/logout"
            
        case .fetchMemberInfo: "/members/"
        case .register: "/members/"
        case .fetchRandomNickname: "/members/nickname"
        case .updateMemberInfo: "/members/"
        case .unregister(let id): "members/\(id)"
            
        case .uploadRecipe: "/recipes"
        case .fetchRecipeDetail(let recipeID): "/recipes/\(recipeID)"
        case .fetchRecipeList: "/recipes/recent"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchMemberInfo, .fetchRandomNickname, .fetchRecipeDetail, .fetchRecipeList: .get
        case .signIn, .reissueToken, .logout, .register, .uploadRecipe: .post
        case .updateMemberInfo: .patch
        case .unregister: .delete
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .signIn(let request):
            return .requestJSONEncodable(request)
        case .reissueToken(let request):
            return .requestJSONEncodable(request)
        case .logout(let request):
            return .requestJSONEncodable(request)
        
        case .fetchMemberInfo(let id, let providerID, let authID):
            var parameters = [String: Any]()
            if let id { parameters["memberId"] = id }
            if let providerID { parameters["oAuthProvider"] = providerID }
            if let authID { parameters["oAuthId"] = authID }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case .register(let request):
            return .requestJSONEncodable(request)
        case .fetchRandomNickname:
            return .requestPlain
        case .updateMemberInfo(let request):
            return .requestJSONEncodable(request)
        case .unregister:
            return .requestPlain
            
        case .uploadRecipe(let dtoData, let item):
            var formData = [MultipartFormData]()
            formData.append(.init(provider: .data(dtoData), name: "request"))
            if let item { formData.append(.init(provider: .data(item.data), name: item.filename, mimeType: item.mimeType)) }
            return .uploadMultipart(formData)
        case .fetchRecipeDetail:
            return .requestPlain
        case .fetchRecipeList(let nextPageID, let limit):
            var parameters = [String: Any]()
            if let nextPageID { parameters["cursorId"] = nextPageID }
            parameters["limit"] = limit
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .signIn: ["App-Platform": "ios"]
        default: .none
        }
    }
    
    var validationType: ValidationType {
        .successCodes
    }
}
