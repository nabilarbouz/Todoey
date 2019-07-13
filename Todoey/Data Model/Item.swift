//
//  Item.swift
//  Todoey
//
//  Created by Nabil Arbouz on 7/12/19.
//  Copyright © 2019 Nabil Arbouz. All rights reserved.
//

import Foundation
import RealmSwift

class Item : Object {
    @objc dynamic var title : String = ""
    @objc dynamic var done : Bool = false
    @objc dynamic var dateCreated: Date?
    
    // "Category.self" makes "Category" the type. and "items" is the property in the
    var parentCategory = LinkingObjects<Category>(fromType: Category.self, property: "items")
}
