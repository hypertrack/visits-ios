import ComposableArchitecture
import MapDetailView
import NonEmpty
import SwiftUI
import Types
import Views


struct EditingMetadataView: View {
  struct State: Equatable {
    var center: PlaceCenter
    var radius: PlaceRadius
    var address: CustomAddress?
    var description: PlaceDescription?
    var company: IntegrationEntity?
  }

  enum Action: Equatable {
    case addPlaceDescriptionUpdated(PlaceDescription?)
    case cancelEditingAddPlaceMetadata
    case chooseCompany
    case createPlaceTapped
    case customAddressUpdated(CustomAddress?)
    case decreaseAddPlaceRadius
    case increaseAddPlaceRadius
  }

  let store: Store<State, Action>
  init(store: Store<State, Action>) { self.store = store }

  var body: some View {
    GeometryReader { geometry in
      WithViewStore(store) { viewStore in
        VStack(spacing: 0) {
          VStack(spacing: 0) {
            TopPadding(geometry: geometry)
            Header(
              title: "Edit Metadata",
              backAction: { viewStore.send(.cancelEditingAddPlaceMetadata) },
              refreshing: false
            )
          }
          ScrollView {
            MapDetailView(
              object: .place(
                .init(
                  id: "EditingMetadata",
                  address: .none,
                  createdAt: .init(rawValue: Date()),
                  shape: .circle(
                    .init(
                      center: viewStore.center.rawValue,
                      radius: UInt(viewStore.radius.rawValue)
                    )
                  ),
                  visits: []
                )
              )
            )
            .frame(height: 250)
            .cornerRadius(10)
            MetadataHeader("Custom Address (optional)")
            TextField(
              "",
              text: .init(
                get: {
                  viewStore.address?.string ?? ""
                },
                set: {
                  viewStore.send(
                    .customAddressUpdated(
                      NonEmptyString(rawValue: $0).map(CustomAddress.init(rawValue:))
                    )
                  )
                }
              )
            )
              .textFieldStyle(RoundedBorderTextFieldStyle())
            MetadataHeader("Company name")
            Button {
              viewStore.send(.chooseCompany)
            } label: {
              FakeTextField(company: viewStore.company)
            }
            MetadataHeader("Description (optional)")
            TextField(
              "",
              text: .init(
                get: {
                  viewStore.description?.string ?? ""
                },
                set: {
                  viewStore.send(
                    .addPlaceDescriptionUpdated(
                      NonEmptyString(rawValue: $0).map(PlaceDescription.init(rawValue:))
                    )
                  )
                }
              )
            )
              .textFieldStyle(RoundedBorderTextFieldStyle())
            MetadataHeader("Radius (meters)")
            HStack {
              Text("\(viewStore.radius.rawValue)")
                .font(.headline)
                .foregroundColor(Color(.secondaryLabel))
                .fontWeight(.bold)
              Spacer()
              Stepper(
                onIncrement: { viewStore.send(.increaseAddPlaceRadius) },
                onDecrement: { viewStore.send(.decreaseAddPlaceRadius) },
                label: {}
              )
              .labelsHidden()
            }
          }
          .padding()
          PrimaryButton(
            variant: viewStore.company != nil
              ? .normal(title: "Create Place")
              : .disabled(title: "Create Place"),
            isHovering: false
          ) {
            viewStore.send(.createPlaceTapped)
          }
          .padding([.trailing, .leading], 64)
          .padding([.bottom], 24)
        }
        .edgesIgnoringSafeArea(.top)
      }
    }
  }
}

struct EditingMetadataView_Previews: PreviewProvider {
  static var previews: some View {
    EditingMetadataView(
      store: .init(
        initialState: .init(
          center: .init(rawValue: .init(latitude: 37.768892, longitude: -122.482525)!),
          radius: .lowest,
          company: .init(id: "NVM", name: "Big Corp.")
        ),
        reducer: .empty,
        environment: ()
      )
    )
  }
}

struct MetadataHeader: View {
  let text: String

  init(_ text: String) { self.text = text }

  var body: some View {
    HStack {
      Text(text)
        .font(.headline)
        .foregroundColor(Color(.label))
      Spacer()
    }
  }
}

struct FakeTextField: View {
  let company: IntegrationEntity?
  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 5, style: .continuous)
        .strokeBorder(Color(.secondarySystemBackground), lineWidth: 1)
        .frame(height: 38)
      if let company = company {
        HStack {
          Text(company.name.string)
            .font(.headline)
            .foregroundColor(Color(.secondaryLabel))
            .fontWeight(.bold)
            .padding([.leading], 8)
          Spacer()
        }
      }
    }

  }
}
