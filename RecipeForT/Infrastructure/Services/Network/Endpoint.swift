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
    // case fetchMemberInfo(id: String?, providerID: String?, ci: String?)                                      // 회원정보 단건 조회 (Deprecated)
    case register(SignUpRequestDTO)                                                                             // 회원가입
    case unregister(id: String)                                                                                 // 회원탈퇴
    case updateMemberInfo(UpdateMemberRequestDTO)                                                               // 회원정보 수정
    case fetchRandomNickname                                                                                    // 랜덤 닉네임 조회
    case checkNicknameDuplication(nickname: String)                                                             // 닉네임 중복 여부 조회
    case fetchMemberInfo                                                                                        // 회원정보 조회
    
    // MARK: - Recipe
    case uploadRecipe(CreateRecipeRequestDTO)                                                                   // 레시피 등록
    case uploadRecipeImage(ImageItem)                                                                           // 레시피 이미지 등록
    case fetchRecipeDetail(recipeID: String)                                                                    // 레시피 단건 조회
    case fetchRecipeList(nextPageID: String?, limit: Int32)                                                     // 페이지네이션 레시피 목록 조회
}

extension Endpoint {
    var usingToken: Bool {
        switch self {
        case .fetchMemberInfo, .uploadRecipe, .uploadRecipeImage, .checkNicknameDuplication:
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
            
        case .fetchMemberInfo: "/members/me"
        case .register: "/members/"
        case .fetchRandomNickname: "/members/nickname"
        case .updateMemberInfo: "/members/"
        case .unregister(let id): "/members/\(id)"
        case .checkNicknameDuplication: "/members/nickname/check"
            
        case .uploadRecipe: "/recipes"
        case .uploadRecipeImage: "/recipes/image-upload"
        case .fetchRecipeDetail(let recipeID): "/recipes/\(recipeID)"
        case .fetchRecipeList: "/recipes/recent"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchMemberInfo, .fetchRandomNickname, .fetchRecipeDetail, .fetchRecipeList, .checkNicknameDuplication: .get
        case .signIn, .reissueToken, .logout, .register, .uploadRecipe, .uploadRecipeImage: .post
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
        
        case .fetchMemberInfo:
            return .requestPlain
        case .register(let request):
            return .requestJSONEncodable(request)
        case .fetchRandomNickname:
            return .requestPlain
        case .updateMemberInfo(let request):
            return .requestJSONEncodable(request)
        case .unregister:
            return .requestPlain
        case .checkNicknameDuplication(let nickname):
            let params = ["nickname": nickname]
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
            
        case .uploadRecipe(let dto):
            return .requestJSONEncodable(dto)
        case .uploadRecipeImage(let item):
            var formDatas = [MultipartFormData]()
            formDatas.append(.init(provider: .data(item.data), name: "imageFile", fileName: item.filename, mimeType: item.mimeType))
            return .uploadMultipart(formDatas)
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
