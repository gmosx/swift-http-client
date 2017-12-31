import Foundation

open class JSONHTTPClient {
    let httpClient = HTTPClient()

    public init() {
    }

    public func get(
        url: URL,
        headers: [String: String]? = nil,
        completionHandler: @escaping DictCompletionHandler
    ) {
        httpClient.get(url: url, headers: headers) { data, response, error in
            jsonDataToDictCompletionHandler(data: data, response: response, error: error, completionHandler: completionHandler)
        }
    }

    public func post(
        url: URL,
        headers: [String: String]? = nil,
        form parameters: [String: Any],
        completionHandler: @escaping DictCompletionHandler
    ) {
        httpClient.post(url: url, headers: headers, form: parameters) { data, response, error in
            jsonDataToDictCompletionHandler(data: data, response: response, error: error, completionHandler: completionHandler)
        }
    }

    public func post(
        url: URL,
        headers: [String: String]? = nil,
        json parameters: [String: Any],
        completionHandler: @escaping DictCompletionHandler
    ) {
        httpClient.post(url: url, headers: headers, json: parameters) { data, response, error in
            jsonDataToDictCompletionHandler(data: data, response: response, error: error, completionHandler: completionHandler)
        }
    }
}
