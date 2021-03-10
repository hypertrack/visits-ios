import SwiftUI
import UIKit

public extension Color {
  static let almostWhite    = Color(#colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1))
  static let cosmicLatte    = Color(#colorLiteral(red: 0.8784313725, green: 0.9764705882, blue: 0.9215686275, alpha: 1))
  static let lilyWhite      = Color(#colorLiteral(red: 0.9529411765, green: 0.9607843137, blue: 0.9568627451, alpha: 1))
  static let titanWhite     = Color(#colorLiteral(red: 0.8784313725, green: 0.8745098039, blue: 0.9019607843, alpha: 1))
  static let ghost          = Color(#colorLiteral(red: 0.7803921569, green: 0.7764705882, blue: 0.8039215686, alpha: 1))
  static let greySuit       = Color(#colorLiteral(red: 0.5803921569, green: 0.5725490196, blue: 0.6156862745, alpha: 1))
  static let topaz          = Color(#colorLiteral(red: 0.462745098, green: 0.4509803922, blue: 0.5058823529, alpha: 1))
  static let gunPowder      = Color(#colorLiteral(red: 0.2980392157, green: 0.2941176471, blue: 0.3647058824, alpha: 1))
  static let saltBox        = Color(#colorLiteral(red: 0.3450980392, green: 0.3411764706, blue: 0.3450980392, alpha: 1))
  static let haiti          = Color(#colorLiteral(red: 0.1450980392, green: 0.1411764706, blue: 0.1843137255, alpha: 1))
  static let darkPink       = Color(#colorLiteral(red: 0.9254901961, green: 0.2509803922, blue: 0.4784313725, alpha: 1))
  static let radicalRed     = Color(#colorLiteral(red: 0.9960784314, green: 0.3019607843, blue: 0.3725490196, alpha: 1))
  static let oldGold        = Color(#colorLiteral(red: 0.8274509804, green: 0.7176470588, blue: 0.2705882353, alpha: 1))
  static let mountainMeadow = Color(#colorLiteral(red: 0.1137254902, green: 0.7607843137, blue: 0.5490196078, alpha: 1))
  static let malachite      = Color(#colorLiteral(red: 0, green: 0.8078431373, blue: 0.3568627451, alpha: 1))
  static let sherpaBlue     = Color(#colorLiteral(red: 0.003921568627, green: 0.3215686275, blue: 0.3215686275, alpha: 1))
  static let dodgerBlue     = Color(#colorLiteral(red: 0.03921568627, green: 0.5176470588, blue: 1, alpha: 1))
}

public extension UIColor {
  static let almostWhite    =       #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1)
  static let cosmicLatte    =       #colorLiteral(red: 0.8784313725, green: 0.9764705882, blue: 0.9215686275, alpha: 1)
  static let lilyWhite      =       #colorLiteral(red: 0.9529411765, green: 0.9607843137, blue: 0.9568627451, alpha: 1)
  static let titanWhite     =       #colorLiteral(red: 0.8784313725, green: 0.8745098039, blue: 0.9019607843, alpha: 1)
  static let ghost          =       #colorLiteral(red: 0.7803921569, green: 0.7764705882, blue: 0.8039215686, alpha: 1)
  static let greySuit       =       #colorLiteral(red: 0.5803921569, green: 0.5725490196, blue: 0.6156862745, alpha: 1)
  static let topaz          =       #colorLiteral(red: 0.462745098, green: 0.4509803922, blue: 0.5058823529, alpha: 1)
  static let gunPowder      =       #colorLiteral(red: 0.2980392157, green: 0.2941176471, blue: 0.3647058824, alpha: 1)
  static let saltBox        =       #colorLiteral(red: 0.3450980392, green: 0.3411764706, blue: 0.3450980392, alpha: 1)
  static let haiti          =       #colorLiteral(red: 0.1450980392, green: 0.1411764706, blue: 0.1843137255, alpha: 1)
  static let darkPink       =       #colorLiteral(red: 0.9254901961, green: 0.2509803922, blue: 0.4784313725, alpha: 1)
  static let radicalRed     =       #colorLiteral(red: 0.9960784314, green: 0.3019607843, blue: 0.3725490196, alpha: 1)
  static let oldGold        =       #colorLiteral(red: 0.8274509804, green: 0.7176470588, blue: 0.2705882353, alpha: 1)
  static let mountainMeadow =       #colorLiteral(red: 0.1137254902, green: 0.7607843137, blue: 0.5490196078, alpha: 1)
  static let malachite      =       #colorLiteral(red: 0, green: 0.8078431373, blue: 0.3568627451, alpha: 1)
  static let sherpaBlue     =       #colorLiteral(red: 0.003921568627, green: 0.3215686275, blue: 0.3215686275, alpha: 1)
  static let dodgerBlue     =       #colorLiteral(red: 0.03921568627, green: 0.5176470588, blue: 1, alpha: 1)
}

public extension Font {
  static let hugeBold            = Font.system(size: 24, weight: .bold)
  static let hugeSemibold        = Font.system(size: 24, weight: .semibold)
  static let largeBold           = Font.system(size: 22, weight: .bold)
  static let bigBold             = Font.system(size: 20, weight: .bold)
  static let bigMedium           = Font.system(size: 20, weight: .medium)
  static let normalHighBold      = Font.system(size: 17, weight: .bold)
  static let normalMedium        = Font.system(size: 16, weight: .medium)
  static let normalLowMedium     = Font.system(size: 15, weight: .medium)
  static let smallMedium         = Font.system(size: 14, weight: .medium)
  static let tinyMedium          = Font.system(size: 12, weight: .medium)
}

public extension UIFont {
  static let smallMedium = UIFont.systemFont(ofSize: 14, weight: .medium)
}
