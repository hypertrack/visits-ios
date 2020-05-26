//
//  PickerView.swift
//  ViewsComponents
//
//  Created by Dmytro Shapovalov on 14.04.2020.
//  Copyright © 2020 Dmytro Shapovalov. All rights reserved.
//

import SwiftUI
import Combine
import Prelude

public struct PickerView: View {
  @Environment(\.colorScheme) var colorScheme
  @State private var selectedIndex: Int = 0
  @Binding private var isPickerShown: Bool
  private let pickerTitle: String
  private let dataSource: NonEmptyArray<String>
  private let defaultItem: NonEmptyString
  private var didSelectedItem: (_ item: NonEmptyString) -> Void
  
  public init(
    title: String,
    dataSource: NonEmptyArray<String>,
    defaultItem: NonEmptyString,
    isPickerShown: Binding<Bool>,
    _ didSelectedItem: @escaping (_ item: NonEmptyString) -> Void = {_ in})
  {
    self.pickerTitle = title
    self.dataSource = dataSource
    self.defaultItem = defaultItem
    self.didSelectedItem = didSelectedItem
    self._isPickerShown = isPickerShown
    self._selectedIndex = State(wrappedValue: dataSource.rawValue.firstIndex(where: { $0 == defaultItem.rawValue })!)
  }
  
  public var body: some View {
    if let selectedItem = NonEmptyString(rawValue: self.dataSource.rawValue[self.selectedIndex]) {
      self.didSelectedItem(selectedItem)
    }
    return VStack {
      HStack {
        Text(self.pickerTitle)
          .font(UIFont.PickerView.leftTextFont.sui)
          .foregroundColor(self.colorScheme == .dark ? UIColor.PickerView.LeftText.dark.sui : UIColor.PickerView.LeftText.light.sui)
          .padding(.leading, 16)
        Button(action: {
          self.isPickerShown.toggle()
        }, label: {
          HStack {
            Spacer()
            Text(self.dataSource.rawValue[self.selectedIndex])
              .font(UIFont.PickerView.rightTextFont.sui)
              .foregroundColor(UIColor.PickerView.RightText.default.sui)
              .lineLimit(1)
              .padding(.trailing, 16)
          }
        })
      }
      .frame(height: 44)
      if self.isPickerShown {
        HStack {
          Picker(
            selection: self.$selectedIndex,
            label: Text("")
          ) {
            ForEach(0 ..< self.dataSource.rawValue.count) {
              Text(self.dataSource.rawValue[$0])
            }
          }
          .labelsHidden()
          .onTapGesture {
            self.isPickerShown.toggle()
          }
        }
      }
    }
    .background(self.colorScheme == .dark ? UIColor.PickerView.Background.dark.sui : UIColor.PickerView.Background.light.sui)
  }
}

struct PickerView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      PickerView(title:"My app manages:", dataSource: NonEmptyArray("Gig economy", "On-demand delivery", "Logistics", "Workforce"), defaultItem: "Other", isPickerShown: .constant(true))
        .environment(\.colorScheme, .dark)
        .frame(height: 300)
      PickerView(title:"My app manages:", dataSource: NonEmptyArray("Gig economy", "On-demand delivery", "Logistics", "Workforce"), defaultItem: "Other", isPickerShown: .constant(true))
        .environment(\.colorScheme, .light)
        .frame(height: 300)
    }
  }
}
