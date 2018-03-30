import Foundation
import LoggerAPI

// This file contains deprecated functionality we still maintain for compatibilty
// purposes.

// TODO: eventually remove this file!
// TODO: the `***getReturningJSON` methods are not that useful, prefer a Codable solution.

public typealias DictCompletionHandler = (_ dict: [String: Any], _ response: HTTPClientResponse?, _ error: Swift.Error?) -> Void

func jsonDataToDictCompletionHandler(data: Data?, response: HTTPClientResponse?, error: Swift.Error?, completionHandler: @escaping  DictCompletionHandler) {
    if let data = data {
        if let json = try? JSONSerialization.jsonObject(with: data, options: [.allowFragments]) {
            if let dict = json as? [String: Any] {
                completionHandler(dict, response, error)
            } else if let array = json as? [Any] {
                // TODO: temp solution, think what to do
                completionHandler(["result": array], response, error)
            }
            // TODO: any additional cases to be handled here?
        } else {
            print("Cannot deserialize JSON")
            if let dataString = String(data: data, encoding: .utf8) {
                print(dataString)
            }
            print(response ?? "")
            print(error ?? "")
            completionHandler([:], response, error)
        }
    } else {
        print("No data") // TODO: use Logger here!!! ARGH!!
        print(response ?? "")
        print(error ?? "")
        completionHandler([:], response, error)
    }
}

public extension HTTPClient {
    public func getReturningJSON(
        url: URL,
        headers: [String: String]? = nil,
        completionHandler: @escaping DictCompletionHandler
    ) {
        get(url: url, headers: headers) { data, response, error in
            jsonDataToDictCompletionHandler(data: data, response: response, error: error, completionHandler: completionHandler)
        }
    }

    public func postReturningJSON(
        url: URL,
        headers: [String: String]? = nil,
        form parameters: [String: Any],
        completionHandler: @escaping DictCompletionHandler
    ) {
        post(url: url, headers: headers, form: parameters) { data, response, error in
            jsonDataToDictCompletionHandler(data: data, response: response, error: error, completionHandler: completionHandler)
        }
    }

    public func postReturningJSON(
        url: URL,
        headers: [String: String]? = nil,
        json parameters: [String: Any],
        completionHandler: @escaping DictCompletionHandler
    ) {
        post(url: url, headers: headers, json: parameters) { data, response, error in
            jsonDataToDictCompletionHandler(data: data, response: response, error: error, completionHandler: completionHandler)
        }
    }
}
