//
//  Profile.swift
//  RibotChallenge
//
//  Created by Ian Dundas on 06/02/2017.
//  Copyright © 2017 Ian Dundas. All rights reserved.
//

import UIKit
import RealmSwift

class Profile: Object{
    
    override open static func primaryKey() -> String? {
        return "id"
    }
    
    open dynamic var id = UUID().uuidString
    
    open dynamic var firstName: String = ""
    
    open dynamic var lastName: String = ""
    
    open dynamic var email: String = ""
    
    open dynamic var avatar: String?
    
    open dynamic var hexColor: String = ""
    
    open dynamic var bio: String? = ""
    
    open dynamic var isActive: Bool = false
}

extension Profile{
    var color: UIColor? {
        return UIColor(hex: hexColor)
    }
    
    // Possible over-simplification here, some people don't have a last name etc. TODO - find out JSON spec.
    var fullName: String{
        return "\(firstName) \(lastName)"
    }
    
    var avatarURL: URL?{
        guard let string = avatar else {return nil}
        return URL(string: string)
    }
}
