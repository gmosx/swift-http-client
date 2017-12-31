import Foundation
import LoggerAPI

public typealias HTTPClientResponse = URLResponse

public typealias DataCompletionHandler = (_ data: Data?, _ response: HTTPClientResponse?, _ error: Swift.Error?) -> Void
public typealias DictCompletionHandler = (_ dict: [String: Any], _ response: HTTPClientResponse?, _ error: Swift.Error?) -> Void
public typealias RequestParams = [String: CustomStringConvertible]

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
        print("No data")
        print(response ?? "")
        print(error ?? "")
        completionHandler([:], response, error)
    }
}

// TODO: add support for blocking operations!
// TODO: avoid extending HTTPClient, compose it instead.
// TODO: Add timeout parameters

open class HTTPClient {
    private let session = URLSession(configuration: URLSessionConfiguration.default)

    public init() {
        // Makes the initializer publicly accessible.
    }

    // MARK: GET

    public func get(
        url: URL,
        headers: [String: String]? = nil,
        completionHandler: @escaping DataCompletionHandler
    ) {
        Log.debug("GET \(url.absoluteString)")

        var request = URLRequest(url: url)

        request.httpMethod = "GET"

        if let headers = headers {
            for (field, value) in headers {
                request.setValue(value, forHTTPHeaderField: field)
            }
        }

        let task = session.dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }

    public func getReturningJSON(
        url: URL,
        headers: [String: String]? = nil,
        completionHandler: @escaping DictCompletionHandler
    ) {
        get(url: url, headers: headers) { data, response, error in
            jsonDataToDictCompletionHandler(data: data, response: response, error: error, completionHandler: completionHandler)
        }
    }

    // MARK: POST

    public func post(
        url: URL,
        headers: [String: String]? = nil,
        body: Data,
        completionHandler: @escaping DataCompletionHandler
    ) {
        Log.debug("POST \(url.absoluteString)")

        var request = URLRequest(url: url)

        request.httpMethod = "POST"

        if let headers = headers {
            for (field, value) in headers {
                request.setValue(value, forHTTPHeaderField: field)
            }
        }

        request.httpBody = body

        let task = session.dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }

    public func post(
        url: URL,
        headers: [String: String]? = nil,
        form parameters: [String: Any],
        completionHandler: @escaping DataCompletionHandler
    ) {
        var headers = headers ?? [:]

        headers["Content-Type"] = "application/x-www-form-urlencoded"

        let queryString = encodeQueryString(from: parameters)

        if let body = queryString.data(using: .utf8) {
            post(url: url, headers: headers, body: body, completionHandler: completionHandler)
        } else {
            Log.error("Invalid form paramets: \(parameters)")
            completionHandler(nil, nil, nil) // TODO: signal error!
        }
    }

    public func post(
        url: URL,
        headers: [String: String]? = nil,
        json parameters: [String: Any],
        completionHandler: @escaping DataCompletionHandler
    ) {
        var headers = headers ?? [:]

        headers["Content-Type"] = "application/json"
        headers["Accept"] = "application/json"

        var body: Data

        do {
            body = try JSONSerialization.data(withJSONObject: parameters/*, options: .prettyPrinted*/)
            post(url: url, headers: headers, body: body, completionHandler: completionHandler)
        } catch let error {
            Log.error(error.localizedDescription)
            completionHandler(nil, nil, nil) // TODO: signal error!
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
