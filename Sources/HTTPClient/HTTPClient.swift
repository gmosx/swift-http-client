import Foundation
import KituraRequest
import KituraNet

//public typealias HTTPClientResponse = URLResponse
public typealias HTTPClientResponse = ClientResponse

// TODO: Extract JSONHTTPClient?

public typealias DataCompletionHandler = (_ data: Data?, _ response: HTTPClientResponse?, _ error: Swift.Error?) -> Void

// TODO: deprecate this!
public typealias JSONCompletionHandler = (_ dict: [String: Any], _ response: HTTPClientResponse?, _ error: Swift.Error?) -> Void

public typealias DictCompletionHandler = (_ dict: [String: Any], _ response: HTTPClientResponse?, _ error: Swift.Error?) -> Void

public typealias RequestParams = [String: CustomStringConvertible]

// TODO: add support for blocking operations!
// TODO: avoid extending HTTPClient, compose it instead.
// TODO: support optional, extensive logging.

/// Currently uses KituraRequest as URLSession bombs on Linux (!!)
open class HTTPClient {
    public init() {
    }

    public func jsonDataToDictCompletionHandler(data: Data?, response: HTTPClientResponse?, error: Swift.Error?, completionHandler: @escaping DictCompletionHandler) {
        if let data = data {
            if let dict = (try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0))) as? [String: Any] {
                completionHandler(dict, response, error)
            } else {
                print("Cannot deserialize JSON")
                print(data)
                print(response ?? "")
                print(error ?? "")
                completionHandler([:], response, error)
            }
        } else {
            print("No data")
            print(response ?? "")
            print(error ?? "")
            completionHandler([:], response, error)
        }
    }

    // TODO: add `headers` and `parameters` argument

    public func get(url: URL, parameters: [String: Any]? = nil, completionHandler: @escaping DataCompletionHandler) {
//        let session = URLSession(configuration: URLSessionConfiguration.default)
//        let task = session.dataTask(with: url, completionHandler: completionHandler)
//        task.resume()

//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
////        let task = URLSession.shared.dataTask(with: request)
//        let session = URLSession(configuration: URLSessionConfiguration.default)
//        let task = session.dataTask(with: request, completionHandler: completionHandler)
//        task.resume()

        // TODO: handle parameters

        KituraRequest.request(.get, url.absoluteString).response { request, response, data, error in
            completionHandler(data, response, error)
        }
    }

    public func getJSON(url: URL, parameters: [String: Any]? = nil, completionHandler: @escaping JSONCompletionHandler) {
        // TODO: handle parameters

        get(url: url, parameters: parameters) { data, response, error in
            if let data = data {
                if let dict = (try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0))) as? [String: Any] {
                    completionHandler(dict, response, error)
                } else {
                    print("Cannot deserialize JSON")
                    if let dataString = String(data: data, encoding: .utf8) {
                        print(dataString)
                    }
                    completionHandler([:], response, error)
                }
            } else {
                completionHandler([:], response, error)
            }
        }
    }

    // TODO: https://stackoverflow.com/questions/26364914/http-request-in-swift-with-post-method
    // TODO: pass parameters!

    public func post(url: URL, headers: [String: String]? = nil,
                     parameters: [String: Any]? = nil,
                     completionHandler: @escaping DataCompletionHandler) {
        KituraRequest.request(.post, url.absoluteString, parameters: parameters, headers: headers).response { request, response, data, error in
            completionHandler(data, response, error)
        }
    }

    public func postJSON(url: URL, headers: [String: String]? = nil, parameters: [String: Any]? = nil, completionHandler: @escaping DictCompletionHandler) {
        KituraRequest.request(.post, url.absoluteString, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { request, response, data, error in
            self.jsonDataToDictCompletionHandler(data: data, response: response, error: error, completionHandler: completionHandler)
        }
    }

//    public func post(url: URL, data: Data, completionHandler: @escaping DataCompletionHandler) {
////        var request = URLRequest(url: url)
////        request.httpMethod = "POST"
////        request.httpBody = data
//////        let task = URLSession.shared.dataTask(with: request)
////        let session = URLSession(configuration: URLSessionConfiguration.default)
////        let task = session.dataTask(with: request, completionHandler: completionHandler)
////        task.resume()
//
////        KituraRequest.request(.post, url.absoluteString).response { request, response, data, error in
////            completionHandler(data, response, error)
////        }
//    }
//
//    public func postJSON(url: URL, dict: [String: Any], completionHandler: @escaping DictCompletionHandler) {
////        if let requestData = try? JSONSerialization.data(withJSONObject: dict) {
////            post(url: url, data: requestData) { responseData, response, error in
////                self.jsonDataToDictCompletionHandler(data: responseData, response: response, error: error, completionHandler: completionHandler)
////            }
////        } else {
////            print("Cannot serialize to JSON")
////            print(dict)
////        }
//    }
}
