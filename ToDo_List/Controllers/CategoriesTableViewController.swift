//
//  CategoriesTableViewController.swift
//  ToDoList
//
//  Created by Kuldeep Kumar P on 03/09/21.
//

import UIKit
import CoreData
import RealmSwift
import ChameleonFramework

class CategoriesTableViewController: SwipeTableViewController {

    var categories = [MyCategory]()
    var realmCategories: Results<MyCategoryRelam>?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = 80
        
        // core data
//        self.loadCategories()
        
        // realm
        self.loadCategoriesFromRealm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.view.backgroundColor = .systemBlue
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
    }
    
    // Delete Data
    
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.realmCategories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("Failed to write to realm")
            }
        }
    }
}

// MARK: - Table view delegates
extension CategoriesTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // core data
//        return categories.count
        
        // realm
        return realmCategories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
// core Data
//        cell.textLabel?.text = categories[indexPath.row].name


        // realm
        cell.textLabel?.text = realmCategories?[indexPath.row].name ?? "No Category Added"
        cell.backgroundColor = UIColor(hexString: realmCategories?[indexPath.row].colorString)
        if let contrastingColor = UIColor.init(contrastingBlackOrWhiteColorOn: cell.backgroundColor, isFlat: true) {
            cell.textLabel?.textColor = contrastingColor
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "gotoItems", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let itemsVC = segue.destination as! TodoListTableViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            // core data
//            itemsVC.selectedCategory = categories[indexPath.row]
            
            // realm
            itemsVC.selectedCategory = realmCategories?[indexPath.row]
        }
    }
}

// MARK: - Data Manipulation

extension CategoriesTableViewController {
    @IBAction func addCategory(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            
            if let newCategoryText = textField.text {
                // Core Data Objects
//                let newCategory = MyCategory(context: self.context)
//
//                self.categories.append(newCategory)
                
                let newCategory = MyCategoryRelam()
                newCategory.name = newCategoryText
                newCategory.colorString = UIColor.randomFlat()?.hexValue() ?? "#FFFF"
                self.saveCategoriesIntoRealm(category: newCategory)
//                self.saveCategories()
                self.tableView.reloadData()
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Model Manipulation - Core Data

extension CategoriesTableViewController {
    func saveCategories() {
        do {
            try context.save()
        } catch {
            print("Failed to save Categories to Core Data")
        }
    }
    
    func saveCategoriesIntoRealm(category: MyCategoryRelam) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Failed to save Categories to realm")
        }
    }
    
    // core data
    func loadCategories() {
        let request: NSFetchRequest<MyCategory> = MyCategory.fetchRequest()
        self.fetchCategories(with: request)
    }
    
    // realm
    func loadCategoriesFromRealm() {
        realmCategories = realm.objects(MyCategoryRelam.self)
        self.tableView.reloadData()
    }
    
    func fetchCategories(with request: NSFetchRequest<MyCategory>) {
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error fetching data from Core Data")
        }
        
        self.tableView.reloadData()
    }
}
