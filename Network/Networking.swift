//
//  Networking.swift
//  RibotChallenge
//
//  Created by Ian Dundas on 06/02/2017.
//  Copyright © 2017 Ian Dundas. All rights reserved.
//

import UIKit
import ReactiveKit
import Model

typealias JSONDictionary = [String: AnyObject]
typealias JSONArray = [JSONDictionary]

func getData(url: URL) -> Signal<Data, String> {
    return Signal { observer in
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data: Data?, response:URLResponse?, error: Error?) in
            if let error = error {observer.failed(error.localizedDescription); return }
            guard let data = data else { observer.failed("Received blank response"); return }
            
            observer.completed(with: data)
        })
        
        task.resume()
        
        return BlockDisposable {
            task.cancel()
        }
    }
}

func getJSONDictionary(url: URL) -> Signal<JSONDictionary, String> {
    return getData(url: url)
        .flatMapLatest(transform: { (data: Data) -> Signal<JSONDictionary, String> in
            guard let parsed = try? JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary else {
                return Signal.failed("Could not parse JSON data")
            }
            guard let json = parsed, JSONSerialization.isValidJSONObject(json) else {
                return Signal.failed("Didn't receive valid JSON")
            }
            return Signal.just(json)
        })
}

func getJSONArray(url: URL) -> Signal<JSONArray, String> {
    return getData(url: url)
        .flatMapLatest(transform: { (data: Data) -> Signal<JSONArray, String> in
            guard let parsed = try? JSONSerialization.jsonObject(with: data, options: []) as? JSONArray else {
                return Signal.failed("Could not parse JSON data")
            }
            guard let json = parsed, JSONSerialization.isValidJSONObject(json) else {
                return Signal.failed("Didn't receive valid JSON")
            }
            return Signal.just(json)
        })
}



func fetchProfiles() -> Signal<[Profile], String> {
    guard let url = URL(string: "https://api.ribot.io/ribots") else {
        return Signal.failed("Unable to form URL");
    }
 
    let signal: Signal<[Profile], String> = getJSONArray(url: url)
        .flatMapLatest { (users: JSONArray) -> Signal<JSONArray, String> in
            let profiles: JSONArray = users.flatMap { (userData: JSONDictionary) -> JSONDictionary? in
                return userData["profile"] as? JSONDictionary
            }
            return Signal.just(profiles)
        }
        .flatMapLatest { (profiles: JSONArray) -> Signal<[Profile], String> in
            
            let profileModels: [Profile?] = profiles.map { (profileData: JSONDictionary) -> Profile? in
                
                // Ensure the non-optional fields are provided:
                guard let id = profileData["id"] as? String
                    , let email = profileData["email"] as? String
                    , let hexColor = profileData["hexColor"] as? String
                    , let isActive = profileData["isActive"] as? Bool
                    , let firstName = profileData["name"]?["first"] as? String
                    , let lastName = profileData["name"]?["last"] as? String
                else {
                    return nil
                }

                let profileModel = Profile()
                profileModel.id = id
                profileModel.email = email
                profileModel.hexColor = hexColor
                profileModel.isActive = isActive
                profileModel.firstName = firstName
                profileModel.lastName = lastName
                
                // Add optional fields:
                profileModel.bio = profileData["bio"] as? String
                profileModel.avatarURL = profileData["avatar"] as? String
                
                return profileModel
            }
            
            // return assets, stripping optionals to make concrete [Profile]
            return Signal.just(profileModels.flatMap{$0})
        }
        return signal
}

