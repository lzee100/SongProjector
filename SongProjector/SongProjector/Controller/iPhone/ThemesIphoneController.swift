//
//  ThemesIphoneController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 27-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit
import SwiftUI

class ThemesIphoneController: ChurchBeamViewController, UIGestureRecognizerDelegate, UIPopoverPresentationControllerDelegate, NewOrEditIphoneControllerDelegate, UISearchResultsUpdating {
    
    @IBOutlet var add: UIBarButtonItem!
    @IBOutlet var tableView: UITableView!
    
    private var themes: [VTheme] = []
    private var filteredThemes: [VTheme] = []
    private var selectedTheme: VTheme?
    private var searchController: UISearchController!
    
    override var requesters: [RequesterBase] {
        return [ThemeFetcher, ThemeSubmitter]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ThemeFetcher.fetch()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, !text.isEmpty {
            let searchString = text.lowercased()
            filteredThemes = themes.filter {
                if let title = $0.title {
                    return title.lowercased().contains(searchString)
                } else {
                    return false
                }
            }
        } else {
            filteredThemes = themes
        }
        self.tableView.reloadData()
        
    }
    
    func didCreate(sheet: VSheet) {
    }
    
    func didCloseNewOrEditIphoneController() {
        presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func handleRequestFinish(requesterId: String, result: Any?) {
        Queues.main.async {
            self.update()
        }
    }
    
    private func setup() {
        tableView.register(cell: Cells.basicCellid)
        tableView.register(header: BasicHeaderView.identifier)
        tableView.keyboardDismissMode = .interactive
        navigationController?.title = AppText.Songs.title
        title = AppText.Themes.title
        add.title = AppText.Actions.add
        add.tintColor = themeHighlighted
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = AppText.Themes.searchBarPlaceholderText
        searchController.searchBar.tintColor = themeHighlighted
        navigationItem.searchController = searchController
        if #available(iOS 11.0, *) {
          navigationItem.hidesSearchBarWhenScrolling = false
      }
        
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.editTableView(_:)))
        longPressGesture.minimumPressDuration = 0.7
        self.tableView.addGestureRecognizer(longPressGesture)
        
        let doubleTab = UITapGestureRecognizer(target: self, action: #selector(self.editTableView(_:)))
        doubleTab.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTab)
        update()
    }
    
    override func update() {
        super.update()
        var predicates: [NSPredicate] = [.skipDeleted]
        predicates.append("isHidden", notEquals: true)
        let themes: [Theme] = DataFetcher().getEntities(moc: moc, predicates: predicates, sort: NSSortDescriptor(key: "position", ascending: true))
        
        self.themes = themes.map({ VTheme(theme: $0, context: moc) })
        filteredThemes = self.themes
        tableView.reloadData()
    }
    
    private func updatePostitions() {
        for (index, theme) in filteredThemes.enumerated() {
            theme.position = Int16(index)
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
    
    var editModel: WrappedStruct<EditSheetOrThemeViewModel>? = nil
    @IBAction func addThemePressed(_ sender: UIBarButtonItem) {
        guard let editThemeModel = EditSheetOrThemeViewModel(editMode: .newTheme, isUniversal: false) else { return }
        let model = WrappedStruct(withItem: editThemeModel)
        self.editModel = model
        let editView = EditThemeOrSheetViewUI(
            dismiss: { dismissPresenting in
                if dismissPresenting {
                    self.dismiss(animated: true)
                } else {
                    self.presentedViewController?.dismiss(animated: true)
                }
        },
            navigationTitle: AppText.NewTheme.title,
            editSheetOrThemeModel: model,
            submitThemeUseCaseResult: .idle
        )
        let controller = UIHostingController(rootView: editView)
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
}

extension ThemesIphoneController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredThemes.count
    }
    
}

extension ThemesIphoneController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.basicCellid, for: indexPath)
        
        if let cell = cell as? BasicCell {
            cell.setup(title: filteredThemes[indexPath.row].title)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if let playerTitle = themes[indexPath.row].title, playerTitle == "Player" || playerTitle == "Songs"  {
            return UITableViewCell.EditingStyle.none
        } else if !themes[indexPath.row].isDeletable {
            return UITableViewCell.EditingStyle.none
        } else {
            let deleteView = tableView.subviews.compactMap({ $0.subviews }).first(where: { $0.contains(where: { $0 is BasicCell }) })?.first
            deleteView?.style(tableView: tableView, forRowAt: indexPath)
            return UITableViewCell.EditingStyle.delete
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let theme = themes[indexPath.row]
            theme.deleteDate = Date() as NSDate
            ThemeSubmitter.submit([theme], requestMethod: .delete)
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return !searchController.isActive
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = filteredThemes[sourceIndexPath.row]
        filteredThemes.remove(at: sourceIndexPath.row)
        filteredThemes.insert(itemToMove, at: destinationIndexPath.row)
        updatePostitions()
        ThemeSubmitter.submit(filteredThemes.compactMap({ $0 }), requestMethod: .put)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Queues.main.async {
            self.selectedTheme = self.filteredThemes[indexPath.row]
            guard
                let themeCodable = ThemeCodable(
                    managedObject: self.filteredThemes[indexPath.row].getManagedObject(context: moc),
                    context: moc
                ),
                let model = EditSheetOrThemeViewModel(
                    editMode: .persistedTheme(themeCodable),
                    isUniversal: uploadSecret != nil
                ) else {
                return
            }
            let editView = EditThemeOrSheetViewUI(dismiss: { [weak self] dismissPresenting in
                if dismissPresenting {
                    self?.dismiss(animated: true)
                } else {
                    self?.presentedViewController?.dismiss(animated: true)
                }
            }, navigationTitle: AppText.EditTheme.title, editSheetOrThemeModel: WrappedStruct<EditSheetOrThemeViewModel>(withItem: model))
            self.present(UIHostingController(rootView: editView), animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.style(cell, forRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.basicHeaderView
        header?.descriptionLabel.text = nil
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
}
