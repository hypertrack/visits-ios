//
//  SectionHeader.swift
//  ViewsComponents
//
//  Created by Dmytro Shapovalov on 21.04.2020.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import SwiftUI

public struct SectionView<Content: View>: View {
  @Environment(\.colorScheme) var colorScheme
  private let title: String
  private let content: () -> Content
  
  public init(headerTitle: String, @ViewBuilder content: @escaping () -> Content) {
    self.title = headerTitle
    self.content = content
  }
  
   public var body: some View {
    Section {
      HStack {
        Spacer()
        SectionHeader(headerTitle: self.title)
        Spacer()
      }
      self.content()
    }
    .listRowBackground(self.colorScheme == .dark ? UIColor.TableView.Section.BackgroundColor.dark.sui : UIColor.TableView.Section.BackgroundColor.light.sui)
  }
}

public struct SectionHeader: View {
  @Environment(\.colorScheme) var colorScheme
  private let title: String
  
  public init(headerTitle: String) {
    self.title = headerTitle
  }
  
  public var body: some View {
    Text(self.title)
      .font(UIFont.SectionHeader.titleFont.sui)
      .foregroundColor(self.colorScheme == .dark ? UIColor.TableView.Section.Title.dark.sui : UIColor.TableView.Section.Title.light.sui)
  }
}

struct SectionHeader_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      SectionHeader(headerTitle: "Pending deliveries").environment(\.colorScheme, .light)
      SectionHeader(headerTitle: "Pending deliveries").environment(\.colorScheme, .dark)
    }
  }
}
