//
//  Category.swift
//  Todoey
//
//  Created by Nabil Arbouz on 7/12/19.
//  Copyright © 2019 Nabil Arbouz. All rights reserved.
//

import Foundation
import RealmSwift
import ChameleonFramework

class Category : Object {
    @objc dynamic var name : String = ""
    var items = List<Item>()
    @objc dynamic var backgroundColor : String = UIColor.randomFlat.hexValue()
}
