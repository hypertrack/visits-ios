import Foundation
import UIKit
import SwiftUI

extension UIColor {
  /// returns SwiftUI Color
  public var sui: Color { Color(self) }
}

extension UIColor {
  public enum Beckground {
    public enum AppBackgroundColor {
      public static var light = UIColor(white: 1.0, alpha: 1.0)
      public static var dark = UIColor(
        red: 37.0 / 255.0,
        green: 36.0 / 255.0,
        blue: 47.0 / 255.0,
        alpha: 1.0
      )
    }
  }
  public enum Button {
    public enum PrimaryBtColor {
      public enum GreenGradientState {
        public static var gradientStartColor = UIColor(
          red: 0.0,
          green: 206.0 / 255.0,
          blue: 91.0 / 255.0,
          alpha: 1.0
        )
        public static var gradientEndColor = UIColor(
          red: 29.0 / 255.0,
          green: 194.0 / 255.0,
          blue: 140.0 / 255.0,
          alpha: 1.0
        )
      }
      public enum RedGradientState {
        public static var gradientStartColor = UIColor(
          red: 236.0 / 255.0,
          green: 64.0 / 255.0,
          blue: 122.0 / 255.0,
          alpha: 1.0
        )
        public static var gradientEndColor = UIColor(
          red: 1.0,
          green: 82.0 / 255.0,
          blue: 82.0 / 255.0,
          alpha: 1.0
        )
      }
      public enum TitleColor {
        public static var `default` = UIColor(white: 1.0, alpha: 1.0)
      }
      public static var pressedColor = UIColor(white: 0.0, alpha: 1.0)
      public static var disabledColor = UIColor(
        red: 148.0 / 255.0,
        green: 146.0 / 255.0,
        blue: 157.0 / 255.0,
        alpha: 1.0
      )
    }
    public enum SecondaryBtColor {
      public enum TitleColor {
        public static var light = UIColor(
          red: 118.0 / 255.0,
          green: 115.0 / 255.0,
          blue: 129.0 / 255.0,
          alpha: 1.0
        )
        public static var dark = UIColor(
          red: 199.0 / 255.0,
          green: 198.0 / 255.0,
          blue: 205.0 / 255.0,
          alpha: 1.0
        )
      }
    }
    public enum TransparentButton {
      public enum BeckgroundColor {
        public static var light = UIColor(
          red: 224.0 / 255.0,
          green: 249.0 / 255.0,
          blue: 235 / 255.0,
          alpha: 1.0
        )
        public static var dark = UIColor.clear
      }
      
      public enum TitleColor {
        public static var `default` = UIColor(
          red: 0.0,
          green: 206.0 / 255.0,
          blue: 91.0 / 255.0,
          alpha: 1.0
        )
      }
      
      public enum BorderColor {
        public static var light = UIColor.clear
        public static var dark = UIColor(
          red: 0.0,
          green: 206.0 / 255.0,
          blue: 91.0 / 255.0,
          alpha: 1.0
        )
      }
    }
    public enum LinkButton {
      public static var titleColor = UIColor(
        red: 10.0 / 255.0,
        green: 132.0 / 255.0,
        blue: 255.0 / 255.0,
        alpha: 1.0
      )
      public static var backgroundColor = UIColor.clear
    }
    public enum NavigationButton {
      public enum BeckgroundColor {
        public static var light = UIColor.black
        public static var dark = UIColor.white
      }
    }
  }
  public enum TextField {
    public enum PrimaryTextFieldColor {
      public static var placeholderColor = UIColor(
        red: 148.0 / 255.0,
        green: 146.0 / 255.0,
        blue: 157.0 / 255.0,
        alpha: 1.0
      )
      public static var borderColor = UIColor(
        red: 199.0 / 255.0,
        green: 198.0 / 255.0,
        blue: 205.0 / 255.0,
        alpha: 1.0
      )
      public static var errorColor = UIColor(
        red: 254.0 / 255.0,
        green: 77.0 / 255.0,
        blue: 95.0 / 255.0,
        alpha: 1.0
      )
    }
    public enum SecureTextFieldColor {
      public static var placeholderColor = UIColor(
        red: 148.0 / 255.0,
        green: 146.0 / 255.0,
        blue: 157.0 / 255.0,
        alpha: 1.0
      )
      public static var borderColor = UIColor(
        red: 199.0 / 255.0,
        green: 198.0 / 255.0,
        blue: 205.0 / 255.0,
        alpha: 1.0
      )
      public static var errorColor = UIColor(
        red: 254.0 / 255.0,
        green: 77.0 / 255.0,
        blue: 95.0 / 255.0,
        alpha: 1.0
      )
    }
  }
  public enum TitleView {
    public enum BackgroundColor {
      public static var light = UIColor(white: 1.0, alpha: 1.0)
      public static var dark = UIColor(
        red: 37.0 / 255.0,
        green: 36.0 / 255.0,
        blue: 47.0 / 255.0,
        alpha: 1.0
      )
    }
    public enum TitleColor {
      public static var light = UIColor(
        red: 76.0 / 255.0,
        green: 75.0 / 255.0,
        blue: 93.0 / 255.0,
        alpha: 1.0
      )
      public static var dark = UIColor.white
    }
    public enum subTitleColor {
      public static var light = UIColor(
        red: 148.0 / 255.0,
        green: 146.0 / 255.0,
        blue: 157.0 / 255.0,
        alpha: 1.0
      )
      public static var dark = UIColor(
        red: 199.0 / 255.0,
        green: 198.0 / 255.0,
        blue: 205.0 / 255.0,
        alpha: 1.0
      )
    }
  }
  public enum TextView {
    public static var light = UIColor(
      red: 76.0 / 255.0,
      green: 75.0 / 255.0,
      blue: 93.0 / 255.0,
      alpha: 1.0
    )
    public static var dark = UIColor(
      red: 250.0 / 255.0,
      green: 250.0 / 255.0,
      blue: 250.0 / 255.0,
      alpha: 1.0
    )
    public static var grayTextColor = UIColor(
      red: 148.0 / 255.0,
      green: 146.0 / 255.0,
      blue: 157.0 / 255.0,
      alpha: 1.0
    )
  }
  public enum PickerView {
    public enum Background {
      public static var light = UIColor(
        red: 255.0 / 255.0,
        green: 255.0 / 255.0,
        blue: 255.0 / 255.0,
        alpha: 1.0
      )
      public static var dark = UIColor(
        red: 76.0 / 255.0,
        green: 75.0 / 255.0,
        blue: 93.0 / 255.0,
        alpha: 1.0
      )
    }
    public enum LeftText {
      public static var light = UIColor(
        red: 76.0 / 255.0,
        green: 75.0 / 255.0,
        blue: 93.0 / 255.0,
        alpha: 1.0
      )
      public static var dark = UIColor(
        red: 250.0 / 255.0,
        green: 250.0 / 255.0,
        blue: 250.0 / 255.0,
        alpha: 1.0
      )
    }
    public enum RightText {
      public static var `default` = UIColor(
        red: 10.0 / 255.0,
        green: 132.0 / 255.0,
        blue: 255.0 / 255.0,
        alpha: 1.0
      )
    }
  }
  public enum HyperLinkTextView {
    public static var textColor = UIColor(
      red: 148.0 / 255.0,
      green: 146.0 / 255.0,
      blue: 157.0 / 255.0,
      alpha: 1.0
    )
    public static var linkTextColor = UIColor(
      red: 10.0 / 255.0,
      green: 132.0 / 255.0,
      blue: 1.0,
      alpha: 1.0
    )
  }
  public enum ImageTextView {
    public enum TitleViewColor {
      public static var light = UIColor(
        red: 76.0 / 255.0,
        green: 75.0 / 255.0,
        blue: 93.0 / 255.0,
        alpha: 1.0
      )
      public static var dark = UIColor(
        red: 255.0 / 255.0,
        green: 255.0 / 255.0,
        blue: 255.0 / 255.0,
        alpha: 1.0
      )
    }
  }
  public enum NavigationView {
    public enum BackgroundColor {
      public static var light = UIColor(
        red: 255.0 / 255.0,
        green: 255.0 / 255.0,
        blue: 255.0 / 255.0,
        alpha: 1.0
      )
      public static var dark = UIColor(
        red: 76.0 / 255.0,
        green: 75.0 / 255.0,
        blue: 93.0 / 255.0,
        alpha: 1.0
      )
    }
    public enum TitleColor {
      public static var light = UIColor.black
      public static var dark = UIColor.white
    }
  }
  public enum TableView {
    public static var separatorColor = UIColor(
      red: 199.0 / 255.0,
      green: 198.0 / 255.0,
      blue: 205.0 / 255.0,
      alpha: 1.0
    )
    public enum Section {
      public enum BackgroundColor {
        public static var light = UIColor(
          red: 243.0 / 255.0,
          green: 245.0 / 255.0,
          blue: 244.0 / 255.0,
          alpha: 1.0
        )
        public static var dark = UIColor(
          red: 76.0 / 255.0,
          green: 75.0 / 255.0,
          blue: 93.0 / 255.0,
          alpha: 1.0
        )
      }
      public enum Title {
        public static var light = UIColor(
          red: 76.0 / 255.0,
          green: 75.0 / 255.0,
          blue: 93.0 / 255.0,
          alpha: 1.0
        )
        public static var dark = UIColor(
          red: 255.0 / 255.0,
          green: 255.0 / 255.0,
          blue: 255.0 / 255.0,
          alpha: 1.0
        )
      }
      public enum SubTitle {
        public static var light = UIColor(
          red: 148.0 / 255.0,
          green: 146.0 / 255.0,
          blue: 157.0 / 255.0,
          alpha: 1.0
        )
        public static var dark = UIColor(
          red: 224.0 / 255.0,
          green: 223.0 / 255.0,
          blue: 230.0 / 255.0,
          alpha: 1.0
        )
      }
    }
    public enum Cell {
      public enum Title {
        public static var light = UIColor(
          red: 76.0 / 255.0,
          green: 75.0 / 255.0,
          blue: 93.0 / 255.0,
          alpha: 1.0
        )
        public static var dark = UIColor(
          red: 255.0 / 255.0,
          green: 255.0 / 255.0,
          blue: 255.0 / 255.0,
          alpha: 1.0
        )
      }
      public enum SubTitle {
        public static var light = UIColor(
          red: 148.0 / 255.0,
          green: 146.0 / 255.0,
          blue: 157.0 / 255.0,
          alpha: 1.0
        )
        public static var dark = UIColor(
          red: 224.0 / 255.0,
          green: 223.0 / 255.0,
          blue: 230.0 / 255.0,
          alpha: 1.0
        )
      }
    }
  }
  public enum NotificationView {
    public static var textColor = UIColor.white
    public enum BackgroundColor {
      public static var primaryBackgroundColor = UIColor(
        red: 10.0 / 255.0,
        green: 132.0 / 255.0,
        blue: 255.0 / 255.0,
        alpha: 1.0
      )
      public static var onVisitedBackgroundColor = UIColor(
        red: 211.0 / 255.0,
        green: 183.0 / 255.0,
        blue: 69.0 / 255.0,
        alpha: 1.0
      )
      public static var onCompletedBackgroundColor = UIColor(
        red: 0.0 / 255.0,
        green: 205.0 / 255.0,
        blue: 91.0 / 255.0,
        alpha: 1.0
      )
    }
  }
  public enum RaundedStack {
    public static var light = UIColor(
      red: 255.0 / 255.0,
      green: 255.0 / 255.0,
      blue: 255.0 / 255.0,
      alpha: 1.0
    )
    public static var dark = UIColor(
      red: 76.0 / 255.0,
      green: 75.0 / 255.0,
      blue: 93.0 / 255.0,
      alpha: 1.0
    )
  }
  public enum AlertColor {
    public static var light = UIColor(
      red: 88 / 255,
      green: 87 / 255,
      blue: 88 / 255,
      alpha: 1
    )
    public static var dark = UIColor(
      red: 76.0 / 255.0,
      green: 75.0 / 255.0,
      blue: 93.0 / 255.0,
      alpha: 1.0
    )
  }
}
