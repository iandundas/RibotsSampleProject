//
//  Realm+reactivekit.swift
//  Tacks
//
//  Created by Ian Dundas on 21/07/2016.
//  Copyright © 2016 Ian Dundas. All rights reserved.
//

import Foundation
import ReactiveKit
import RealmSwift

public extension Realm{
    
    public func writeOperation(_ block: @escaping () -> Void) -> Signal<Void, String> {
        return Signal { observer in
            
            do {
                try self.write(block)
                observer.next()
                observer.completed()
            }
            catch (let error as NSError){
                observer.failed(error.localizedDescription)
            }
            
            return SimpleDisposable()
        }
    }
    
    // Signal which takes an object which will be passed back in the .next
    public func writeOperation<T: Object>(_ object: T, block: @escaping (T, Realm) -> Void) -> Signal<T, String> {
        return Signal { observer in
            guard !(object as Object).isInvalidated else {
                observer.failed("Object was already invalid")
                return SimpleDisposable()
            }
            
            do {
                try self.write({ 
                    block(object, self)
                })
                
                observer.next(object)
                observer.completed()
            }
            catch (let error as NSError){
                observer.failed(error.localizedDescription)
            }
            
            return SimpleDisposable()
        }
    }

    public static func addOrUpdateItemOperation<T: Object>(_ item: T, realm: Realm = try! Realm()) -> Signal<T, String> {
        return Signal { observer in
            do {
                try realm.write{
                    realm.add(item, update: true)
                }
                observer.next(item)
                observer.completed()
            }
            catch let error as NSError{
                observer.failed(error.localizedDescription)
            }
            
            return SimpleDisposable()
        }
    }
}
