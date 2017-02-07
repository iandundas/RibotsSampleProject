//
//  Profile.swift
//  RibotChallenge
//
//  Created by Ian Dundas on 06/02/2017.
//  Copyright © 2017 Ian Dundas. All rights reserved.
//

import Foundation
import RealmSwift

class Profile: Object{
    
    override open static func primaryKey() -> String? {
        return "id"
    }
    
    open dynamic var id = UUID().uuidString
    
    open dynamic var firstName: String = ""
    
    open dynamic var lastName: String = ""
    
    open dynamic var email: String = ""
    
    open dynamic var avatarURL: String?
    
    open dynamic var hexColor: String = ""
    
    open dynamic var bio: String? = ""
    
    open dynamic var isActive: Bool = false
}
