//
//  Data.swift
//  Todoey
//
//  Created by Nabil Arbouz on 7/12/19.
//  Copyright © 2019 Nabil Arbouz. All rights reserved.
//

import Foundation
import RealmSwift

class Data : Object {
    @objc dynamic var name : String  = ""
    @objc dynamic var age : Int = 0
}
