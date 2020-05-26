//
//  Fonts.swift
//  ViewsComponents
//
//  Created by Dmytro Shapovalov on 13.04.2020.
//  Copyright © 2020 Dmytro Shapovalov. All rights reserved.
//

import Foundation
import SwiftUI

extension UIFont {
  public var sui: Font { Font(self) }
}

public extension UIFont {
  enum Button {
    public static var primaryBtFont: UIFont {
      return .systemFont(ofSize: 20.0, weight: .bold)
    }
    public static var secondaryBtFont: UIFont {
      return .systemFont(ofSize: 20.0, weight: .bold)
    }
    public static var transparentBtFont: UIFont {
      return .systemFont(ofSize: 20.0, weight: .bold)
    }
    public static var linkBtFont: UIFont {
      return .systemFont(ofSize: 16.0, weight: .medium)
    }
  }
  enum TextField {
    enum PrimaryTextField {
      public static var placeholderFont: UIFont {
        return .systemFont(ofSize: 14.0, weight: .medium)
      }
      public static var textFont: UIFont {
        return .systemFont(ofSize: 16.0, weight: .medium)
      }
      public static var errorFont: UIFont {
        return .systemFont(ofSize: 14.0, weight: .medium)
      }
    }
    enum SecureTextField {
      public static var placeholderFont: UIFont {
        return .systemFont(ofSize: 14.0, weight: .medium)
      }
      public static var textFont: UIFont {
        return .systemFont(ofSize: 16.0, weight: .medium)
      }
      public static var errorFont: UIFont {
        return .systemFont(ofSize: 14.0, weight: .medium)
      }
    }
  }
  enum TitleView {
    public static var titleFont: UIFont {
      return .systemFont(ofSize: 24.0, weight: .semibold)
    }
    public static var subtitleFont: UIFont {
      return .systemFont(ofSize: 14.0, weight: .medium)
    }
  }
  enum TextView {
    public static var textFont: UIFont {
      return .systemFont(ofSize: 14.0, weight: .medium)
    }
  }
  enum PickerView {
    public static var leftTextFont: UIFont {
      return .systemFont(ofSize: 16.0, weight: .medium)
    }
    public static var rightTextFont: UIFont {
      return .systemFont(ofSize: 16.0, weight: .medium)
    }
  }
  enum HyperLinkTextView {
    public static var textFont: UIFont {
      return .systemFont(ofSize: 14.0, weight: .medium)
    }
  }
  enum ImageTextView {
    public static var titleFont: UIFont {
      return .systemFont(ofSize: 24.0, weight: .bold)
    }
  }
  enum NavigationView {
    public static var titleFont: UIFont {
      return .systemFont(ofSize: 20.0, weight: .medium)
    }
  }
  enum SectionHeader {
    public static var titleFont: UIFont {
      return .systemFont(ofSize: 15.0, weight: .medium)
    }
  }
  enum Cell {
    public static var titleFont: UIFont {
      return .systemFont(ofSize: 17.0, weight: .bold)
    }
    public static var subTitleFont: UIFont {
      return .systemFont(ofSize: 12.0, weight: .medium)
    }
  }
  enum NotificationView {
    public static var textFont: UIFont {
      return .systemFont(ofSize: 14.0, weight: .medium)
    }
  }
  enum Alert {
    public static var titleFont: UIFont {
      return .systemFont(ofSize: 22.0, weight: .bold)
    }
  }
}
