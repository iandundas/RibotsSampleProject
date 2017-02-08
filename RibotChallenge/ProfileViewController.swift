//
//  ProfileViewController.swift
//  RibotChallenge
//
//  Created by Ian Dundas on 08/02/2017.
//  Copyright © 2017 Ian Dundas. All rights reserved.
//

import UIKit
import ReactiveKit

protocol ProfileViewModelType{
    var title: String? {get}
    var email: String? {get}
    var bio: String? {get}
    
    var avatar: SafeSignal<UIImage> {get}
}

class ProfileViewController: BaseBoundViewController<ProfileViewModelType> {
    @IBOutlet var email: UILabel!
    @IBOutlet var bio: UILabel!
    @IBOutlet var stackView: UIStackView!
    
    override func bindTo(viewModel: ProfileViewModelType) {
        title = viewModel.title
        email.text = viewModel.email
        bio.text = viewModel.bio
        
        viewModel.avatar
            .take(first: 1)
            .observeOn(DispatchQueue.main)
            .bind(to: stackView) { (stackView: UIStackView, avatar: UIImage) in
                let imageView = UIImageView(image: avatar)
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
                imageView.contentMode = .scaleAspectFit
                stackView.insertArrangedSubview(imageView, at: 0)
            }
    }
}

// Default usage of Profile VC (have the ability to use another Storyboard, but this is the default):
extension ProfileViewController {
    public static func create(viewModelFactory: @escaping (ProfileViewController) -> ProfileViewModelType) -> ProfileViewController{
        return create(storyboard: UIStoryboard(name: "Profile", bundle: Bundle.main), viewModelFactory: downcast(closure: viewModelFactory)) as! ProfileViewController
    }
}
