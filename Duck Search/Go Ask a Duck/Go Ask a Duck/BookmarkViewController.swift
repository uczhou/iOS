//
//  BookmarkViewController.swift
//  Go Ask a Duck
//
//  Created by Honglei Zhou on 2/16/18.
//  Copyright © 2018 Honglei Zhou. All rights reserved.
//

import UIKit

class BookmarkViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    var objects = [String]()
    
    /// Reference to the object that conforms to the `DetailBookmarkDelegate`
    
    weak var delegate: DetailBookmarkDelegate?
    
    @IBOutlet weak var tableView: UITableView!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        objects = [String]()
        self.navigationController?.setToolbarHidden(false, animated: true)
        // Load data into view
        let defaults = UserDefaults.standard
        if let urlArray = defaults.array(forKey: "myURL") {
            for obj in urlArray as! [String]{
                let result = obj.components(separatedBy: "\n")
                objects.append(result[0])
            }
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
        
    }
    
    @IBAction func editFavorite(_ sender: UIBarButtonItem) {
        if(self.tableView.isEditing == true)
        {
            self.tableView.isEditing = false
        }
        else
        {
            self.tableView.isEditing = true
        }
    }
    // MARK: - Table View
    
    @IBAction func closeBookmark(_ sender: UIBarButtonItem) {
        if(self.tableView.isEditing == true)
        {
            self.tableView.isEditing = false
            //self.navigationItem.rightBarButtonItem?.title = "Done"
        }
        self.dismiss(animated: false, completion: nil)
        
    }
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
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let object = objects[indexPath.row]
        delegate?.bookmarkPassedURL(object)
        self.dismiss(animated: false, completion: nil)
     }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            dataDelete(row: indexPath.row)
            refresher()
        
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func dataDelete(row: Int) {
        let defaults = UserDefaults.standard
        if let urlArray = defaults.array(forKey: "myURL") {
            if urlArray.count > 0 {
                var tmp = urlArray
                tmp.remove(at: row)
                defaults.set(tmp, forKey: "myURL")
            }
        }
    }
    
    func refresher() {
        self.viewDidLoad()
    }
}
