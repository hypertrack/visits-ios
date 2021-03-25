import Prelude
import XCTest
import Types
@testable import APIEnvironmentLive

final class APIEnvironmentLiveConstructAddressTests: XCTestCase {
  func testConstructAddress_whenBoth_itReturnsBoth() throws {
    XCTAssertEqual(
      constructAddress(fromSubThoroughfare: "1", thoroughfare: "Avenue", formattedAddress: "1 Avenue Lane"),
      These<Order.Street, Order.FullAddress>.both(Order.Street(rawValue: "1 Avenue"), Order.FullAddress(rawValue: "1 Avenue Lane"))
    )
  }
  
  func testConstructAddress_whenAddress_itReturnsThis() throws {
    XCTAssertEqual(
      constructAddress(fromSubThoroughfare: "1", thoroughfare: "Avenue", formattedAddress: nil),
      These<Order.Street, Order.FullAddress>.this(Order.Street(rawValue: "1 Avenue"))
    )
  }
  
  func testConstructAddress_whenFullAddress_itReturnsThat() throws {
    XCTAssertEqual(
      constructAddress(fromSubThoroughfare: nil, thoroughfare: nil, formattedAddress: "1 Avenue Lane"),
      These<Order.Street, Order.FullAddress>.that(Order.FullAddress(rawValue: "1 Avenue Lane"))
    )
  }
  
  func testConstructAddress_whenNoStreetNumber_itReturnsStreetWithout() throws {
    XCTAssertEqual(
      constructAddress(fromSubThoroughfare: nil, thoroughfare: "Avenue", formattedAddress: "1 Avenue Lane"),
      These<Order.Street, Order.FullAddress>.both(Order.Street(rawValue: "Avenue"), Order.FullAddress(rawValue: "1 Avenue Lane"))
    )
    XCTAssertEqual(
      constructAddress(fromSubThoroughfare: nil, thoroughfare: "Avenue", formattedAddress: nil),
      These<Order.Street, Order.FullAddress>.this(Order.Street(rawValue: "Avenue"))
    )
  }
  
  func testConstructAddress_whenOnlyStreetNumber_itReturnsWithout() throws {
    XCTAssertEqual(
      constructAddress(fromSubThoroughfare: "1", thoroughfare: nil, formattedAddress: "1 Avenue Lane"),
      These<Order.Street, Order.FullAddress>.that(Order.FullAddress(rawValue: "1 Avenue Lane"))
    )
    XCTAssertEqual(
      constructAddress(fromSubThoroughfare: "1", thoroughfare: nil, formattedAddress: nil),
      nil
    )
  }
  
  func testConstructAddress_whenNone_itReturnsNil() throws {
    XCTAssertEqual(
      constructAddress(fromSubThoroughfare: nil, thoroughfare: nil, formattedAddress: nil),
      nil
    )
  }
}
