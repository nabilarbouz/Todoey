//
//  ViewController.swift
//  Todoey
//
//  Created by Nabil Arbouz on 7/6/19.
//  Copyright © 2019 Nabil Arbouz. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var itemArray = [Item]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        loadData()
        
        print(directoryPath)
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        //this line will change the bool flag associated with whether the task is completed or not
        // it will affect the checkmark so we will reload the data after
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
    
        saveData()

        tableView.deselectRow(at: indexPath, animated: true)
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
        //what we will do when the user clicks the add new item button in the alert
            
            let newItem = Item(context: self.context)
            
            newItem.title = textField.text!
            newItem.done = false
            
            self.itemArray.append(newItem)
            
            self.saveData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)

        present(alert, animated: true, completion: nil)
    }
    
    func saveData() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context, \(error)")
        }
        tableView.reloadData()
    }
    
    func loadData(with request: NSFetchRequest<Item> = Item.fetchRequest()) {
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching the data, \(error)")
        }
        
        tableView.reloadData()
    }
    
}

extension TodoListViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        //this will adjust what the query will look for using NSPredicate regex
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        //this will toggle a sort on th query so it comes in ascending order
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        //now we load the data with this custom request as the argument
        loadData(with: request)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchBar.text?.count == 0) {
            loadData()
            
            //this will take the cursor away from the search bar immediately after pressing the "X" on the searchbar. Async will allow this to be performed in the backgroun so it does not stop any other operations
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
