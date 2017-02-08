//
//  AccountListCells.swift
//  RibotChallenge
//
//  Created by Ian Dundas on 07/02/2017.
//  Copyright © 2017 Ian Dundas. All rights reserved.
//

import UIKit

// MARK: Payment Cell:

public struct ProfileCellData {
    let name: String
    let backgroundColor: UIColor
    
    // public memberwise initializer not available to other frameworks, so have to define one:
    public init(name: String, backgroundColor: UIColor?){
        self.name = name
        self.backgroundColor = backgroundColor ?? .white
    }
}

public class ProfileCell: UITableViewCell {
    static public let defaultID = "ProfileCell"
    
    @IBOutlet private var name: UILabel!{
        didSet{
            name.font = Style.Fonts.cellTitleFont
        }
    }
    
    public var viewModel: ProfileCellData? {
        didSet{
            guard let viewModel = viewModel else {return}
            name.text = viewModel.name
            contentView.backgroundColor = viewModel.backgroundColor
        }
    }
}

