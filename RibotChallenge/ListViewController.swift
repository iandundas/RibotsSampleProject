//
//  ListViewController.swift
//  RibotChallenge
//
//  Created by Ian Dundas on 07/02/2017.
//  Copyright © 2017 Ian Dundas. All rights reserved.
//

import UIKit
import ReactiveKit
import Bond

public enum ListUpdate{
    case initial
    case sectionChange(sectionIndex: Int, deletions: [Int], insertions: [Int], modifications: [Int])
}

public protocol ListViewModelType{
    var title: String {get}
    
    var listDidUpdate: SafeSignal<ListUpdate> {get}
    
    func sectionCount() -> Int
    func itemCount(section index: Int) -> Int
}

public class ListViewController: BaseBoundViewController<ListViewModelType>, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet private var tableView: UITableView!{
        didSet{
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    // MARK: Configuration points:
    public var createCell: ((ListViewModelType, IndexPath, UITableView) -> UITableViewCell)?
    public var rowHeight: CGFloat = 50
    public var sectionHeight: CGFloat = 30
    
    // MARK: Binding
    override internal func bindTo(viewModel: ListViewModelType) {
     
        if let noticable = viewModel as? UserNoticeable{
            noticable.errors.bind(to: self, setter: { (me, errorMessage) in
                me.displayError(errorMessage: errorMessage)
            })
        }
        
        // bind(to: Deallocatable) removes need to [weak self] to access tableview
        viewModel.listDidUpdate.bind(to: self.tableView) { (tableView: UITableView, changes: ListUpdate) in
            
            switch changes {
            case .initial:
                tableView.reloadData()
                
            case let .sectionChange(sectionIndex: sectionIndex, deletions: deletedIndexes, insertions: insertedIndexes, modifications: modifiedIndexes):
                let deletedIndexPaths = deletedIndexes.map {IndexPath(row: $0, section: sectionIndex)}
                let insertedIndexPaths = insertedIndexes.map {IndexPath(row: $0, section: sectionIndex)}
                let modifiedIndexPaths = modifiedIndexes.map {IndexPath(row: $0, section: sectionIndex)}

                tableView.beginUpdates()
                tableView.deleteRows(at: deletedIndexPaths, with: .automatic)
                tableView.insertRows(at: insertedIndexPaths, with: .automatic)
                tableView.reloadRows(at: modifiedIndexPaths, with: .automatic)
                tableView.endUpdates()
            }
        }
    }
    
    func displayError(errorMessage: String){
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "okay", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: UITableViewDelegate
    public func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sectionCount()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = viewModel.itemCount(section: section)
        return rows
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let createCell = createCell else { fatalError("Please provide a createCell configuration closure.") }
        let cell = createCell(viewModel, indexPath, tableView)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionHeight
    }
    
    fileprivate let rowTaps = SafePublishSubject<IndexPath>()
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        rowTaps.next(indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// Default usage of List VC (have the ability to use another Storyboard, but this is the default):
public extension ListViewController {
    public static func create(viewModelFactory: @escaping (ListViewController) -> ListViewModelType) -> ListViewController{
        return create(storyboard: UIStoryboard(name: "List", bundle: Bundle.main), viewModelFactory: downcast(closure: viewModelFactory)) as! ListViewController
    }
}

public extension ListViewController{
    
    public struct Actions {
        let rowTaps: SafeSignal<IndexPath>
    }
    
    public var actions: Actions {
        return Actions(
            rowTaps: rowTaps.toSignal()
        )
    }
}
