import UIKit

func setupUIAppearance() {
  UITableView.appearance().separatorInset = .zero
  UITableView.appearance().backgroundColor = .clear
  UITableView.appearance().separatorColor = UIColor(
    red: 199.0 / 255.0,
    green: 198.0 / 255.0,
    blue: 205.0 / 255.0,
    alpha: 1.0
  )
  UITabBar.appearance().isTranslucent = false
  UITabBar.appearance().barTintColor = UIColor(named: "TabBarBackgroundColor")
  UITabBar.appearance(for: .init(userInterfaceStyle: .dark)).backgroundImage = UIColor.gunPowder.image()
  UITabBar.appearance(for: .init(userInterfaceStyle: .light)).backgroundImage = UIColor.white.image()
  UITabBar.appearance(for: .init(userInterfaceStyle: .dark)).shadowImage = UIColor.gunPowder.image()
  UITabBar.appearance(for: .init(userInterfaceStyle: .light)).shadowImage = UIColor.white.image()
}

extension UIColor {
  func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
    return UIGraphicsImageRenderer(size: size).image { rendererContext in
      self.setFill()
      rendererContext.fill(CGRect(origin: .zero, size: size))
    }
  }
}
