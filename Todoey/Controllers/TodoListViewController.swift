//
//  ViewController.swift
//  Todoey
//
//  Created by Nabil Arbouz on 7/6/19.
//  Copyright © 2019 Nabil Arbouz. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    //let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let realm = try! Realm()
    
    var todoItems : Results<Item>?
    
    @IBOutlet var searchBar: UISearchBar!
    
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        loadItems()
        
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = selectedCategory?.name
        
        guard let colorHex = selectedCategory?.backgroundColor else {fatalError()}
        
        updateNavBar(withHexCode: colorHex)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateNavBar(withHexCode: "1D9BF6")
    }
    
    func updateNavBar(withHexCode colorHexCode : String) {
        guard let navBar = navigationController?.navigationBar else {fatalError()}
        
        guard let navBarColor = UIColor(hexString: colorHexCode) else {fatalError()}
        
        //this changes the color of the navigation bar background color
        navBar.barTintColor = navBarColor
        
        //this makes the buttons on navigation bar the contrast color of the background
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        
        //once we have made the titles bigger through the main story board -> nav controler -> nav bar -> prefer larger titles, we can make sure that title text is the contrast of the navbar background color
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
        
        searchBar.barTintColor = navBarColor
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
        
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none

            if let color = HexColor(selectedCategory!.backgroundColor)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
                
            }
        } else {
            cell.textLabel?.text = "No items added yet"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        //this line will change the bool flag associated with whether the task is completed or not
        // it will affect the checkmark so we will reload the data after
        //todoItems[indexPath.row].done = !todoItems[indexPath.row].done
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                    //this is the line to delete the item when we implement that
                    // realm.delete(item)
                }
            } catch {
                print("Error changing the item status: \(error)")
            }
        }
        
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
        //what we will do when the user clicks the add new item button in the alert
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("error creating a new item: \(error)")
                }
            }
            self.tableView.reloadData()
        }

        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)

        present(alert, animated: true, completion: nil)
    }
    
    func saveData() {
        tableView.reloadData()
    }
    
    func loadItems() {
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
      
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemToDelete = self.todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(itemToDelete)
                }
            } catch {
                print("Unable to delete item: \(error)")
            }
        }
    }
    
}

extension TodoListViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        let request : NSFetchRequest<Item> = Item.fetchRequest()
//
//        //this will adjust what the query will look for using NSPredicate regex
//        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//
//        //this will toggle a sort on th query so it comes in ascending order
//        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//
//        //now we load the data with this custom request as the argument
//        loadItems(with: request, predicate: predicate)
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchBar.text?.count == 0) {
            loadItems()

            //this will take the cursor away from the search bar immediately after pressing the "X" on the searchbar. Async will allow this to be performed in the backgroun so it does not stop any other operations
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
