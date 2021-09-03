//
//  Data.swift
//  ToDoList
//
//  Created by Kuldeep Kumar P on 03/09/21.
//

import Foundation
import RealmSwift

class ItemRelam: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var isDone: Bool = false
    @objc dynamic var colorString: String = ""
    var parentCategory = LinkingObjects(fromType: MyCategoryRelam.self, property: "items")
}

class MyCategoryRelam: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var colorString: String = ""
    let items = List<ItemRelam>()
}
