import XCTest
@testable import DeepLink

final class DeepLinkTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(DeepLink().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
