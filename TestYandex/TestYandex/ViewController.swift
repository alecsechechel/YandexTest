//
//  ViewController.swift
//  TestYandex
//
//  Created by admin on 12.08.15.
//  Copyright (c) 2015 iosOleksii. All rights reserved.
//

import UIKit
import SwiftyJSON
import SQLite
import Alamofire

public class ViewController: UIViewController {

    @IBOutlet public weak var tableView: UITableView!
    
    var list = [List]()
    var databasePath = ""
    
    var arrayIsSectionExpanded: [Int]!
    var sectionContentDict = [String: [String]]()
    
    //MARK: - UIViewController lifecycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Яндекс.Денег"
        savePath(kDB)
        if isExist() {
            getListFromDB()
        } else {
            createDB()
            getList()
        }
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: - Tap Action
    func sectionHeaderTapped(recognizer: UITapGestureRecognizer) {
        var indexPath = NSIndexPath(forRow: 0, inSection:(recognizer.view?.tag)!)
        
        if indexPath.row == 0 {
            arrayIsSectionExpanded[indexPath.section] = arrayIsSectionExpanded[indexPath.section] == 1 ? 0 : 1

            var range = NSMakeRange(indexPath.section, 1)
            var sectionToReload = NSIndexSet(indexesInRange: range)
            self.tableView.reloadSections(sectionToReload, withRowAnimation:UITableViewRowAnimation.Fade)
        }
    }
    
    // MARK: - Expand Table
    func prepareForExpand() {
        
        arrayIsSectionExpanded = [Int](count: list.count, repeatedValue: 0)
        for value in list {
            if let array = value.array {
                let subStrings: [String] = array.map { $0.title }
                sectionContentDict[value.title] = subStrings
            }
        }
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: kCellIndentifier)
    }
    
    // MARK: - Get List
    func getList() {
        YandexProvider.manager.session.configuration.HTTPAdditionalHeaders?.updateValue("ru", forKey: "Accept-Language")
        YandexProvider.request(.GetList, completion: {(data, status, resonse, error) -> () in
            var success = error == nil
            if let data = data {
                let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil)
                if let json: AnyObject = json {
                    self.list = ParseData().listCategiries(JSON(json))!
                    self.saveData(self.list)
                    self.prepareForExpand()
                    self.tableView.reloadData()
                } else {
                    success = false
                }
            } else {
                success = false
            }
            
            if !success {
                self.showAlert("Wi-Fi not avaiable!")
            }
        })
    }
    
    //MARK: - Alert
    func showAlert(text: String) {
        let alertController = UIAlertController(title: "Error", message: text, preferredStyle: .Alert)
        let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        })
        alertController.addAction(ok)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //MARK: - DB
    func createDB() {
        if !isExist() {
            let listDB = FMDatabase(path: databasePath as String)
            
            if listDB == nil {
                println("Error: \(listDB.lastErrorMessage())")
            }
            
            if listDB.open() {
                let sql_stmt_first = "CREATE TABLE IF NOT EXISTS CATEGORIES (ID INTEGER, TITLE TEXT)"
                if !listDB.executeStatements(sql_stmt_first) {
                    println("Error: \(listDB.lastErrorMessage())")
                }
                let sql_stmt_second = "CREATE TABLE IF NOT EXISTS SUBS (ID INTEGER, TITLE TEXT, CATEGORY TEXT)"
                if !listDB.executeStatements(sql_stmt_second) {
                    println("Error: \(listDB.lastErrorMessage())")
                }
                listDB.close()
            } else {
                println("Error: \(listDB.lastErrorMessage())")
            }
        }
    }
    
    func saveData(list: [List]) {
        let listDB = FMDatabase(path: databasePath as String)
        
        deleteData()
        if listDB.open() {
            for index in 0..<list.count {
                let insertSQL = "INSERT INTO CATEGORIES (id, title) VALUES ('\(index+1)', '\(list[index].title)')"
                let result = listDB.executeUpdate(insertSQL,
                    withArgumentsInArray: nil)
                
                if !result {
                    println("Error: \(listDB.lastErrorMessage())")
                }
                
                if let array = list[index].array {
                    for i in 0..<array.count {
                        let insertSQL = "INSERT INTO SUBS (id, title, category) VALUES ('\(array[i].id)', '\(array[i].title)', '\(list[index].title)')"
                        let result = listDB.executeUpdate(insertSQL, withArgumentsInArray: nil)
                        
                        if !result {
                            println("Error: \(listDB.lastErrorMessage())")
                        }
                    }
                }
            }
        } else {
            println("Error: \(listDB.lastErrorMessage())")
        }
    }
    
    func deleteData() {
        let listDB = FMDatabase(path: databasePath as String)
        
        if listDB.open() {
            let deleteCategoriesSQL = "DELETE FROM CATEGORIES"
            let resultCategories = listDB.executeUpdate(deleteCategoriesSQL,withArgumentsInArray: nil)
            let deleteSubsSQL = "DELETE FROM SUBS"
            let resultSubs = listDB.executeUpdate(deleteSubsSQL,withArgumentsInArray: nil)
            
            if !resultCategories || !resultSubs {
                println("Error: \(listDB.lastErrorMessage())")
            }
            listDB.close()
        }
    }
    
    func getListFromDB() {
        let listDB = FMDatabase(path: databasePath as String)
        
        list.removeAll(keepCapacity: false)
        if listDB.open() {
            let querySQL = "SELECT title FROM CATEGORIES"
            let results:FMResultSet? = listDB.executeQuery(querySQL, withArgumentsInArray: nil)

            if let result = results {
                while result.next() {
                    let title = result.stringForColumn("title")
                    let items = getListSubs(title)
                    list.append(List(title: title, array:items))
                }
            }
            listDB.close()
        } else {
            println("Error: \(listDB.lastErrorMessage())")
        }
        prepareForExpand()
        tableView.reloadData()
    }
    
    func getListSubs(name: String) -> [Item]? {
        let listDB = FMDatabase(path: databasePath as String)
        var item = [Item]()
        
        if listDB.open() {
            let querySQL = "SELECT id, title FROM SUBS WHERE category = \"\(name)\""
            let results:FMResultSet? = listDB.executeQuery(querySQL, withArgumentsInArray: nil)
            
            if let result = results {
                while result.next() {
                    item.append(Item(id: Int(result.intForColumn("id")), title: result.stringForColumn("title")))
                }
            }
            listDB.close()
        } else {
            println("Error: \(listDB.lastErrorMessage())")
        }
        return item
    }
    
    //MARK: - File Managere
    func isExist() -> Bool {
        let filemgr = NSFileManager.defaultManager()
        
        return filemgr.fileExistsAtPath(databasePath as String)
    }
    
    func savePath(name: String) {
        let filemgr = NSFileManager.defaultManager()
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docsDir = dirPaths[0] as! String
        
        databasePath = docsDir.stringByAppendingPathComponent(name)
    }
    
    //MARK: - Refresh
    @IBAction func refresh(sender: AnyObject) {
        getList()
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return list.count
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let array = arrayIsSectionExpanded {
            if array[section] == 1 {
                if let count = list[section].array?.count {
                    return count
                }
            }
        }
        return 0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 40))
        headerView.backgroundColor = kHeaderColor
        headerView.tag = section
        
        let headerString = UILabel(frame: CGRect(x: 10, y: 10, width: tableView.frame.size.width-10, height: 30)) as UILabel
        headerString.text = list[section].title
        headerView.addSubview(headerString)
        
        let headerTapped = UITapGestureRecognizer(target: self, action:"sectionHeaderTapped:")
        headerView.addGestureRecognizer(headerTapped)
        
        return headerView
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        var cell = self.tableView.dequeueReusableCellWithIdentifier(kCellIndentifier) as! UITableViewCell
        var manyCells = arrayIsSectionExpanded[indexPath.section] == 1 ? true : false
        
        if manyCells {
            let arrayContent = sectionContentDict[list[indexPath.section].title]!
            
            cell.textLabel?.text = arrayContent[indexPath.row]
            cell.backgroundColor = kItemsColor
        }
        return cell
    }
}









