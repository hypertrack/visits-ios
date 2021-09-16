import UIKit


func setupUIAppearance() {
  /// Fix iOS 15 Tab Bar translucency bug when scolling to the bottom
  /// or pushing and popping views
  if #available(iOS 15.0, *) {
    let bar = UITabBarAppearance()
    bar.configureWithOpaqueBackground()
    UITabBar.appearance().scrollEdgeAppearance = bar
  }
}
