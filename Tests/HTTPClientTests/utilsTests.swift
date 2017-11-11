import Foundation
import XCTest
@testable import HTTPClient

class UtilsTests: XCTestCase {
    func testEncodeQueryString() {
        let parameters: [String: CustomStringConvertible] = [
            "name": "George",
            "access": 15,
            "data": 198
        ]
        XCTAssertEqual(encodeQueryString(from: parameters), "access=15&name=George&data=198")
    }

    func testEncodeQueryStringSorted() {
        let parameters: [String: CustomStringConvertible] = [
            "name": "George",
            "access": 15,
            "data": 198
        ]
        XCTAssertEqual(encodeQueryStringSorted(from: parameters), "access=15&data=198&name=George")

        let parameters2: [String: CustomStringConvertible] = [
            "zork": "great",
            "pac": "man",
            "bubble": "bobble",
        ]
        XCTAssertEqual(encodeQueryStringSorted(from: parameters2), "bubble=bobble&pac=man&zork=great")
    }
}
