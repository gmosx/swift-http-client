
// TODO: Add unit tests!
// TODO: consider formatQueryString(from:)

/// Encodes parameters into a querystring.
public func encodeQueryString(from parameters: [String: Any]) -> String {
    let paramsString = parameters.map({ (key, value) in
        if let valueEncoded = String(describing: value).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            return "\(key)=\(valueEncoded)"
        } else {
            return "\(key)="
        }
    }).joined(separator: "&")
    
    return paramsString
}


/// Encodes parameters into a querystring, sorted by key.
public func encodeQueryStringSorted(from parameters: [String: Any]) -> String {
    let parametersKeys = parameters.keys.sorted(by: <)
    let paramsString = parametersKeys.map({ key in
        if let value = parameters[key] {
            if let valueEncoded = String(describing: value).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                return "\(key)=\(valueEncoded)"
            } else {
                return "\(key)="
            }
        } else {
            return "" // TODO: Hmm...
        }
    }).joined(separator: "&")
    
    return paramsString
}
