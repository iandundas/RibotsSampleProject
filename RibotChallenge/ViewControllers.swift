//
//  ViewControllers.swift
//  RibotChallenge
//
//  Created by Ian Dundas on 08/02/2017.
//  Copyright © 2017 Ian Dundas. All rights reserved.
//

import Foundation
import ReactiveKit

protocol UserNoticeable {
    var errors: SafeSignal<String> {get}
}
