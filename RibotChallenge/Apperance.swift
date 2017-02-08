//
//  Style.swift
//  RibotChallenge
//
//  Created by Ian Dundas on 06/02/2017.
//  Copyright © 2017 Ian Dundas. All rights reserved.
//

import UIKit

public enum Style {} // used for namespacing http://khanlou.com/2016/06/easy-namespacing-in-swift/

extension Style{
    public struct Fonts {
        public static let navbarFont = UIFont(name: "AvenirNextCondensed-Medium", size: 26.0)!
        public static let navbuttonFont = UIFont(name: "Avenir-Roman", size: 17.0)!
        
        public static let cellTitleFont = UIFont(name: "Avenir-Book", size: 17)
        public static let cellSubtitleFont = UIFont(name: "Avenir-Light", size: 14)
        public static let cellValueFont = UIFont(name: "Avenir-Heavy", size: 16)
        public static let cellSubvalueFont = UIFont(name: "Avenir-MediumOblique", size: 13)
    }
    
    public struct Colors {
        public static let ingBlue = UIColor(red: 21.0 / 255.0, green: 126.0 / 255.0, blue: 251.0 / 255.0, alpha: 1.0)
        public static let ingWhite = UIColor(white: 215.0 / 255.0, alpha: 1.0)
    }
    
    public static func applyGlobal(){
        
        // MARK: NavigationBar:
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barTintColor = .white
        UINavigationBar.appearance().tintColor = Colors.ingBlue
        
        let attrs: [String:AnyObject] = [
            NSForegroundColorAttributeName : Colors.ingBlue,
            NSFontAttributeName : Fonts.navbarFont
        ]
        UINavigationBar.appearance().titleTextAttributes = attrs
        
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).setTitleTextAttributes([
            NSFontAttributeName: Fonts.navbuttonFont,
            NSForegroundColorAttributeName: Colors.ingBlue
            ], for: .normal)
        
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).setTitleTextAttributes([
            NSFontAttributeName: Fonts.navbuttonFont,
            NSForegroundColorAttributeName: Colors.ingWhite
            ], for: .disabled)
    }
}
