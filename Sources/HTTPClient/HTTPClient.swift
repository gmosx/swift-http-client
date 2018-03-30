import Foundation
import LoggerAPI

// TODO: consider removing those typealiases!

public typealias HTTPClientResponse = URLResponse
public typealias DataCompletionHandler = (_ data: Data?, _ response: HTTPClientResponse?, _ error: Swift.Error?) -> Void
public typealias RequestParams = [String: CustomStringConvertible]

// TODO: rename completionHandler to something shorter
// TODO: add support for nested post data: xxx[yyy].
// TODO: add support for blocking operations!
// TODO: avoid extending HTTPClient, compose it instead.
// TODO: Add timeout parameters.
// TODO: Add DELETE and other HTTP methods.
// TODO: add POST method that accepts Codable.
// TODO: add GET method that accepts query parameters.
// TODO: add general .request() method.

open class HTTPClient {
    private let session = URLSession(configuration: URLSessionConfiguration.default)

    public init() {
    }

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

        do {
            let body = try JSONSerialization.data(withJSONObject: parameters/*, options: .prettyPrinted*/)
            post(url: url, headers: headers, body: body, completionHandler: completionHandler)
        } catch let error {
            Log.error(error.localizedDescription)
            completionHandler(nil, nil, nil) // TODO: signal error!
        }
    }
}
