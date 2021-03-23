import Prelude
import XCTest
import Visit
@testable import APIEnvironmentLive

final class APIEnvironmentLiveConstructAddressTests: XCTestCase {
  func testConstructAddress_whenBoth_itReturnsBoth() throws {
    XCTAssertEqual(
      constructAddress(fromSubThoroughfare: "1", thoroughfare: "Avenue", formattedAddress: "1 Avenue Lane"),
      These<Visit.Street, Visit.FullAddress>.both(Visit.Street(rawValue: "1 Avenue"), Visit.FullAddress(rawValue: "1 Avenue Lane"))
    )
  }
  
  func testConstructAddress_whenAddress_itReturnsThis() throws {
    XCTAssertEqual(
      constructAddress(fromSubThoroughfare: "1", thoroughfare: "Avenue", formattedAddress: nil),
      These<Visit.Street, Visit.FullAddress>.this(Visit.Street(rawValue: "1 Avenue"))
    )
  }
  
  func testConstructAddress_whenFullAddress_itReturnsThat() throws {
    XCTAssertEqual(
      constructAddress(fromSubThoroughfare: nil, thoroughfare: nil, formattedAddress: "1 Avenue Lane"),
      These<Visit.Street, Visit.FullAddress>.that(Visit.FullAddress(rawValue: "1 Avenue Lane"))
    )
  }
  
  func testConstructAddress_whenNoStreetNumber_itReturnsStreetWithout() throws {
    XCTAssertEqual(
      constructAddress(fromSubThoroughfare: nil, thoroughfare: "Avenue", formattedAddress: "1 Avenue Lane"),
      These<Visit.Street, Visit.FullAddress>.both(Visit.Street(rawValue: "Avenue"), Visit.FullAddress(rawValue: "1 Avenue Lane"))
    )
    XCTAssertEqual(
      constructAddress(fromSubThoroughfare: nil, thoroughfare: "Avenue", formattedAddress: nil),
      These<Visit.Street, Visit.FullAddress>.this(Visit.Street(rawValue: "Avenue"))
    )
  }
  
  func testConstructAddress_whenOnlyStreetNumber_itReturnsWithout() throws {
    XCTAssertEqual(
      constructAddress(fromSubThoroughfare: "1", thoroughfare: nil, formattedAddress: "1 Avenue Lane"),
      These<Visit.Street, Visit.FullAddress>.that(Visit.FullAddress(rawValue: "1 Avenue Lane"))
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
