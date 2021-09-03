//
//  TodoListTableViewController.swift
//  ToDoList
//
//  Created by Kuldeep Kumar P on 03/09/21.
//

import UIKit
import CoreData
import RealmSwift
import ChameleonFramework

class TodoListTableViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    var itemArray = [Item]()
    var realmItemArray: Results<ItemRelam>?
    let realm = try! Realm()
    var cellBackgrounColor: String = "#FFFF"
    // core data
//    var selectedCategory: MyCategory? {
//        didSet {
////            loadItems()
//        }
//    }
    
    // realm
    var selectedCategory: MyCategoryRelam? {
            didSet {
                cellBackgrounColor = selectedCategory?.colorString ?? "#FFFF"
                loadItemFromRealm()
            }
    }
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = 80
        // MARK: - User Defaults
        // Use UserDefaults only for small tid-bits.
        //        if let defaultsData = defaults.value(forKey: "ToDoListArray") as? Array<Item> {
        //            itemArray = defaultsData
        //        }
        
        self.searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let contrastingColor = UIColor.init(contrastingBlackOrWhiteColorOn: UIColor(hexString: cellBackgrounColor), isFlat: true) {
            self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : contrastingColor]
            self.navigationController?.navigationBar.tintColor = contrastingColor
        }
        
        
        self.title = selectedCategory?.name
        searchBar.barTintColor = UIColor(hexString: cellBackgrounColor)
        searchBar.searchTextField.backgroundColor = .white
        self.navigationController?.view.backgroundColor = UIColor(hexString: selectedCategory?.colorString ?? "#FFFF")
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDeletion = self.realmItemArray?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(itemForDeletion)
                }
            } catch {
                print("Failed to write to realm")
            }
        }
    }
}

// MARK: - Actions

extension TodoListTableViewController {
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New ToDo Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            if let newItemText = textField.text {
                // Core Data
//                let newItem = Item(context: self.context)
//                newItem.title = newItemText
//                newItem.parentCategory = self.selectedCategory
//                self.itemArray.append(newItem)
////                self.saveItems()
                
                // User Defaults
                //                self.defaults.setValue(self.itemArray, forKey: "ToDoListArray")
                
                // Realm
                if let currentCategory = self.selectedCategory {
                   
                    do {
                        try self.realm.write {
                            let newRealmItem = ItemRelam()
                            newRealmItem.title = newItemText
                            currentCategory.items.append(newRealmItem)
                        }
                    } catch {
                        print("Failed to save items to Realm")
                    }
                    self.tableView.reloadData()
                }
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Model Manipulation

extension TodoListTableViewController {
    // MARK: - NSEncoder
    
    func saveItems() {
        //        let encoder = PropertyListEncoder()
        //
        //        do {
        //            let data = try encoder.encode(itemArray)
        //
        //            if let path = self.dataFilePath {
        //                try data.write(to: path)
        //            } else {
        //                print("Invalid Path!")
        //            }
        //        } catch {
        //            print("Failed to encode!")
        //        }
        
        // MARK: - Core Data
        do {
            try context.save()
        } catch {
            print("Failed to save items to Core Data")
        }
    }
    
    func loadItems(request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        //        do {
        //            if let path = self.dataFilePath {
        //                let data = try Data(contentsOf: path)
        //                let decoder = PropertyListDecoder()
        //                itemArray = try decoder.decode([Item].self, from: data)
        //            } else {
        //                print("Invalid Path!")
        //            }
        //        } catch {
        //            print("Failed to decode!")
        //        }
        
        // MARK: - Core Data
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from Core Data")
        }
        
        self.tableView.reloadData()
    }
    
    func loadItemFromRealm() {
        realmItemArray = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        self.tableView.reloadData()
    }
}

// MARK: - Table view Delegates

extension TodoListTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // core data
//        return itemArray.count
        // Realm
        return realmItemArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        // core data
//        let item = itemArray[indexPath.row]
//
//        cell.textLabel?.text = item.title
//
//        cell.accessoryType = item.isDone ? .checkmark : .none
        if let color = UIColor(hexString: cellBackgrounColor)?.darken(byPercentage: (CGFloat(indexPath.row)/CGFloat(realmItemArray!.count))) {
            cell.backgroundColor = color
            cell.textLabel?.textColor = UIColor.init(contrastingBlackOrWhiteColorOn: color, isFlat: true)
        }
        
        // Realm
        if let item = realmItemArray?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.isDone ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        // core data
//        itemArray[indexPath.row].isDone = !itemArray[indexPath.row].isDone
//        self.saveItems()
        
        // realm
        if let item = realmItemArray?[indexPath.row] {
            do {
                try realm.write {
                    item.isDone = !item.isDone
                }
            } catch {
                print("Error saving done status")
            }
        }
        
        tableView.reloadData()
    }
}

// MARK: - Search Delegates

extension TodoListTableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Core data
//        let request: NSFetchRequest<Item> = Item.fetchRequest()
//        if let searchText = searchBar.text {
//            let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchText)
//            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//
//            self.loadItems(request: request, predicate: predicate)
//        }
        
        // realm
        if let searchText = searchBar.text {
            realmItemArray = realmItemArray?.filter("title CONTAINS[cd] %@", searchText).sorted(byKeyPath: "title", ascending: true)
        }
        
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.isEmpty ?? true {
            self.loadItemFromRealm()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
