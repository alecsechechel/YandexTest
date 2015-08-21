//
//  Constants.swift
//  TestYandex
//
//  Created by admin on 12.08.15.
//  Copyright (c) 2015 iosOleksii. All rights reserved.
//

import Foundation
import UIKit

struct Item {
    let id : Int!
    let title : String!
}

struct List {
    let title: String!
    let array: [Item]?
}

let kURL = "https://money.yandex.ru"
let kList = "/api/categories-list"

let kDB = "list.db"

let kCellIndentifier = "Cell"

let kHeaderColor = UIColor(rgba: "#bdc3c7")
let kItemsColor = UIColor(rgba: "#ecf0f1")
