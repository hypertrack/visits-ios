import XCTest
@testable import App

final class AppTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(App().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
