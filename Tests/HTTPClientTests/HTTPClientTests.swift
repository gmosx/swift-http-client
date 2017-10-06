import Foundation
import XCTest
@testable import HTTPClient

class HTTPClientTests: XCTestCase {
    func testGet() {
        let client = HTTPClient()
        let expect = expectation(description: "`get` performs an HTTP-GET request")
        
        client.get(url: URL(string: "http://www.reizu.com")!) { data, _, _ in
            if let data = data {
                print("--- \(String(data: data, encoding: .utf8) ?? "!!")")
            }
            expect.fulfill()
        }
        
        wait(for: [expect], timeout: 10)
    }
    
    func testGetJSON() {
    }
    
    func testPost() {
    }

    func testPostJSON() {
    }

    static var allTests = [
        ("testGet", testGet),
    ]
}
