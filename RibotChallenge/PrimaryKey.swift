//
//  PrimaryKey.swift
//  Tacks
//
//  Created by Ian Dundas on 03/02/2017.
//  Copyright © 2017 Ian Dundas. All rights reserved.
//

import Foundation
import RealmSwift
import Bond
import ReactiveKit

/*  Realm is not thread-safe by default, so we should pass around these instead
    It's a wrapper which takes the "primary key" value for a given type, and retrieves 
    the concrete value based on that.
 */

public class PrimaryKey<Item: RealmSwift.Object>{
    public let id: String
    
    public init(id: String){
        self.id = id
    }
    
    public init(item: Item){
        guard let primaryKey = Item.primaryKey() else {fatalError("Realm object does not have a Primary Key field")}
        id = item.value(forKey: primaryKey) as! String
    }
    
    public func vend(realm: Realm = try! Realm()) -> Item? {
        guard let primaryKey = Item.primaryKey() else {return nil}
        let object = realm.objects(Item.self).filter("\(primaryKey) = %@", id).first
        return object
    }
}

extension PrimaryKey: Equatable{
    public static func ==(a:PrimaryKey, b: PrimaryKey) -> Bool{
        return a.id == b.id
    }
}

