import NonEmpty
import XCTest
@testable import Types

final class GeoJSONPolygonTests: XCTestCase {
  func testDecoding_whenPolygon_itReturnsAPolygon() throws {
    XCTAssertEqual(
      polygonTriangle,
      try JSONDecoder().decode(GeoJSON.self, from: fixturePolygonTriangle)
    )
    XCTAssertEqual(
      polygonTriangleHollow,
      try JSONDecoder().decode(GeoJSON.self, from: fixturePolygonTriangleHollow)
    )
    XCTAssertEqual(
      polygonSquareHollow,
      try JSONDecoder().decode(GeoJSON.self, from: fixturePolygonSquareHollow)
    )
  }
  
  func testDecoding_whenPolygonHasUnexpectedTypesAfterCoordinates_itIgnoresThem() throws {
    XCTAssertEqual(
      polygonTriangle,
      try JSONDecoder().decode(
        GeoJSON.self,
        from: fixturePolygonTriangle.json(
          updatingKeyPaths:
            (
              "coordinates", [
                [
                  [
                    -122.42138385772704,
                    37.78560552974875,
                    "Hello",
                    []
                  ],
                  [
                    -122.4312114715576,
                    37.78441844686463,
                    "Hello",
                    []
                  ],
                  [
                    -122.42945194244386,
                    37.77502286117533,
                    "Hello",
                    []
                  ],
                  [
                    -122.42138385772704,
                    37.78560552974875,
                    "Hello",
                    []
                  ]
                ]
              ]
            )
        )
      )
    )
  }
  
  func testDecoding_whenLinearRingsLessThenFourValues_itThrows() throws {
    AssertThrowsValueNotFound(
      decoding: GeoJSON.self,
      from: try fixturePolygonTriangle.json(updatingKeyPaths: ("coordinates", [[[]]]))
    )
    AssertThrowsValueNotFound(
      decoding: GeoJSON.self,
      from: try fixturePolygonTriangle.json(updatingKeyPaths: ("coordinates", [[[30]]]))
    )
  }
  
  func testDecoding_whenPolygonHasDifferentFirstAndLastCoordinates_itThrows() throws {
    AssertThrowsCorrupted(
      decoding: GeoJSON.self,
      from: try fixturePolygonTriangle.json(
        updatingKeyPaths:
          (
            "coordinates", [
              [
                [
                  -122.42138385772704,
                  37.78560552974875
                ],
                [
                  -122.4312114715576,
                  37.78441844686463
                ],
                [
                  -122.42945194244386,
                  37.77502286117533
                ],
                [
                  -120,
                  37
                ]
              ]
            ]
          )
      )
    )
  }
  
  func testDecoding_whenPolygonLinearRingCoordinatesAreInvalid_itThrows() throws {
    AssertThrowsCorrupted(
      decoding: GeoJSON.self,
      from: try fixturePolygonTriangle.json(
        updatingKeyPaths:
          (
            "coordinates", [
              [
                [
                  37,
                  -120
                ],
                [
                  -122.4312114715576,
                  37.78441844686463
                ],
                [
                  -122.42945194244386,
                  37.77502286117533
                ],
                [
                  37,
                  -120
                ]
              ]
            ]
          )
      )
    )
  }
  
  func testDecoding_whenPolygonLinearRingCoordinatesAreNotNumbers_itThrows() throws {
    AssertThrowsTypeMismatch(
      decoding: GeoJSON.self,
      from: try fixturePolygonTriangle.json(
        updatingKeyPaths:
          (
            "coordinates", [
              [
                [
                  "-122.42138385772704",
                  "37.78560552974875"
                ],
                [
                  "-122.4312114715576",
                  "37.78441844686463"
                ],
                [
                  "-122.42945194244386",
                  "37.77502286117533"
                ],
                [
                  "-122.42138385772704",
                  "37.78560552974875"
                ]
              ]
            ]
          )
      )
    )
  }
  
  func testDecoding_whenPolygonLinearRingIsWronglyNested_itThrows() throws {
    AssertThrowsTypeMismatch(
      decoding: GeoJSON.self,
      from: try fixturePolygonTriangle.json(
        updatingKeyPaths:
          (
            "coordinates", [
              [
                -122.42138385772704,
                37.78560552974875
              ],
              [
                -122.4312114715576,
                37.78441844686463
              ],
              [
                -122.42945194244386,
                37.77502286117533
              ],
              [
                -122.42138385772704,
                37.78560552974875
              ]
            ]
          )
      )
    )
  }
}

let polygonTriangle = GeoJSON.polygon(
  NonEmptyArray(
    rawValue: [
      LinearRing(
        origin: Coordinate(latitude: 37.78560552974875, longitude: -122.42138385772704)!,
        first: Coordinate(latitude: 37.78441844686463, longitude: -122.4312114715576)!,
        second: Coordinate(latitude: 37.77502286117533, longitude: -122.42945194244386)!,
        rest: []
      )
    ]
  )!
)
let fixturePolygonTriangle = Data("""
  {
    "type": "Polygon",
    "coordinates": [
      [
        [
          -122.42138385772704,
          37.78560552974875
        ],
        [
          -122.4312114715576,
          37.78441844686463
        ],
        [
          -122.42945194244386,
          37.77502286117533
        ],
        [
          -122.42138385772704,
          37.78560552974875
        ]
      ]
    ]
  }
  """.utf8
)


let polygonTriangleHollow = GeoJSON.polygon(
  NonEmptyArray(
    rawValue: [
      LinearRing(
        origin: Coordinate(latitude: 37.78560552974875, longitude: -122.42138385772704)!,
        first: Coordinate(latitude: 37.78441844686463, longitude: -122.4312114715576)!,
        second: Coordinate(latitude: 37.77502286117533, longitude: -122.42945194244386)!,
        rest: []
      ),
      LinearRing(
        origin: Coordinate(latitude: 37.78389273263846, longitude: -122.42779970169066)!,
        first: Coordinate(latitude: 37.78026350661797, longitude: -122.4270486831665)!,
        second: Coordinate(latitude: 37.784350612981044, longitude: -122.42449522018431)!,
        rest: []
      )
    ]
  )!
)
let fixturePolygonTriangleHollow = Data("""
  {
    "type": "Polygon",
    "coordinates": [
      [
        [
          -122.42138385772704,
          37.78560552974875
        ],
        [
          -122.4312114715576,
          37.78441844686463
        ],
        [
          -122.42945194244386,
          37.77502286117533
        ],
        [
          -122.42138385772704,
          37.78560552974875
        ]
      ],
      [
        [
          -122.42779970169066,
          37.78389273263846
        ],
        [
          -122.4270486831665,
          37.78026350661797
        ],
        [
          -122.42449522018431,
          37.784350612981044
        ],
        [
          -122.42779970169066,
          37.78389273263846
        ]
      ]
    ]
  }
  """.utf8
)


let polygonSquareHollow = GeoJSON.polygon(
  NonEmptyArray(
    rawValue: [
      LinearRing(
        origin: Coordinate(latitude: 37.774853254793086, longitude: -122.43292808532715)!,
        first: Coordinate(latitude: 37.774853254793086, longitude: -122.4067497253418)!,
        second: Coordinate(latitude: 37.79486412183905, longitude: -122.4067497253418)!,
        rest: [Coordinate(latitude: 37.79486412183905, longitude: -122.43292808532715)!]
      ),
      LinearRing(
        origin: Coordinate(latitude: 37.77777043035903, longitude: -122.4276065826416)!,
        first: Coordinate(latitude: 37.77777043035903, longitude: -122.41189956665039)!,
        second: Coordinate(latitude: 37.79106586542567, longitude: -122.41189956665039)!,
        rest: [Coordinate(latitude: 37.79106586542567, longitude: -122.4276065826416)!]
      )
    ]
  )!
)
let fixturePolygonSquareHollow = Data("""
  {
    "type": "Polygon",
    "coordinates": [
      [
        [
          -122.43292808532715,
          37.774853254793086
        ],
        [
          -122.4067497253418,
          37.774853254793086
        ],
        [
          -122.4067497253418,
          37.79486412183905
        ],
        [
          -122.43292808532715,
          37.79486412183905
        ],
        [
          -122.43292808532715,
          37.774853254793086
        ]
      ],
      [
        [
          -122.4276065826416,
          37.77777043035903
        ],
        [
          -122.41189956665039,
          37.77777043035903
        ],
        [
          -122.41189956665039,
          37.79106586542567
        ],
        [
          -122.4276065826416,
          37.79106586542567
        ],
        [
          -122.4276065826416,
          37.77777043035903
        ]
      ]
    ]
  }
  """.utf8
)
