//
//  Cell.swift
//  ViewsComponents
//
//  Created by Dmytro Shapovalov on 21.04.2020.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import SwiftUI

// MARK: -
// MARK: DeliveryCell
public struct DeliveryCell: View {
  @Environment(\.colorScheme) var colorScheme
  private let title: String
  private let subTitle: String
  private let onTapAction: () -> Void
  
  public init(title: String, subTitle: String = "", _ onTapAction: @escaping () -> Void = {}) {
    self.title = title
    self.subTitle = subTitle
    self.onTapAction = onTapAction
  }
  
  public var body: some View {
    GeometryReader { geometry in
      Button(action: {
        self.onTapAction()
      }, label: {
        HStack {
          VStack(alignment: .leading) {
            Text(self.title)
              .font(UIFont.Cell.titleFont.sui)
              .foregroundColor(self.colorScheme == .dark ? UIColor.TableView.Cell.Title.dark.sui : UIColor.TableView.Cell.Title.light.sui)
            if self.subTitle.isEmpty == false {
              Text(self.subTitle)
                .font(UIFont.Cell.subTitleFont.sui)
                .foregroundColor(self.colorScheme == .dark ? UIColor.TableView.Cell.SubTitle.dark.sui : UIColor.TableView.Cell.SubTitle.light.sui)
                .padding(.top, 4)
            }
          }
          Spacer()
          Image(systemName: "chevron.right").foregroundColor(self.colorScheme == .dark ? UIColor.TableView.Cell.Title.dark.sui : UIColor.TableView.Cell.Title.light.sui)
        }
        .frame(width: geometry.size.width)
      })
    }.frame(height: 50)
  }
}

struct DeliveryCell_Previews: PreviewProvider {
  static var previews: some View {
    DeliveryCell(title: "address", subTitle: "subtitle")
  }
}

// MARK: -
// MARK: ContentCell
public struct ContentCell: View {
  @Environment(\.colorScheme) var colorScheme
  private let title: String
  private let subTitle: String
  private let leadingPadding: CGFloat
  private let isCopyButtonEnabled: Bool
  private let onCopyAction: (String) -> Void
  
  public init(title: String, subTitle: String = "", leadingPadding: CGFloat = 50.0, isCopyButtonEnabled: Bool = true, _ onCopyAction: @escaping (String) -> Void = { _ in }) {
    self.title = title
    self.subTitle = subTitle
    self.leadingPadding = leadingPadding
    self.isCopyButtonEnabled = isCopyButtonEnabled
    self.onCopyAction = onCopyAction
  }
  
  public var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text(self.title)
          .font(UIFont.Cell.titleFont.sui)
          .foregroundColor(self.colorScheme == .dark ? UIColor.TableView.Cell.Title.dark.sui : UIColor.TableView.Cell.Title.light.sui)
        if self.subTitle.isEmpty == false {
          Text(self.subTitle)
            .font(UIFont.Cell.subTitleFont.sui)
            .foregroundColor(self.colorScheme == .dark ? UIColor.TableView.Cell.SubTitle.dark.sui : UIColor.TableView.Cell.SubTitle.light.sui)
            .padding(.top, 4)
        }
      }
      .padding(.leading, self.leadingPadding)
      .padding(.top, 8)
      Spacer()
      if self.isCopyButtonEnabled {
        Button(action: {
          self.onCopyAction(self.subTitle)
        }, label: {
          Text("Copy")
            .font(UIFont.Cell.titleFont.sui)
            .foregroundColor(self.colorScheme == .dark ? UIColor.TableView.Cell.Title.dark.sui : UIColor.TableView.Cell.Title.light.sui)
        })
          .padding(.trailing, 16)
      }
    }
  }
}

struct ContentCell_Previews: PreviewProvider {
  static var previews: some View {
    ContentCell(title: "address", subTitle: "501 Twin Peaks Blvd, San Francisco, CA 94114 501 Twin Peaks Blvd, San Francisco, CA 94114 ")
  }
}
