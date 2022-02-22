//
//  APIManager.swift
//  MuchBetterAssignment
//
//  Created by Brijesh Singh on 17/02/22.
//  Copyright © 2020 . All rights reserved.
//

import UIKit

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case put = "PUT"
}

enum APIErrorCode: Int {
    case badRequest = 400
    case unauthorized = 401
    case notFound = 404
    case notAcceptable = 406
    case unprocessable = 422
    case serverError = 500
    case jsonParsing = 501
    case noData = 502
    case unknown
    
    var errorMesg:String {
        
        switch self {
            case .badRequest: return "Bad Request"
            case .unauthorized: return "Request Unauthorized"
            case .notFound: return "404 Not Found"
            case .notAcceptable: return "Input Data Not Acceptable"
            case .unprocessable: return "Unprocessable Entity"
            case .serverError: return "Internal Server Error"
            case .jsonParsing: return "JSON Parsing Fails"
            case .noData: return "Response Data is Empty"
            case .unknown: return "Something went wrong"
        }
    }
    
    init(rawValue: Int) {
        switch rawValue {
            case 400: self = .badRequest
            case 401: self = .unauthorized
            case 404: self = .notFound
            case 406: self = .notAcceptable
            case 422: self = .unprocessable
            case 500: self = .serverError
            case 501: self = .jsonParsing
            case 502: self = .noData
            default:  self = .unknown
        }
    }
}

struct APIError {
    var errorCode: APIErrorCode
    var error:Error?
}

enum APIResponse<Result> {
    case success(Result)
    case failure(APIError)
    
    var errorCode : APIErrorCode {
        if case .failure(let e) = self {
            return e.errorCode
        }
        else {
            return .unknown
        }
    }
}

class APIManager {
    static let shared = APIManager()
    //https://api.openweathermap.org/data/2.5/weather?lat=26.410642040229497&lon=80.38472037732619&appid=bf497dffc49a29bf3239413758e2ee12

    private init() {

    }
    
    func requestAPI<T:Codable>(responseModel: T.Type, endpoint: APIEndPoint, httpMethod:HTTPMethod, params:[String:Any]?, completion:@escaping (APIResponse<T>)->Void) {
        let url = URL(string: BASE_URL + endpoint.rawValue)!
        guard var urlRequest = self.getRequest(url: url, httpMethod: httpMethod, params: params) else {
            print("ERROR IN CREATING URL for Request URL")
            return
        }
        
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        printRequest(endpoint: endpoint, httpMethod: httpMethod, params: params, header: urlRequest.allHTTPHeaderFields)
        let urlSession = URLSession.init(configuration: URLSessionConfiguration.default)
        urlSession.dataTask(with: urlRequest) { (data, response, error) in
            DispatchQueue.main.async {
                self.printResponse(url: response?.url?.absoluteString, data: data, error: error)
                let apiResponse = self.parseResponse(responseModel, data, response, error)
                
                completion(apiResponse)

            }
        }.resume()
    }
}

extension APIManager {
    private func getRequest(url:URL, httpMethod:HTTPMethod, params:[String:Any]?) -> URLRequest? {
        switch httpMethod {
        case .post, .put:
            return self.createPostRequest(url: url, params: params)
        case .get, .delete:
            return self.createGetRequest(url: url, params: params)
        }
    }
    
    fileprivate func createPostRequest(url:URL, params:[String:Any]?) -> URLRequest? {
        var request = URLRequest.init(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params ?? [], options: JSONSerialization.WritingOptions.prettyPrinted)
        return request
    }
    
    fileprivate func createGetRequest(url:URL, params:[String:Any]?) -> URLRequest? {
        var components = URLComponents(string: url.absoluteString)
        components?.queryItems = params?.map { (key,val) in
            URLQueryItem(name: key, value: (val as? String))
        }

        guard let newURL = components?.url else { return nil }
        var request = URLRequest.init(url: newURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60)
        request.httpMethod = "GET"
        return request
    }
}

extension APIManager {
    
    fileprivate func parseResponse<T:Codable>(_ responseModel: T.Type, _ responseData:Data?, _ response: URLResponse?, _ error:Error?) -> APIResponse<T> {
        
        if let err = error {
            let apiError = APIError.init(errorCode: APIErrorCode.init(rawValue: (err as NSError).code), error: err)
            let apiResponse = APIResponse<T>.failure(apiError)
            return apiResponse
        }
        
        guard let data = responseData else {
            let apiError = APIError.init(errorCode: APIErrorCode.noData, error: error)
            let apiResponse = APIResponse<T>.failure(apiError)
            return apiResponse
        }
        
        guard let code = (response as? HTTPURLResponse)?.statusCode else {
            let apiError = APIError.init(errorCode: APIErrorCode.notFound, error: error)
            let apiResponse = APIResponse<T>.failure(apiError)
            return apiResponse
        }

        switch code {
        case 200, 201, 202, 204:
            do {
                var responseData = data
                if data.count == 0 {
                    responseData = "{}".data(using: .utf8)!
                }
                let response = try JSONDecoder().decode(responseModel, from: responseData)
                let apiResponse = APIResponse.success(response)
                return apiResponse

            } catch let parseError {
                let apiError = APIError.init(errorCode: APIErrorCode.jsonParsing, error: parseError)
                let apiResponse = APIResponse<T>.failure(apiError)
                return apiResponse
            }
        default:
            let apiError = APIError.init(errorCode: APIErrorCode.init(rawValue: code), error: nil)
            let apiResponse = APIResponse<T>.failure(apiError)
            return apiResponse
        }
    }
}

extension APIManager {
    fileprivate func printRequest(endpoint: APIEndPoint, httpMethod:HTTPMethod, params:[String:Any]?, header:[String:Any]?) {
        print("\n")
        debugPrint("----------- API Request -----------")
        debugPrint("URL : ", BASE_URL + endpoint.rawValue)
        debugPrint("httpMethod : ", httpMethod.rawValue)
        debugPrint("params : ", (params ?? [:]) as NSDictionary)
        debugPrint("headers : ", header ?? [:] as NSDictionary)
        debugPrint("----------- API Request -----------")
        print("\n")
    }
    
    fileprivate func printResponse(url:String?, data:Data?, error:Error?) {
        print("\n")
        debugPrint("----------- API Response -----------")
        debugPrint("URL : ", url ?? "")
        if error != nil {
            debugPrint("API Error : ",error?.localizedDescription ?? "")
        }
        if let data = data {
            debugPrint("Response : ",data.toObject() ?? "")
        }
        debugPrint("----------- API Response -----------")
        print("\n")
    }
}
