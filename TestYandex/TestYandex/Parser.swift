//
//  Parser.swift
//  TestYandex
//
//  Created by admin on 12.08.15.
//  Copyright (c) 2015 iosOleksii. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class ParseData {
    
    func listCategiries(categiriesJson : JSON) -> [List]? {
        var list = [List]()
        let array = categiriesJson.arrayValue
        
        for index in 0..<array.count {
            let title = array[index]["title"].stringValue
            var items = [Item]()
            let subs = array[index]["subs"].arrayValue
            
            for i in 0..<subs.count {
                items.append(Item(id: subs[i]["id"].intValue, title: subs[i]["title"].stringValue))
            }
            
            list.append(List(title: title, array: items))
        }
        return list
    }
}
