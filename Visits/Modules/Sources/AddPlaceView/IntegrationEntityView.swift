import ComposableArchitecture
import SwiftUI
import Types
import Views


struct IntegrationEntityView: View {
  let integrationEntity: IntegrationEntity

  var body: some View {
    HStack {
      Image(systemName: "building.2.crop.circle")
        .font(.title)
        .foregroundColor(.accentColor)
        .frame(width: 20, height: 20, alignment: .center)
        .padding(.trailing, 10)
      PrimaryRow(
        integrationEntity.name.string
      )
    }
    .padding(.vertical, 10)
  }
}
