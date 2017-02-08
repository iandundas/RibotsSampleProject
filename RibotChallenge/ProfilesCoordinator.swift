//
//  AccountLsCoordinator.swift
//  RibotChallenge
//
//  Created by Ian Dundas on 06/02/2017.
//  Copyright © 2017 Ian Dundas. All rights reserved.
//

import UIKit
import ReactiveKit
import RealmSwift

class ProfilesCoordinator: NSObject, Coordinator{
    
    // MARK: Coordinator:
    let identifier = "Profiles"
    let presenter: UINavigationController
    var childCoordinators: [String : Coordinator] = [:]
    
    let bag = DisposeBag()
    
    init(presenter: UINavigationController){
        self.presenter = presenter
        super.init()
        
        presenter.setNavigationBarHidden(false, animated: false)
    }

    /// Tells the coordinator to create its initial view controller and take over the user flow.
    func start(withCallback completion: CoordinatorCallback?) {
        
        // Can be fed errors which will then appear in the UI, see below
        let errors = SafeReplaySubject<String>()
        
        // Instantiate the ListViewController, passing it's viewmodel the
        // actions (i.e. UI slider events) from the accountsViewController:
        let listViewController = ListViewController.create { (listViewController) -> ListViewModelType in
            
            let viewModel = ProfileListViewModel(actions: listViewController.actions, errors: errors)
            
            listViewController.actions.rowTaps.observeNext { [weak self] (indexPath) in
                guard let strongSelf = self else {return}
                let profileKey = viewModel.profile(index: indexPath.row)
                strongSelf.show(profileKey: profileKey)
            }.dispose(in: listViewController.reactive.bag)
            
            return viewModel
        }
        
        listViewController.createCell = { (viewModel, indexPath, tableView) -> UITableViewCell in
            guard let viewModel = viewModel as? ProfileListViewModel else {fatalError("Expected ProfileListViewModel")}

            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileCell.defaultID) as! ProfileCell
            cell.viewModel = viewModel.profileCellData(index: indexPath.row)
            return cell
        }
        
        
        // Kick off network to refresh data:
        Profile.triggerNetworkRefresh()
            .feedError(into: errors) // pass any errors (saving or network) into this signal
            .observeNext { (profiles) in // observe
                print("Fetched profiles: \(profiles)")
            }.dispose(in: bag)
        
        presenter.viewControllers = [listViewController]
    }
    
    
    /// Tells the coordinator that it is done and that it should rewind the view controller state to where it was before `start` was called.
    func stop(withCallback completion: CoordinatorCallback?) {
        presenter.dismiss(animated: true){
            completion?(self)
        }
    }
    
    func show(profileKey: PrimaryKey<Profile>){
        let viewController = ProfileViewController.create { (viewController) -> ProfileViewModelType in
            let viewModel = ProfileViewModel(profileKey: profileKey)
            return viewModel
        }
        
        presenter.pushViewController(viewController, animated: true)
    }
    
    
    
}

extension Profile {
    
    // Kick off networking:
    static func triggerNetworkRefresh() -> Signal<[Profile], String>{
        
        return fetchProfiles() // network fetches (unsaved) Profile objects
            .flatMapConcat(transform: { (profiles) -> Signal<[Profile], String> in
                do {
                    // Delete old Profile objects, now that we've successfully fetched the new ones:
                    let realm = try Realm()
                    let oldProfiles = realm.objects(Profile.self)
                    try realm.write {
                        oldProfiles.forEach(realm.delete)
                    }
                    return Signal.just(profiles)
                }
                catch (let error as NSError) {
                    return Signal.failed(error.localizedDescription)
                }
            })
            .flatMapConcat { (profiles: [Profile]) -> Signal<Profile, String> in
                // flatMap to a Signal of profiles, instead of a Signal of profile arrays:
                return Signal.sequence(profiles)
            }
            .flatMapLatest { (profile) -> Signal<Profile, String> in
                // For each profile, flat map a Save Signal (add or update):
                return Realm.addOrUpdateItemOperation(profile)
            }
            .collect() // return to a Signal of Profile arrays:
        
    }
}
