//
//  ShoppingListViewController.swift
//  C2ShoppingList
//
//  Created by Chris Parker on 5/3/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import UIKit

class ShoppingListViewController: UITableViewController, UITextFieldDelegate {
    
    var shoppingList = [String]()
    
    var doneButton: UIBarButtonItem!
    var cartButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Shopping List"
        navigationController?.navigationBar.prefersLargeTitles = true
        let barImage = UIImage(named: "white")
        navigationController?.navigationBar.setBackgroundImage(barImage, for: .default)
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = .darkGray
        
        //  Left and Right bar button item setup.
        doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneEditing))
        cartButton = UIBarButtonItem(image: UIImage(systemName: "cart.badge.plus"), style: .plain, target: self, action: #selector(newShoppingItem))
        
        navigationItem.rightBarButtonItems = [cartButton]

        let trashButton = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: #selector(clearList))
        navigationItem.leftBarButtonItems = [trashButton]
        
        //  Bottom toolbar setup
        let flexibleSpacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let share = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        let addItem = UIBarButtonItem(image: UIImage(systemName: "cart.badge.plus"), style: .plain, target: self, action: #selector(newShoppingItem))
        
        navigationController?.toolbar.setBackgroundImage(barImage, forToolbarPosition: .any, barMetrics: .default)
        navigationController?.toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        navigationController?.toolbar.isTranslucent = true
        navigationController?.toolbar.backgroundColor = .clear
        navigationController?.toolbar.tintColor = .darkGray

        toolbarItems = [flexibleSpacer, share, flexibleSpacer, addItem]
        navigationController?.isToolbarHidden = false
        navigationController?.toolbar.isTranslucent = true
        
//        let normalTapGesture = UITapGestureRecognizer(target: self, action: #selector(normalTap(_:)))
//        normalTapGesture = 1
//        tableView.addGestureRecognizer(normalTapGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        tableView.addGestureRecognizer(doubleTapGesture)
        
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longTap(_ :)))
        tableView.addGestureRecognizer(longTapGesture)
        
        let itemsObject = UserDefaults.standard.object(forKey: "shoppingList")
        
        if let tempItems = itemsObject as? [String] {
            
            shoppingList = tempItems
            
        }
        
        // Hides separator lines on unused cells
        tableView.tableFooterView = UIView()
    }

    @objc func newShoppingItem() {
        let ac = UIAlertController(title: "Add New Item 👍", message: nil, preferredStyle: .alert)
        ac.addTextField { (textField) in
            textField.autocorrectionType = .default
        }
        
        let newItemAction = UIAlertAction(title: "Save", style: .default) { [weak self, weak ac] action in
            guard let self = self else { return }
            guard let newItem = ac?.textFields?[0].text else { return }
            if newItem == "" {
                self.showAlert(with: "Ooops", description: "Come on, WAKE UP!😴\nAn item to add would be useful.")
                return
            } else {
                let itemToAdd = newItem.capitalized
                self.addItem(itemToAdd)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        ac.addAction(newItemAction)
        ac.addAction(cancelAction)
        present(ac, animated: true)
    }
    
    func showAlert(with title: String, description message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        ac.addAction(okAction)
        present(ac, animated: true)
    }
    
    func addItem(_ itemToAdd: String) {
        // Insert item at the beginning of the array.
        if shoppingList.contains(itemToAdd) {
            showAlert(with: "This item already exists!", description: "Pay attention!🤔")
            return
        }
        shoppingList.insert(itemToAdd, at: 0)
        UserDefaults.standard.set(self.shoppingList, forKey: "shoppingList")

        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.none
    }
    
    @objc func clearList() {
        let ac = UIAlertController(title: "STOP", message: "After all that work, do you really want to erase all these entries? 😖", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Yes!", style: .destructive) { ( action ) in
            self.shoppingList.removeAll()
            UserDefaults.standard.set(self.shoppingList, forKey: "shoppingList")
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        ac.addAction(okAction)
        ac.addAction(cancelAction)
        present(ac, animated: true)
        
    }
    
    @objc func shareTapped() {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let now = Date()
        let dateString = formatter.string(from: now)
        
        var list = "My Shopping List as at: \(dateString)\n"
        list += shoppingList.joined(separator: ", ")
        let vc = UIActivityViewController(activityItems: [list], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
        
    }
    
    @objc func longTap(_ sender: UIGestureRecognizer) {
        if sender.state == .began {
            UIView.animate(withDuration: 0.3) {
                self.tableView.isEditing = true
                self.navigationItem.rightBarButtonItems = [self.cartButton, self.doneButton]
            }
        }
    }
    
    @objc func doneEditing() {
        self.tableView.isEditing = false
        navigationItem.rightBarButtonItems = [cartButton]
    }
    
    @objc func doubleTap(_ sender: UIGestureRecognizer) {
        if tableView.isEditing == true {
            UIView.animate(withDuration: 0.3) {
                self.tableView.isEditing = false
                self.navigationItem.rightBarButtonItems = [self.cartButton]
            }
        }
    }
    
    
    func doesAbsolutelyNothing(_ itemToAdd: String) {
        // Code to insert row at the beginning of the array.
        
        
        //  Code to insert row at the end of the array
        var row = 0
        if shoppingList.isEmpty {
            row = 0
        } else {
            row = shoppingList.count
        }
        shoppingList.insert(itemToAdd, at: row)
        UserDefaults.standard.set(self.shoppingList, forKey: "shoppingList")
        
        let indexPath = IndexPath(row: row, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

}

extension ShoppingListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = shoppingList[indexPath.row]
        
        //  Set the background colour of the cell to white but with alpha of 0.6 so that some of the background colour of the tableView bleeds through giving a paler look compared to unused cells.
//        cell.contentView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, nil) in
            self.shoppingList.remove(at: indexPath.row)
            UserDefaults.standard.set(self.shoppingList, forKey: "shoppingList")
            tableView.reloadData()
        }
        
        deleteAction.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        deleteAction.image = UIImage(systemName: "trash")
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        config.performsFirstActionWithFullSwipe = false
        
        return config
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.isEditing = false
        if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCell.AccessoryType.checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = shoppingList.remove(at: sourceIndexPath.row)
        shoppingList.insert(itemToMove, at: destinationIndexPath.row)
        
        UserDefaults.standard.set(self.shoppingList, forKey: "shoppingList")
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        
        //  This removes the delete option that would normally appear on the left side of the row.
        return UITableViewCell.EditingStyle.none
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}
