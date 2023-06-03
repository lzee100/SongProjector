//
//  TagsController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 25/03/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import UIKit

class TagsController: ChurchBeamViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
    
    
    // MARK: - Properties
    
    @IBOutlet var tableView: UITableView!
    
    override var requesters: [RequesterBase] {
        return [TagFetcher, TagSubmitter]
    }
    
    // MARK: - Private  Properties
    
    private var tags: [VTag] = []
    private var filteredTags: [VTag] = []
    private var editingInfo: (RequestMethod, IndexPath?)?
    private var searchController: UISearchController!
    
    
    // MARK: - UIView Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = AppText.Tags.title
        tableView.register(cell: BasicCell.identifier)
        tableView.register(header: BasicHeaderView.identifier)
        tableView.rowHeight = 60
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.editTableView(_:)))
        longPressGesture.minimumPressDuration = 0.7
        self.tableView.addGestureRecognizer(longPressGesture)
        navigationItem.rightBarButtonItem?.tintColor = themeHighlighted
        navigationController?.navigationBar.isTranslucent = false
        let doubleTab = UITapGestureRecognizer(target: self, action: #selector(self.editTableView(_:)))
        doubleTab.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTab)
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = AppText.Tags.placeholder
        searchController.searchBar.tintColor = themeHighlighted
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.setEditing(false, animated: false)
        update()
        TagFetcher.fetch()
    }
    
    
    
    // MARK: - UITableView Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BasicCell.identifier) as! BasicCell
        
        cell.setup(title: filteredTags[indexPath.row].title ?? "No name")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return !searchController.isActive
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = filteredTags[sourceIndexPath.row]
        tags.remove(at: sourceIndexPath.row)
        tags.insert(itemToMove, at: destinationIndexPath.row)
        updatePostitions()
        editingInfo = (.put, nil)
        TagSubmitter.submit(filteredTags, requestMethod: .put)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if filteredTags[indexPath.row].isDeletable {
            let deleteView = tableView.subviews.compactMap({ $0.subviews }).first(where: { $0.contains(where: { $0 is BasicCell }) })?.first
            deleteView?.style(tableView: tableView, forRowAt: indexPath)
            return .delete
        }
        return .none
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        editingInfo = (.delete, indexPath)
        TagSubmitter.submit([filteredTags[indexPath.row]], requestMethod: .delete)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showEditTag(tag: filteredTags[indexPath.row], indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.style(cell, forRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.basicHeaderView
        view?.descriptionLabel.text = nil
        return view
    }
    
//    override func requesterDidFinish(requester: RequesterBase, result: RequestResult, isPartial: Bool) {
//        self.navigationItem.rightBarButtonItems?.forEach({ $0.isEnabled = true })
//        self.hideLoader()
//        switch result {
//        case .failed(let error): self.show(error)
//        case .success(_):
//            if requester.id == TagSubmitter.id, let editingInfo = self.editingInfo {
//                if editingInfo.0 == .delete, let indexPath = editingInfo.1 {
//                    if let index = self.tags.firstIndex(where: { $0.id == self.filteredTags[indexPath.row].id }) {
//                        self.tags.remove(at: index)
//                    }
//                    self.filteredTags.remove(at: indexPath.row)
//                    self.tableView.deleteRows(at: [indexPath], with: .top)
//                    Queues.main.asyncAfter(deadline: .now() + 0.4) {
//                        self.tableView.reloadData()
//                    }
//                } else if editingInfo.0 == .put, let indexPath = editingInfo.1 {
//                    let tags: [Tag] = DataFetcher().getEntities(moc: moc, predicates: [.skipDeleted], sort: NSSortDescriptor(key: "position", ascending: true))
//                    self.tags = tags.map({ VTag(tag: $0, context: moc) })
//                    self.tableView.reloadRows(at: [indexPath], with: .fade)
//                } else {
//                    let tags: [Tag] = DataFetcher().getEntities(moc: moc, predicates: [.skipDeleted], sort: NSSortDescriptor(key: "position", ascending: true))
//                    self.tags = tags.map({ VTag(tag: $0, context: moc) })
//                    self.tableView.reloadData()
//                }
//            } else {
//                update()
//            }
//        }
//        self.editingInfo = nil
//    }
    
//    override func update() {
//        let tags: [Tag] = DataFetcher().getEntities(moc: moc, predicates: [.skipDeleted], sort: NSSortDescriptor(key: "position", ascending: true))
//        self.tags = tags.map({ VTag(tag: $0, context: moc) })
//        self.filteredTags = self.tags
//        self.tableView.reloadData()
//    }
    
    
    
    // MARK: - Private functions
    
    
    private func showEditTag(tag: VTag, indexPath: IndexPath) {
        let name = tag.title
        let controller = UIAlertController(title: AppText.Tags.newTag, message: nil, preferredStyle: .alert)
        controller.addTextField { (textField) in
            textField.placeholder = AppText.Tags.name
            textField.text = name
        }
        controller.addAction(UIAlertAction(title: AppText.Actions.save, style: .default, handler: { (_) in
            if let newName = controller.textFields?.first?.text, name != newName, !newName.isBlanc {
                tag.title = newName
                self.editingInfo = (.put, indexPath)
                TagSubmitter.submit([tag], requestMethod: .put)
            }
        }))
        controller.addAction(UIAlertAction(title: AppText.Actions.cancel, style: .cancel, handler: { (_) in
            
        }))
        self.present(controller, animated: true)
    }
    
    private func updatePostitions() {
        for (index, tag) in tags.enumerated() {
            tag.position = Int16(index)
        }
    }
    
    @objc private func editTableView(_ gestureRecognizer: UIGestureRecognizer) {
        guard !searchController.isActive else { return }
        if let gestureRecognizer = gestureRecognizer as? UILongPressGestureRecognizer {
            if gestureRecognizer.state == UIGestureRecognizer.State.began {
                changeEditingState()
            }
        } // for double tab
        else if let _ = gestureRecognizer as? UITapGestureRecognizer, tableView.isEditing {
            changeEditingState()
        }
    }
    
    private func changeEditingState(_ onlyIfEditing: Bool? = nil) {
        if let _ = onlyIfEditing {
            if tableView.isEditing {
                tableView.setEditing(false, animated: false)
            }
        } else {
            tableView.setEditing(tableView.isEditing ? false : true, animated: false)
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, !text.isEmpty {
            filteredTags = tags.filter({ $0.title?.contains(text) ?? false })
        } else {
            filteredTags = tags
        }
        self.tableView.reloadData()
    }
    
    
    
    // MARK: - IBAction functions
    
    @IBAction func didPressAddTag(_ sender: UIBarButtonItem) {
        let controller = UIAlertController(title: AppText.Tags.newTag, message: nil, preferredStyle: .alert)
        controller.addTextField { (textField) in
            textField.placeholder = AppText.Tags.name
        }
        controller.addAction(UIAlertAction(title: AppText.Actions.save, style: .default, handler: { (_) in
            if let name = controller.textFields?.first?.text {
                let tag = VTag()
                tag.title = name
                TagSubmitter.submit([tag], requestMethod: .post)
            }
        }))
        controller.addAction(UIAlertAction(title: AppText.Actions.cancel, style: .cancel, handler: { (_) in
            
        }))
        self.present(controller, animated: true)
    }
    
}
