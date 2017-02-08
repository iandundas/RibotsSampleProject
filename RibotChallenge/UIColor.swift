//
//  UIColor.swift
//  RibotChallenge
//
//  Created by Ian Dundas on 08/02/2017.
//  Copyright © 2017 Ian Dundas. All rights reserved.
//

import UIKit

// Thanks to: http://stackoverflow.com/a/33397427/349364
extension UIColor {
    convenience init?(hex: String) {
        var int = UInt32()
        let stripped = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        Scanner(string: stripped).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch stripped.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
