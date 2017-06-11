import Foundation

public typealias DataCompletionHandler = (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void

// TODO: deprecate this!
public typealias JSONCompletionHandler = (_ dict: [String: Any], _ response: URLResponse?, _ error: Error?) -> Void

public typealias DictCompletionHandler = (_ dict: [String: Any], _ response: URLResponse?, _ error: Error?) -> Void

// TODO: consider Kitura-Request instead? -> no!
// TODO: add support for blocking operations!
// TODO: avoid extending HTTPClient, compose it instead.

open class HTTPClient {
    public init() {
    }

    func jsonDataToDictCompletionHandler(data: Data?, response: URLResponse?, error: Error?, completionHandler: @escaping DictCompletionHandler) {
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

    public func get(url: URL, completionHandler: @escaping DataCompletionHandler) {
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: url, completionHandler: completionHandler)
        task.resume()
    }

    // THINK: is this really worth it's weight?
    public func getJSON(url: URL, completionHandler: @escaping JSONCompletionHandler) {
        get(url: url) { data, response, error in
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
        //
        // KituraRequest.request(.get, url.absoluteString).response { request, response, data, error in
        //     if let data = data,
        //         let dict = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String: Any] {
        //         completionHandler(dict, response, error)
        //     } else {
        //         completionHandler([:], response, error)
        //     }
        // }
    }

    public func post(url: URL, data: Data, completionHandler: @escaping DataCompletionHandler) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = data
//        let task = URLSession.shared.dataTask(with: request)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }

    public func postJSON(url: URL, dict: [String: Any], completionHandler: @escaping DictCompletionHandler) {
        if let requestData = try? JSONSerialization.data(withJSONObject: dict) {
            post(url: url, data: requestData) { responseData, response, error in
                self.jsonDataToDictCompletionHandler(data: responseData, response: response, error: error, completionHandler: completionHandler)
            }
        } else {
            print("Cannot serialize to JSON")
            print(dict)
        }
    }
}
