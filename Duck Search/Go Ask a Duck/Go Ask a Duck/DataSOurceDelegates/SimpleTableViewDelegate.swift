//
//  SimpleTableViewDelegate.swift
//  Go Ask a Duck
//
//  Created by Honglei Zhou on 2/15/18.
//  Copyright © 2018 Honglei Zhou. All rights reserved.
//

import Foundation

import UIKit


class SimpleTableDataSourceDelegate: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var objects = [String]()
    
    //weak var cellDelegate: BookmarkTableDelegate?
    
    // MARK: - Initialization
    override init() {}
    
    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookmarkCell", for: indexPath)
        let object = objects[indexPath.row]
        cell.textLabel!.text = object
        return cell
    }
    /*
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("clicked")
        let object = objects[indexPath.row]
        //print(object)
        //cellDelegate?.passCellContent(object)
    }
    */
    
}
