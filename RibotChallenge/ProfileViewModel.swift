//
//  ProfileViewModel.swift
//  RibotChallenge
//
//  Created by Ian Dundas on 08/02/2017.
//  Copyright © 2017 Ian Dundas. All rights reserved.
//

import Foundation
import ReactiveKit
import UIKit

class ProfileViewModel: ProfileViewModelType{
    
    private let profileKey: PrimaryKey<Profile>
    init(profileKey: PrimaryKey<Profile>){
        self.profileKey = profileKey
    }
    
    var avatar: Signal<UIImage, NoError>{
        guard let profile = profileKey.vend(), let url = profile.avatarURL else {return Signal.never()}
        return fetchImage(url: url).suppressError(logging: true)
    }
    
    var title: String? {
        return profileKey.vend()?.fullName
    }
    
    var email: String? {
        return profileKey.vend()?.email
    }
    
    var bio: String? {
        return profileKey.vend()?.bio
    }
}
