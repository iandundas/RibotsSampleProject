//
//  AccountListViewModel.swift
//  RibotChallenge
//
//  Created by Ian Dundas on 06/02/2017.
//  Copyright © 2017 Ian Dundas. All rights reserved.
//

import Foundation
import ReactiveKit
import RealmSwift
import Model
import Diff


// We consume [ListUpdate] events, map to these from the Diff from old->new Realm Results:
extension Diff {
    func toListUpdate() -> [ListUpdate] {
        return elements.map { (diffElement) -> ListUpdate in
            switch diffElement{
                
            case let .insert(at: index):
                return .sectionChange(
                    sectionIndex: 0,
                    deletions: [],
                    insertions: [index],
                    modifications: [])
                
            case let .delete(at: index):
                return .sectionChange(
                    sectionIndex: 0,
                    deletions: [index],
                    insertions: [],
                    modifications: [])
            }
        }
    }
}

class ProfileListViewModel: ListViewModelType, UserNoticeable{
    
    // MARK: UserNoticeable
    let errors: SafeSignal<String>
    
    // MARK: ListViewModelType:
    let title = "🏂"
    
    // Public (immutable) signal indicating List updated
    var listDidUpdate: Signal<ListUpdate, NoError>{
        return profilesUpdated.toSignal()
    }
    
    // Private (mutable) PublishSubject allows events to be sent on itself - indicating Profiles updated in this case
    fileprivate let profilesUpdated = SafePublishSubject<ListUpdate>()
    
    fileprivate var profiles: Results<Profile>
    
    // retain Realm notification tokens:
    private var profileUpdatesToken: NotificationToken? = nil
    
    private let bag = DisposeBag()
    init(actions: ListViewController.Actions, errors: SafeReplaySubject<String>, realm: Realm = try! Realm()){
        self.errors = errors.toSignal()
        self.profiles = realm.objects(Profile.self)
        
        profileUpdatesToken = profiles.addNotificationBlock { [ weak self] (changes: RealmCollectionChange<Results<Profile>>) in
            guard let strongSelf = self else {return}
            
            switch changes {
            case .initial(_): break // not actually necessary as TableView pulls via .reloadData() to start with.
                
            case let .update(_, deletions: deletedIndexes, insertions: insertedIndexes, modifications: updatedIndexes):
                strongSelf.profilesUpdated.next(.sectionChange(
                    sectionIndex: 0,
                    deletions: deletedIndexes,
                    insertions: insertedIndexes,
                    modifications: updatedIndexes))
                
            case .error(let error):
                // just log it for now
                print("Error: \(error)")
            }
        }
    }
    
    func sectionCount() -> Int {
        return 1
    }
    
    func itemCount(section index: Int) -> Int {
        return profiles.count
    }
    
    
    // For Coordinator:
    func profileCellData(index: Int) -> ProfileCellData{
        return profiles[index].cellViewModel()
    }
    
    func profile(index: Int) -> PrimaryKey<Profile>{
        return PrimaryKey(item: profiles[index])
    }
}

extension Profile{
    func cellViewModel() -> ProfileCellData{
        print("\(self)")
        let viewModel = ProfileCellData(name: fullName, backgroundColor: color)
        return viewModel
    }
}
